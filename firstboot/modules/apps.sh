# Core desktop apps.
# shellcheck shell=bash
module_apps() {
  step "Google Chrome";      repo_chrome; dnf_install google-chrome-stable
  step "Visual Studio Code"; repo_vscode; dnf_install code
  step "Spotify (Flathub)";  flatpak_install com.spotify.Client
  step "Claude Code (official Anthropic repo)"; repo_claude; dnf_install claude-code
  step "KDE Connect";        dnf_install kde-connect
  $SUDO firewall-cmd --permanent --add-service=kdeconnect >>"$TOS_LOG" 2>&1 && $SUDO firewall-cmd --reload >>"$TOS_LOG" 2>&1 || true
  # VSCode: Catppuccin + font defaults on first run only
  local vs="$HOME/.config/Code/User/settings.json"
  if [[ ! -f $vs ]]; then
    mkdir -p "$(dirname "$vs")"
    cat > "$vs" <<'JSON'
{
  "workbench.colorTheme": "Catppuccin Mocha",
  "workbench.iconTheme": "catppuccin-mocha",
  "editor.fontFamily": "'JetBrains Mono', monospace",
  "editor.fontLigatures": true,
  "terminal.integrated.defaultProfile.linux": "fish",
  "window.titleBarStyle": "custom"
}
JSON
    code --install-extension Catppuccin.catppuccin-vsc --install-extension Catppuccin.catppuccin-vsc-icons >>"$TOS_LOG" 2>&1 || true
  fi
}

# Claude Desktop has no official Fedora build (Anthropic ships .deb only).
module_claude_desktop() {
  warn "Claude Desktop is not officially packaged for Fedora."
  if gum confirm "Install the UNOFFICIAL community RPM (github.com/aaddrick/claude-desktop-debian)?" --default=false; then
    local url
    url=$(curl -fsSL https://api.github.com/repos/aaddrick/claude-desktop-debian/releases/latest \
          | jq -r '.assets[] | select(.name | test("x86_64\\.rpm$")) | .browser_download_url' | head -1)
    [[ -n $url ]] && dnf_install "$url" || warn "Could not find a community RPM; see https://claude.ai/download"
  else
    xdg-open https://claude.ai/download >/dev/null 2>&1 &
  fi
}
