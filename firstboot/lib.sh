# Shared helpers for tushar-os-welcome modules. Sourced, not executed.
# shellcheck shell=bash
TOS_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/tushar-os"
TOS_LOG="$TOS_STATE/welcome.log"
mkdir -p "$TOS_STATE"
export FEDORA; FEDORA=$(rpm -E %fedora)

log()  { printf '[%s] %s\n' "$(date +%T)" "$*" | tee -a "$TOS_LOG"; }
step() { if command -v gum >/dev/null; then gum style --foreground 212 --bold "▸ $*"; else echo "▸ $*"; fi; log "$*"; }
warn() { if command -v gum >/dev/null; then gum style --foreground 210 "! $*"; else echo "! $*"; fi; log "WARN $*"; }
SUDO=sudo; [[ $EUID -eq 0 ]] && SUDO=

dnf_install() { $SUDO dnf -y install "$@" 2>&1 | tee -a "$TOS_LOG" | grep -E '^(Installing|Upgrading|Nothing|Package .* already)' || true; }
have_rpm()    { rpm -q "$1" >/dev/null 2>&1; }

# add_repo <id> <name> <baseurl> <gpgkey>
add_repo() {
  local f="/etc/yum.repos.d/$1.repo"
  [[ -f $f ]] && return 0
  $SUDO tee "$f" >/dev/null <<REPO
[$1]
name=$2
baseurl=$3
enabled=1
gpgcheck=1
gpgkey=$4
REPO
  log "added repo $1"
}

flathub() {
  command -v flatpak >/dev/null || dnf_install flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>&1 | tee -a "$TOS_LOG"
}
flatpak_install() { flathub; flatpak install -y --noninteractive flathub "$@" 2>&1 | tee -a "$TOS_LOG" | tail -2; }
