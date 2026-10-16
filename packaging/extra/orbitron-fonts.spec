Name:           orbitron-fonts
Version:        2.001
Release:        2%{?dist}
Summary:        Orbitron geometric display font (clock / widgets)
License:        OFL-1.1
URL:            https://github.com/google/fonts/tree/main/ofl/orbitron
# "#/" renames the download: COPR dist-git cannot store the %5B..%5D name
Source0:        https://github.com/google/fonts/raw/main/ofl/orbitron/Orbitron%5Bwght%5D.ttf#/Orbitron-Variable.ttf
Source1:        https://github.com/google/fonts/raw/main/ofl/orbitron/OFL.txt
BuildArch:      noarch
BuildRequires:  fontpackages-devel

%description
Orbitron is a geometric sans-serif display typeface. hyprdev uses it as the
freely redistributable stand-in for Nasalization in the clock widgets.

%prep

%install
install -Dm644 %{SOURCE0} %{buildroot}%{_fontdir}/Orbitron-Variable.ttf
install -Dm644 %{SOURCE1} %{buildroot}%{_licensedir}/%{name}/OFL.txt

%files
%license %{_licensedir}/%{name}/OFL.txt
%{_fontdir}/

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 2.001-2
- Rename Source0 to a plain file name (COPR dist-git 404)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 2.001-1
- Initial package for hyprdev
