Name:           tushar-os-sddm-theme
Version:        0.1.0
Release:        2%{?dist}
Summary:        tushar-os SDDM login theme
License:        MIT
URL:            https://github.com/tushar/tushar-os
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       sddm qt6-qtdeclarative qt6-qt5compat
Requires:       tushar-os-branding orbitron-fonts rsms-inter-fonts symbols-nerd-fonts

%description
Catppuccin Mocha glass login screen for SDDM, matching the tushar-os desktop.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/sddm/themes/tushar-os
cp -a sddm-theme/. %{buildroot}%{_datadir}/sddm/themes/tushar-os/
install -Dm644 /dev/stdin %{buildroot}%{_sysconfdir}/sddm.conf.d/10-tushar-os.conf <<'CONF'
[Theme]
Current=tushar-os
CursorTheme=catppuccin-mocha-mauve-cursors

[General]
DisplayServer=wayland
CONF
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_datadir}/sddm/themes/tushar-os/
%config(noreplace) %{_sysconfdir}/sddm.conf.d/10-tushar-os.conf

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Drop layer-shell greeter environment (greeter crashed without the Qt plugin)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
