# tushar-os fish config. Personal additions: ~/.config/fish/conf.d/*.fish
set -g fish_greeting
if status is-interactive
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source
    command -q mise; and mise activate fish | source
    command -q fzf; and fzf --fish | source

    command -q eza; and alias ls 'eza --icons --group-directories-first'
    command -q eza; and alias ll 'eza -la --icons --git --group-directories-first'
    command -q bat; and alias cat 'bat --paging=never'
    alias y yazi
    alias lg lazygit
end

# Bun installs land here.
fish_add_path -g ~/.bun/bin ~/.local/bin
