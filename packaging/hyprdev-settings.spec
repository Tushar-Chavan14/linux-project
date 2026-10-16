Name:           hyprdev-settings
Version:        0.1.0
Release:        1%{?dist}
Summary:        HyprDev Settings: GUI for display, wallpaper, desktop and input settings
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  desktop-file-utils
Requires:       python3-gobject gtk4 libadwaita
Requires:       hyprland jq
# Pages hand off to these tools
Requires:       wdisplays nwg-look qt6ct network-manager-applet blueman pavucontrol system-config-printer

%description
Settings app for the HyprDev Hyprland desktop: display resolution, refresh rate
and scale, wallpaper, desktop widgets, gaps/blur/animations, keyboard layout,
pointer and touchpad, plus shortcuts to network, Bluetooth, sound and printers.

%prep
%setup -q

%install
install -Dm755 settings/hyprdev-settings %{buildroot}%{_bindir}/hyprdev-settings
desktop-file-install --dir=%{buildroot}%{_datadir}/applications settings/hyprdev-settings.desktop
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_bindir}/hyprdev-settings
%{_datadir}/applications/hyprdev-settings.desktop

%changelog
* Fri Oct 16 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
