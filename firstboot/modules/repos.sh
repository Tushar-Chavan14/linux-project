# Third-party repositories (each added only when a module needs it).
# shellcheck shell=bash
module_rpmfusion() {
  have_rpm rpmfusion-nonfree-release && return 0
  step "Enabling RPM Fusion (free + nonfree)"
  dnf_install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$FEDORA.noarch.rpm" \
              "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$FEDORA.noarch.rpm"
  # Full codecs (replaces the limited Fedora ffmpeg)
  $SUDO dnf -y swap ffmpeg-free ffmpeg --allowerasing >>"$TOS_LOG" 2>&1 || true
}
repo_chrome()  { add_repo google-chrome "Google Chrome" "https://dl.google.com/linux/chrome/rpm/stable/x86_64" "https://dl.google.com/linux/linux_signing_key.pub"; }
repo_vscode()  { add_repo vscode "Visual Studio Code" "https://packages.microsoft.com/yumrepos/vscode" "https://packages.microsoft.com/keys/microsoft.asc"; }
repo_claude()  { add_repo claude-code "Claude Code" "https://downloads.claude.ai/claude-code/rpm/stable" "https://downloads.claude.ai/keys/claude-code.asc"; }
repo_mise()    { [[ -f /etc/yum.repos.d/mise.repo ]] || $SUDO dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo >>"$TOS_LOG" 2>&1; }
repo_docker()  { [[ -f /etc/yum.repos.d/docker-ce.repo ]] || $SUDO dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo >>"$TOS_LOG" 2>&1; }
repo_pgadmin() { add_repo pgadmin4 "pgAdmin 4" "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/fedora/fedora-\$releasever-\$basearch" "https://www.pgadmin.org/static/packages_pgadmin_org.pub"; }
repo_mysql() {
  add_repo mysql84-community "MySQL 8.4 Community" "https://repo.mysql.com/yum/mysql-8.4-community/fc/\$releasever/\$basearch" "https://repo.mysql.com/RPM-GPG-KEY-mysql-2025"
  add_repo mysql-tools-community "MySQL Tools Community" "https://repo.mysql.com/yum/mysql-tools-community/fc/\$releasever/\$basearch" "https://repo.mysql.com/RPM-GPG-KEY-mysql-2025"
}
repo_copr()    { [[ -n $(ls /etc/yum.repos.d/_copr*"${1/\//:}"*.repo 2>/dev/null) ]] || $SUDO dnf -y copr enable "$1" >>"$TOS_LOG" 2>&1; }
