# Not in Fedora 44 or any maintained COPR at time of writing.
%global goipath github.com/nwg-piotr/nwg-dock-hyprland
%global debug_package %{nil}

Name:           nwg-dock-hyprland
Version:        0.4.11
Release:        1%{?dist}
Summary:        GTK3-based dock for Hyprland
License:        MIT
URL:            https://%{goipath}
Source0:        %{url}/archive/v%{version}/%{name}-%{version}.tar.gz

BuildRequires:  golang >= 1.22
BuildRequires:  git-core
BuildRequires:  pkgconfig(gtk+-3.0)
BuildRequires:  pkgconfig(gtk-layer-shell-0)
BuildRequires:  pkgconfig(gobject-introspection-1.0)
BuildRequires:  pkgconfig(cairo-gobject)
Requires:       gtk-layer-shell
Requires:       hyprland

%description
Configurable, GTK3-based dock for the Hyprland Wayland compositor.

%prep
%autosetup -n %{name}-%{version}

%build
# COPR builders allow network access; vendored modules are fetched here.
export GOFLAGS="-buildmode=pie -trimpath -mod=mod"
go build -ldflags "-s -w" -o %{name} .

%install
install -Dm755 %{name} %{buildroot}%{_bindir}/%{name}
install -d %{buildroot}%{_datadir}/%{name}
cp -a config/* %{buildroot}%{_datadir}/%{name}/
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license LICENSE
%{_bindir}/%{name}
%{_datadir}/%{name}/

%changelog
* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 0.4.11-1
- Initial package for hyprdev
