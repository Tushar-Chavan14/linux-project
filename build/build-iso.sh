#!/usr/bin/env bash
# Build the hyprdev live ISO with KIWI inside a privileged Fedora container.
# Output: out/iso/HyprDev-HyprDev-Live-*.iso
#   build/build-iso.sh            # full build (rebuilds our RPMs first)
#   SKIP_RPMS=1 build/build-iso.sh  # reuse out/rpms
#   FAST=1 build/build-iso.sh       # test build: lz4 instead of lzma (bigger ISO, ~6 min faster)
#   CACHE=0 build/build-iso.sh      # ignore .cache/pkg-cache (see build/cache-packages.sh)
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../config.env
source "$root/config.env"

FKD_URL="https://pagure.io/fedora-kiwi-descriptions.git"
FKD_REF="${FKD_REF:-f$FEDORA_VERSION}"
cache="$root/.cache"; desc="$cache/kiwi-desc"; mkdir -p "$cache" "$root/out/iso"

# 0. An interrupted build can leave root-owned files (the container's chown
#    trap never ran); hand them back before we try to delete anything.
if [[ -n $(find "$root/out" "$cache" ! -user "$(id -u)" -print -quit 2>/dev/null) ]]; then
  docker run --rm -v "$root/out:/o" -v "$cache:/c" "registry.fedoraproject.org/fedora:$FEDORA_VERSION" \
    chown -R "$(id -u):$(id -g)" /o /c
fi

# 1. Our RPMs -> local repo
[[ ${SKIP_RPMS:-0} == 1 ]] || "$root/packaging/build-rpms.sh"

# 2. Fedora's KIWI descriptions for this release
if [[ ! -d $cache/fkd/.git ]]; then git clone -q -b "$FKD_REF" "$FKD_URL" "$cache/fkd"
else git -C "$cache/fkd" fetch -q origin "$FKD_REF" && git -C "$cache/fkd" checkout -q FETCH_HEAD; fi
echo "fedora-kiwi-descriptions @ $(git -C "$cache/fkd" rev-parse --short HEAD)"

# 3. Assemble description: Fedora's tree + our overlay
# -L: the boxbuild VM reads this tree over 9p, which does not follow symlinks
rm -rf "$desc"; cp -rL "$cache/fkd" "$desc"; rm -rf "$desc/.git"
cp -a "$root/build/kiwi/." "$desc/"
sed -i "s/@FEDORA_VERSION@/$FEDORA_VERSION/g" "$desc/HyprDev.kiwi"
copr_xml=""
for c in "${COPRS[@]}"; do
  owner=${c%%/*} proj=${c##*/}
  base="https://download.copr.fedorainfracloud.org/results/$owner/$proj"
  copr_xml+="	<repository type=\"rpm-md\" alias=\"copr-$owner-$proj\" imageinclude=\"true\">
		<source path=\"$base/fedora-\$releasever-\$basearch/\">
			<signing key=\"$base/pubkey.gpg\"/>
		</source>
	</repository>
"
done
# Local package cache (build/cache-packages.sh): preferred over the network,
# remote repos still fill in anything new.
if [[ ${CACHE:-1} == 1 && -d $cache/pkg-cache/repodata ]]; then
  copr_xml+="	<repository type=\"rpm-md\" alias=\"hyprdev-cache\" priority=\"2\" imageinclude=\"false\">
		<source path=\"this://./pkg-cache\"/>
	</repository>
"
  echo "Package cache: $(find "$cache/pkg-cache" -name '*.rpm' | wc -l) RPMs"
fi
python3 - "$desc/repositories/hyprdev.xml.in" "$desc/repositories/hyprdev.xml" "$copr_xml" <<'PY'
import sys
src, dst, copr = sys.argv[1:]
open(dst, "w").write(open(src).read().replace("@COPR_REPOS@", copr.rstrip()))
PY
rm "$desc/repositories/hyprdev.xml.in"
if [[ -n ${FEDORA_MIRROR:-} ]]; then
  python3 - "$desc/repositories/core.xml" "$FEDORA_MIRROR" <<'PY'
import re, sys
path, m = sys.argv[1:]
s = open(path).read()
s = s.replace('sourcetype="metalink"', 'sourcetype="baseurl"')
s = re.sub(r'https://mirrors\.fedoraproject\.org/metalink\?repo=fedora-\$releasever&amp;arch=\$basearch',
           m + '/releases/$releasever/Everything/$basearch/os/', s)
s = re.sub(r'https://mirrors\.fedoraproject\.org/metalink\?repo=updates-released-f\$releasever&amp;arch=\$basearch',
           m + '/updates/$releasever/Everything/$basearch/', s)
open(path, "w").write(s)
PY
  echo "Fedora mirror: $FEDORA_MIRROR"
fi
# ISO identity
sed -i -e "s/publisher=\"Fedora Project\"/publisher=\"$DISTRO_PRETTY\"/" \
       -e "s/application_id=\"Fedora_Linux\"/application_id=\"$DISTRO_NAME\"/" \
       -e "s/volid=\"Fedora_Linux\"/volid=\"$DISTRO_NAME\"/" \
       -e "s/mediacheck=\"true\"/mediacheck=\"false\"/" "$desc/components/liveinstall.xml"
if [[ ${FAST:-0} == 1 ]]; then
  sed -i 's/erofscompression="lzma,level=6"/erofscompression="lz4hc,level=9"/' "$desc/components/liveinstall.xml"
  echo "FAST=1: lz4hc compression (test build, larger ISO)"
fi  # boxbuild VM has no tagmedia; ISO ships a .sha256 instead
# Fedora's config.sh ends with "exit 0": insert our section before it, not after.
python3 - "$desc/config.sh" "$root/build/config-hyprdev.sh" <<'PY'
import sys
cfg, ours = sys.argv[1:]
lines = open(cfg).read().rstrip("\n").split("\n")
assert lines[-1].strip() == "exit 0", "unexpected end of Fedora config.sh: " + lines[-1]
open(cfg, "w").write("\n".join(lines[:-1]) + "\n" + open(ours).read() + "\nexit 0\n")
PY
# boxbuild: give the build VM enough RAM/CPU (defaults are small)
sed -i 's/system boxbuild --box universal/system boxbuild --box universal --box-memory=${BOX_MEMORY:-10G} --box-smp-cpus=${BOX_CPUS:-4} --no-update-check/' "$desc/kiwi-build"

# 4. Local repo of our packages
# (inside the description dir: the isolated build VM only sees that tree)
mkdir -p "$desc/local-repo"
cp "$root"/out/rpms/*.noarch.rpm "$root"/out/rpms/*.x86_64.rpm "$desc/local-repo/"
# Hard links: instant, no extra disk space (same filesystem)
[[ ${CACHE:-1} == 1 && -d $cache/pkg-cache/repodata ]] && cp -al "$cache/pkg-cache" "$desc/pkg-cache"

# 5. Build — isolated: KIWI runs inside its own KVM VM (kiwi boxbuild), so the
#    container needs only /dev/kvm. No --privileged, no host /dev: image
#    scriptlets such as os-prober never see the host's disks.
docker build -q -t hyprdev-kiwi --build-arg FEDORA_VERSION="$FEDORA_VERSION" \
  -f "$root/build/Containerfile.kiwi" "$root/build" >/dev/null
mkdir -p "$cache/kiwi-boxes"
# RAM is backed by /dev/shm inside the container, so it must fit the box VM.
# mkfs.erofs (lzma, 1 MiB clusters) needs ~8 GB when packing the root fs.
# Retry: one dropped connection during the 2-3 GB download otherwise fails the whole build.
for attempt in 1 2 3; do
  echo "=== KIWI build attempt $attempt"
  rc=0
  docker run --rm --device /dev/kvm --shm-size=11g --dns 1.1.1.1 --dns 8.8.8.8 \
    -v "$root:/work" -v "$cache/kiwi-boxes:/root/.kiwi_boxes" -w /work/.cache/kiwi-desc hyprdev-kiwi bash -euo pipefail -c '
      trap "chown -R '"$(id -u):$(id -g)"' /work/out /work/.cache" EXIT
      createrepo_c -q local-repo
      rm -rf /work/out/kiwi-build
      ./kiwi-build --isolated --kiwi-file=HyprDev.kiwi --image-type=iso --image-profile=HyprDev-Live \
        --output-dir=/work/out/kiwi
      find /work/out/kiwi-build -maxdepth 1 -name "*.iso" -exec mv {} /work/out/iso/ \;
      # Embed the checksum the default "Test this media & start" entry verifies
      # (KIWI would do this via tagmedia, which the boxbuild VM lacks).
      cd /work/out/iso
      for iso in *.iso; do
        implantisomd5 --force "$iso"
        sha256sum "$iso" > "$iso.sha256"
        chmod 644 "$iso" "$iso.sha256"
      done
    ' 2>&1 | tee "$root/out/kiwi-attempt.log" || rc=$?
  [[ $rc == 0 ]] && break
  [[ $attempt == 3 ]] && { echo "ISO build failed after 3 attempts" >&2; exit 1; }
  cat "$root/out/kiwi-build/result.log" "$root/out/kiwi-attempt.log" 2>/dev/null \
    | grep -qaE "Curl error|Failed to download|Could not resolve|Failed to resolve|NameResolutionError|Timeout was reached" \
    || { echo "build failed (not a download error) - not retrying" >&2; exit 1; }
  echo "download error - retrying in 30s"; sleep 30
done
ls -lh "$root/out/iso"
