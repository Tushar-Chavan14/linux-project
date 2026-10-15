# tushar-os

A Fedora-based Hyprland desktop for developers. It ships as a live ISO with the
Anaconda installer. The look is taken from
[desktop-portfolio-tushar](https://desktop-portfolio-tushar.vercel.app/):
Catppuccin Mocha colours, frosted glass, a minimal top bar and a bottom dock.
The desktop widgets are ports of the old conky calendar and clock.

The ISO contains only freely redistributable software. Proprietary apps and drivers
(Chrome, VSCode, Spotify, NVIDIA, Claude Code…) are installed from their vendors' own
repositories by **tushar-os-welcome**, which opens on first login.

## Layout

| Path | What |
|---|---|
| `config.env` | Distro name, Fedora version and the COPR list. Rename the distro here |
| `dotfiles/` | Everything under `~/.config`: hypr, waybar, eww, rofi, swaync, kitty, fish… |
| `firstboot/` | `tushar-os-welcome` (gum TUI) and its modules: gpu, repos, apps, devtools, databases |
| `branding/` | Wallpaper (`make-wallpaper.sh`), logo, os-release template, live-session hook |
| `sddm-theme/` | QML login theme |
| `packaging/` | RPM specs. `extra/` packages what Fedora 44 lacks (nwg-dock-hyprland, Orbitron, Nerd symbols, cursors) |
| `build/` | KIWI overlay (`TusharOS-Live` profile) and `build-iso.sh` |
| `tests/` | Lint container and the QEMU boot test (`boot-iso.sh`) |

## Build

All you need on the host is Docker. Everything else runs in Fedora containers.

```bash
packaging/build-rpms.sh      # -> out/rpms/
build/build-iso.sh           # -> out/iso/*.iso      (KIWI boxbuild VM, needs /dev/kvm)
```

### Fast iteration (don't rebuild the ISO for desktop tweaks)

| Goal | Command | Time |
|---|---|---|
| Change dotfiles / welcome app / theme | `packaging/build-rpms.sh tushar-os-desktop` + `dnf upgrade` in the VM (below) | seconds |
| Test ISO | `FAST=1 build/build-iso.sh` (lz4 instead of lzma) | ~6 min with the cache |
| Release ISO | `build/build-iso.sh`, or tag `v*` and let GitHub build it | ~10 min with the cache |

```bash
build/cache-packages.sh                   # once, after a successful build: ~2.5 GB of RPMs into .cache/pkg-cache
tests/run-vm.sh out/iso/*.iso             # install tushar-os into a persistent VM (VNC: localhost:5901)
tests/run-vm.sh                           # later: boot the installed VM
packaging/serve-repo.sh                   # serve out/rpms to the VM; see the script header for the one-time repo file
```

Boot the ISO under KVM (inside a container) and take screenshots into `out/boot/`:

```bash
tests/boot-iso.sh out/iso/*.iso 300 30
```

For publishing to GitHub/COPR and keeping installs updated, see [docs/RELEASING.md](docs/RELEASING.md).

## Where packages come from (Fedora 44)

| Source | Packages |
|---|---|
| Fedora | waybar, rofi 2.x, SwayNotificationCenter, kitty, fish, sddm, gum, fonts, Papirus… |
| COPR `sdegler/hyprland` | hyprland, hyprlock, hypridle, hyprpaper, hyprpolkitagent, xdph, eww-git |
| COPR `atim/starship`, `atim/lazygit`, `lihaohong/yazi`, `erikreider/swayosd` | as named |
| Our COPR (`packaging/`) | tushar-os-*, nwg-dock-hyprland, orbitron-fonts, symbols-nerd-fonts, catppuccin-cursors |
| First boot (vendor repos) | RPM Fusion + NVIDIA akmod, Google Chrome, VSCode, Claude Code (official Anthropic RPM repo), mise, Docker CE, pgAdmin 4, MySQL 8.4 + Workbench, Flathub (Spotify, DBeaver, Bruno) |

Claude Desktop has no official Fedora package (Anthropic publishes a .deb only), so the
welcome app offers an **unofficial** community RPM as an explicit opt-in.

## Keys

| Keys | Action |
|---|---|
| `SUPER+Space` | App launcher (rofi) |
| `SUPER+Return` | Terminal (kitty) |
| `SUPER+E` / `SUPER+SHIFT+E` | Nautilus / Yazi |
| `SUPER+N` | Control centre (Wi-Fi, Bluetooth, volume, power) |
| `SUPER+V` | Clipboard history |
| `SUPER+W` | Wallpaper picker (system + `~/Pictures/Wallpapers`) |
| `SUPER+Esc` | Power menu |
| `SUPER+/` | Every keybind |

Personal overrides go in `~/.config/hypr/user.conf`. The weather city goes in
`~/.config/tushar-os/location`. `tushar-os-reset-config` restores the defaults and
backs up anything you changed.
