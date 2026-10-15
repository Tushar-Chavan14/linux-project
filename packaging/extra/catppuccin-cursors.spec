Name:           catppuccin-cursors
Version:        2.0.0
Release:        1%{?dist}
Summary:        Catppuccin Mocha Mauve cursor theme
License:        GPL-2.0-only
URL:            https://github.com/catppuccin/cursors
Source0:        %{url}/releases/download/v%{version}/catppuccin-mocha-mauve-cursors.zip
Source1:        https://raw.githubusercontent.com/catppuccin/cursors/v%{version}/LICENSE
BuildArch:      noarch
BuildRequires:  unzip

%description
Soothing pastel mouse cursors (Mocha flavour, Mauve accent), with both
XCursor and hyprcursor formats.

%prep
%setup -q -c

%install
install -d %{buildroot}%{_datadir}/icons
cp -a catppuccin-mocha-mauve-cursors %{buildroot}%{_datadir}/icons/
install -Dm644 %{SOURCE1} %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_datadir}/icons/catppuccin-mocha-mauve-cursors/

%changelog
* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 2.0.0-1
- Initial package for tushar-os
