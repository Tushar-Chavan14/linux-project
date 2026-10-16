#!/usr/bin/env bash
# Build every spec under packaging/ in a clean Fedora container -> out/rpms/
# Usage: packaging/build-rpms.sh [spec-name-filter]
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=../config.env
source "$root/config.env"
mkdir -p "$root/out/rpms" "$root/.cache/rpm-sources" "$root/.cache/go" "$root/.cache/go-build"
"$root/packaging/make-sources.sh" >/dev/null
docker build -q --network host -t hyprdev-rpmbuild --build-arg FEDORA_VERSION="$FEDORA_VERSION" \
  -f "$root/build/Containerfile.rpmbuild" "$root/build" >/dev/null
docker run --rm --dns 1.1.1.1 --dns 8.8.8.8 \
  -v "$root:/src:ro" -v "$root/out/rpms:/out" -v "$root/.cache/rpm-sources:/sources" \
  -v "$root/.cache/go:/root/go" -v "$root/.cache/go-build:/root/.cache/go-build" \
  hyprdev-rpmbuild bash -uo pipefail -c '
    shopt -s globstar nullglob
    failed=()
    for spec in /src/packaging/**/*.spec; do
      [[ -n "${1:-}" && "$spec" != *"$1"* ]] && continue
      name=$(basename "$spec" .spec); echo "=== $name"
      cp "$spec" ~/rpmbuild/SPECS/
      cp /sources/* ~/rpmbuild/SOURCES/ 2>/dev/null || true
      (cd ~/rpmbuild/SOURCES && spectool -g ~/rpmbuild/SPECS/$name.spec >/dev/null 2>&1) || true
      dnf -y -q builddep ~/rpmbuild/SPECS/$name.spec >/tmp/builddep.log 2>&1 || { tail -5 /tmp/builddep.log; failed+=("$name"); continue; }
      if rpmbuild -ba --quiet ~/rpmbuild/SPECS/$name.spec >/tmp/build.log 2>&1; then echo "    ok"
      else tail -25 /tmp/build.log; failed+=("$name"); fi
    done
    cp ~/rpmbuild/RPMS/*/*.rpm ~/rpmbuild/SRPMS/*.rpm /out/ 2>/dev/null
    rpmlint -r /dev/null /out/*.rpm 2>&1 | grep -E " E: " | head -20
    ((${#failed[@]} == 0)) || { echo "FAILED: ${failed[*]}"; exit 1; }
  ' _ "${1:-}"
ls -1 "$root/out/rpms"
