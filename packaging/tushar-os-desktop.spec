Name:           tushar-os-desktop
Version:        0.1.0
Release:        3%{?dist}
Summary:        tushar-os Hyprland desktop: dotfiles, widgets and session
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
# Built by packaging/make-sources.sh from dotfiles/ and packaging/desktop/
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

# Compositor + shell
Requires:       hyprland hyprlock hypridle hyprpaper hyprpolkitagent
Requires:       xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
Requires:       waybar nwg-dock-hyprland eww-git rofi SwayNotificationCenter swayosd
Requires:       cliphist wl-clipboard grim slurp swappy brightnessctl playerctl
Requires:       pavucontrol blueman NetworkManager-tui bluez
# Apps
Requires:       kitty fish starship yazi nautilus fastfetch btop jq curl
# Look
Requires:       adw-gtk3-theme papirus-icon-theme kvantum qt6ct
Requires:       rsms-inter-fonts jetbrains-mono-fonts-all orbitron-fonts symbols-nerd-fonts
Requires:       catppuccin-cursors
Requires:       tushar-os-branding tushar-os-welcome

%description
Preconfigured Hyprland desktop for tushar-os: Waybar top bar, nwg-dock,
eww calendar/clock/info widgets, rofi launcher, swaync control centre and
Catppuccin Mocha theming. Defaults are installed to /etc/skel for new users;
existing users can run tushar-os-reset-config.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/tushar-os/skel/.config %{buildroot}%{_sysconfdir}/skel/.config
for d in dotfiles/*/; do
  cp -a "$d" %{buildroot}%{_datadir}/tushar-os/skel/.config/
done
install -m644 dotfiles/starship.toml %{buildroot}%{_datadir}/tushar-os/skel/.config/starship.toml
install -Dm644 dotfiles/nwg-dock-hyprland/pinned %{buildroot}%{_datadir}/tushar-os/skel/.cache/nwg-dock-pinned
rm %{buildroot}%{_datadir}/tushar-os/skel/.config/nwg-dock-hyprland/pinned
ln -s %{_datadir}/backgrounds/tushar-os/default.jpg %{buildroot}%{_datadir}/tushar-os/skel/.config/hypr/wallpaper
# /etc/skel gets the same tree (new accounts, incl. the one Anaconda creates)
cp -a %{buildroot}%{_datadir}/tushar-os/skel/. %{buildroot}%{_sysconfdir}/skel/
install -Dm755 packaging/desktop/tushar-os-reset-config %{buildroot}%{_bindir}/tushar-os-reset-config
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_bindir}/tushar-os-reset-config
%{_datadir}/tushar-os/skel/
%config(noreplace) %{_sysconfdir}/skel/.config/
%config(noreplace) %{_sysconfdir}/skel/.cache/

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-3
- hyprpaper 0.8 config syntax; SUPER+W wallpaper picker

* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Dock always visible (was auto-hide)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
