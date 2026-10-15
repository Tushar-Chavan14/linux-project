Name:           hyprdev-branding
Version:        0.1.0
Release:        2%{?dist}
Summary:        hyprdev wallpapers, logos and release identity
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

%description
Wallpapers, logos and fastfetch art for hyprdev.

# ---------------------------------------------------------------------------
%package -n hyprdev-live
Summary:        Live-ISO session setup for hyprdev (autologin into Hyprland)
Requires:       livesys-scripts sddm hyprdev-desktop libnotify

%description -n hyprdev-live
livesys hook that logs the live user into Hyprland and surfaces the installer.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/backgrounds/hyprdev
install -m644 branding/wallpapers/*.jpg branding/wallpapers/*.png branding/wallpapers/CREDITS \
    %{buildroot}%{_datadir}/backgrounds/hyprdev/
ln -s purpled-night.jpg %{buildroot}%{_datadir}/backgrounds/hyprdev/default.jpg
install -Dm644 branding/logo.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/hyprdev-logo.svg
install -Dm644 branding/logo.txt %{buildroot}%{_datadir}/hyprdev/logo.txt
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE
install -Dm755 branding/live/livesys-hyprland %{buildroot}%{_libexecdir}/livesys/sessions.d/livesys-hyprland

%files
%license %{_licensedir}/%{name}/LICENSE
%{_datadir}/backgrounds/hyprdev/
%{_datadir}/icons/hicolor/scalable/apps/hyprdev-logo.svg
%{_datadir}/hyprdev/logo.txt

%files -n hyprdev-live
%{_libexecdir}/livesys/sessions.d/livesys-hyprland

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 0.1.0-2
- Portfolio wallpapers; default is purpled-night

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
