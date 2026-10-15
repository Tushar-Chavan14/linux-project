# Developer tooling.
# shellcheck shell=bash
module_cli() {
  step "CLI essentials"
  repo_copr atim/lazygit
  dnf_install git gh neovim lazygit ripgrep fd-find fzf bat eza zoxide btop jq yq tldr make gcc
}

module_runtimes() {
  step "mise + Node LTS, Bun, Go, Python"
  repo_mise; dnf_install mise
  mise use -g node@lts bun@latest go@latest python@latest 2>&1 | tee -a "$TOS_LOG" | tail -4
}

module_containers() {
  step "Podman, podman-compose, Distrobox"
  dnf_install podman podman-compose distrobox
  if gum confirm "Also install Docker CE (alongside Podman)?" --default=false; then
    repo_docker; dnf_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    $SUDO systemctl enable --now docker; $SUDO usermod -aG docker "$USER"
    warn "Log out and back in to use docker without sudo."
  fi
}
