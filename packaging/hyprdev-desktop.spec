Name:           hyprdev-desktop
Version:        0.1.0
Release:        5%{?dist}
Summary:        hyprdev Hyprland desktop: dotfiles, widgets and session
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
# Built by packaging/make-sources.sh from dotfiles/ and packaging/desktop/
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

# Compositor + shell
Requires:       hyprland hyprlock hypridle swaybg hyprpolkitagent
Requires:       xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
Requires:       waybar eww-git rofi rofimoji SwayNotificationCenter swayosd gtk3
Requires:       cliphist wl-clipboard grim slurp swappy brightnessctl playerctl
Requires:       pavucontrol blueman NetworkManager-tui bluez
# Apps
Requires:       kitty fish starship yazi nautilus fastfetch btop jq curl
# Look
Requires:       adw-gtk3-theme papirus-icon-theme kvantum qt6ct
Requires:       rsms-inter-fonts jetbrains-mono-fonts-all orbitron-fonts symbols-nerd-fonts
Requires:       catppuccin-cursors
Requires:       hyprdev-branding hyprdev-welcome hyprdev-settings

%description
Preconfigured Hyprland desktop for HyprDev: Waybar top bar and dock,
eww calendar/clock/info widgets, rofi launcher, swaync control centre and
Catppuccin Mocha theming. Defaults are installed to /etc/skel for new users;
existing users can run hyprdev-reset-config.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/hyprdev/skel/.config %{buildroot}%{_sysconfdir}/skel/.config
for d in dotfiles/*/; do
  cp -a "$d" %{buildroot}%{_datadir}/hyprdev/skel/.config/
done
install -m644 dotfiles/starship.toml %{buildroot}%{_datadir}/hyprdev/skel/.config/starship.toml
ln -s %{_datadir}/backgrounds/hyprdev/default.jpg %{buildroot}%{_datadir}/hyprdev/skel/.config/hypr/wallpaper
# /etc/skel gets the same tree (new accounts, incl. the one Anaconda creates)
cp -a %{buildroot}%{_datadir}/hyprdev/skel/. %{buildroot}%{_sysconfdir}/skel/
install -Dm755 packaging/desktop/hyprdev-reset-config %{buildroot}%{_bindir}/hyprdev-reset-config
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_bindir}/hyprdev-reset-config
%{_datadir}/hyprdev/skel/
%config(noreplace) %{_sysconfdir}/skel/.config/

%changelog
* Fri Oct 16 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-5
- Dock icons: Waybar image module wants path/tooltip lines, not JSON
- Emoji picker via rofimoji (rofi has no emoji mode built in)

* Fri Oct 16 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-4
- Waybar dock (replaces nwg-dock), swaybg wallpaper, desktop right-click menu,
  HyprDev Settings integration

* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-3
- hyprpaper 0.8 config syntax; SUPER+W wallpaper picker

* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Dock always visible (was auto-hide)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
