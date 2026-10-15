#!/usr/bin/env bash
# Download every RPM the last ISO build installed into a local repo
# (.cache/pkg-cache). build-iso.sh then installs from it first, so a rebuild
# needs almost no network: ~2.5 GB once, then only packages that changed.
#   build/cache-packages.sh            # after a successful build-iso.sh
#   CACHE=0 build/build-iso.sh         # ignore the cache for one build
set -euo pipefail
export LC_ALL=C   # comm needs the same sort order on host and in the container
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../config.env
source "$root/config.env"
list=$(find "$root/out/kiwi-build" -maxdepth 1 -name '*.packages' | head -1)
[[ -f $list ]] || { echo "no out/kiwi-build/*.packages - run build/build-iso.sh first" >&2; exit 1; }
cache="$root/.cache/pkg-cache"; mkdir -p "$cache"

# KIWI .packages format: name|epoch|version|release|arch|...
awk -F'|' '$5 != "(none)" { print $1 "-" $3 "-" $4 "." $5 }' "$list" | sort -u > "$cache/wanted.txt"
echo "$(wc -l < "$cache/wanted.txt") packages in the last image"

copr_args=""
for c in "${COPRS[@]}"; do copr_args+=" $c"; done
docker run --rm --dns 1.1.1.1 --dns 8.8.8.8 \
  -v "$cache:/cache" -v "$root/out/rpms:/local:ro" \
  "registry.fedoraproject.org/fedora:$FEDORA_VERSION" bash -euo pipefail -c '
    export LC_ALL=C
    dnf -y -q install dnf-plugins-core createrepo_c >/dev/null
    for c in '"$copr_args"'; do dnf -y -q copr enable "$c" >/dev/null; done
    printf "[local]\nname=local\nbaseurl=file:///local\ngpgcheck=0\n" > /etc/yum.repos.d/local.repo
    cd /cache
    # Only fetch what is not cached yet
    have=$(ls -1 *.rpm 2>/dev/null | sed "s/\.rpm$//" | sort -u || true)
    comm -23 wanted.txt <(echo "$have") > missing.txt
    echo "$(wc -l < missing.txt) to download"
    if [[ -s missing.txt ]]; then
      xargs -a missing.txt -n 200 dnf -q download --skip-unavailable --destdir /cache
    fi
    # Drop RPMs no longer part of the image
    comm -13 wanted.txt <(ls -1 *.rpm | sed "s/\.rpm$//" | sort -u) | sed "s/$/.rpm/" | xargs -r rm -f
    createrepo_c -q --update /cache
    rm -f missing.txt
    chown -R '"$(id -u):$(id -g)"' /cache
  '
echo "cache: $(find "$cache" -name '*.rpm' | wc -l) RPMs, $(du -sh "$cache" | cut -f1) in $cache"
