Name:           tushar-os-branding
Version:        0.1.0
Release:        2%{?dist}
Summary:        tushar-os wallpapers, logos and release identity
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

%description
Wallpapers, logos and fastfetch art for tushar-os.

# ---------------------------------------------------------------------------
%package -n tushar-os-live
Summary:        Live-ISO session setup for tushar-os (autologin into Hyprland)
Requires:       livesys-scripts sddm tushar-os-desktop libnotify

%description -n tushar-os-live
livesys hook that logs the live user into Hyprland and surfaces the installer.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/backgrounds/tushar-os
install -m644 branding/wallpapers/*.jpg branding/wallpapers/*.png branding/wallpapers/CREDITS \
    %{buildroot}%{_datadir}/backgrounds/tushar-os/
ln -s purpled-night.jpg %{buildroot}%{_datadir}/backgrounds/tushar-os/default.jpg
install -Dm644 branding/logo.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/tushar-os-logo.svg
install -Dm644 branding/logo.txt %{buildroot}%{_datadir}/tushar-os/logo.txt
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE
install -Dm755 branding/live/livesys-hyprland %{buildroot}%{_libexecdir}/livesys/sessions.d/livesys-hyprland

%files
%license %{_licensedir}/%{name}/LICENSE
%{_datadir}/backgrounds/tushar-os/
%{_datadir}/icons/hicolor/scalable/apps/tushar-os-logo.svg
%{_datadir}/tushar-os/logo.txt

%files -n tushar-os-live
%{_libexecdir}/livesys/sessions.d/livesys-hyprland

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Portfolio wallpapers; default is purpled-night

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
