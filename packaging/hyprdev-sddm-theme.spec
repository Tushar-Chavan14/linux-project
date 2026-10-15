Name:           hyprdev-sddm-theme
Version:        0.1.0
Release:        2%{?dist}
Summary:        hyprdev SDDM login theme
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       sddm qt6-qtdeclarative qt6-qt5compat
Requires:       hyprdev-branding orbitron-fonts rsms-inter-fonts symbols-nerd-fonts

%description
Catppuccin Mocha glass login screen for SDDM, matching the hyprdev desktop.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/sddm/themes/hyprdev
cp -a sddm-theme/. %{buildroot}%{_datadir}/sddm/themes/hyprdev/
install -Dm644 /dev/stdin %{buildroot}%{_sysconfdir}/sddm.conf.d/10-hyprdev.conf <<'CONF'
[Theme]
Current=hyprdev
CursorTheme=catppuccin-mocha-mauve-cursors

[General]
DisplayServer=wayland
CONF
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_datadir}/sddm/themes/hyprdev/
%config(noreplace) %{_sysconfdir}/sddm.conf.d/10-hyprdev.conf

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Drop layer-shell greeter environment (greeter crashed without the Qt plugin)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
