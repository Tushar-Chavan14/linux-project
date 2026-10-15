Name:           tushar-os-welcome
Version:        0.1.0
Release:        1%{?dist}
Summary:        tushar-os first-boot setup (drivers, apps, developer tools)
License:        MIT
URL:            https://github.com/Tushar-Chavan14/linux-project
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       gum jq curl pciutils mokutil flatpak dnf5-plugins kitty

%description
Interactive first-boot setup for tushar-os. Installs GPU drivers, Chrome,
VSCode, Spotify, Claude Code, runtimes, containers and databases from their
vendors' repositories, keeping the ISO itself free of proprietary software.

%prep
%setup -q

%install
install -d %{buildroot}%{_datadir}/tushar-os/welcome/modules
install -m644 firstboot/lib.sh %{buildroot}%{_datadir}/tushar-os/welcome/
install -m644 firstboot/modules/*.sh %{buildroot}%{_datadir}/tushar-os/welcome/modules/
install -Dm755 firstboot/tushar-os-welcome %{buildroot}%{_bindir}/tushar-os-welcome
install -Dm644 firstboot/tushar-os-welcome.desktop %{buildroot}%{_datadir}/applications/tushar-os-welcome.desktop
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_bindir}/tushar-os-welcome
%{_datadir}/tushar-os/welcome/
%{_datadir}/applications/tushar-os-welcome.desktop

%changelog
* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.1.0-1
- Initial release
