#!/usr/bin/env bash
# Serve out/rpms as a dnf repo so a tushar-os VM can test changes in seconds,
# without rebuilding the ISO.
#
#   packaging/build-rpms.sh tushar-os-desktop   # after editing dotfiles/
#   packaging/serve-repo.sh                     # leave running
#
# Once, inside the VM (QEMU user networking reaches the host at 10.0.2.2):
#   sudo tee /etc/yum.repos.d/tushar-os-dev.repo <<'EOF'
#   [tushar-os-dev]
#   name=tushar-os dev (host)
#   baseurl=http://10.0.2.2:8080/
#   gpgcheck=0
#   priority=1
#   metadata_expire=0
#   EOF
# Then, for each change:
#   sudo dnf upgrade --refresh 'tushar-os-*' && tushar-os-reset-config && hyprctl reload
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
port=${PORT:-8080}
docker run --rm -v "$root/out/rpms:/r" registry.fedoraproject.org/fedora:44 \
  bash -c "dnf -y -q install createrepo_c >/dev/null && createrepo_c -q /r && chown -R $(id -u):$(id -g) /r/repodata"
echo "Serving $root/out/rpms on http://0.0.0.0:$port (VM: http://10.0.2.2:$port)"
cd "$root/out/rpms" && exec python3 -m http.server "$port"
