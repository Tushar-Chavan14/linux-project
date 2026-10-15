%global fontname symbols-nerd-font

Name:           symbols-nerd-fonts
Version:        3.5.1
Release:        1%{?dist}
Summary:        Nerd Fonts symbols-only font (icons for bars and prompts)
License:        MIT
URL:            https://github.com/ryanoasis/nerd-fonts
Source0:        %{url}/releases/download/v%{version}/NerdFontsSymbolsOnly.tar.xz
BuildArch:      noarch
BuildRequires:  fontpackages-devel

%description
Symbols Nerd Font: Powerline, Font Awesome, Material Design and other icon
glyphs without any text glyphs, used as a fallback font.

%prep
%setup -q -c

%install
install -d %{buildroot}%{_fontdir}
install -m644 *.ttf %{buildroot}%{_fontdir}/
install -Dm644 10-nerd-font-symbols.conf %{buildroot}%{_fontconfig_templatedir}/10-nerd-font-symbols.conf 2>/dev/null || :

%files
%license LICENSE
%{_fontdir}/
%{_fontconfig_templatedir}/*

%changelog
* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 3.5.1-1
- Initial package for hyprdev
