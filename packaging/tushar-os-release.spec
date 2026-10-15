# Release identity for tushar-os, modelled on fedora-release-common.
# A Fedora Remix must not ship fedora-release / fedora-logos. generic-release
# can't be used alongside a custom identity (generic-release-common requires
# it), so this package provides the whole set of release files itself.
Name:           tushar-os-release
Version:        %{fedora}
Release:        2
Summary:        tushar-os release files (os-release, presets, dist macros)
License:        MIT
URL:            https://github.com/tushar/tushar-os
Source0:        tushar-os-branding-0.1.0.tar.gz
BuildArch:      noarch

Provides:       system-release
Provides:       system-release(%{version})
Provides:       system-release(releasever) = %{version}
Provides:       base-module(platform:f%{version})
Conflicts:      fedora-release-common generic-release generic-release-common
# Keep dependencies minimal: basesystem -> system-release is part of glibc's
# install-order chain, so anything pulling bash/coreutils here (e.g. logos)
# makes rpm install bash before glibc and every early scriptlet fails.
Requires:       fedora-repos(%{version})

%description
os-release identity for tushar-os, a Fedora %{version} based Hyprland remix.

%prep
%setup -q -n tushar-os-branding-0.1.0

%install
source ./config.env
sed -e "s/@DISTRO_NAME@/$DISTRO_NAME/g" -e "s/@DISTRO_PRETTY@/$DISTRO_PRETTY/g" \
    -e "s/@FEDORA_VERSION@/%{version}/g" branding/os-release.in > os-release
install -Dm644 os-release %{buildroot}%{_prefix}/lib/os-release
install -d %{buildroot}%{_sysconfdir}
ln -s ../usr/lib/os-release %{buildroot}%{_sysconfdir}/os-release

echo "$DISTRO_PRETTY release %{version}" > %{buildroot}%{_prefix}/lib/tushar-os-release
ln -s ../usr/lib/tushar-os-release %{buildroot}%{_sysconfdir}/tushar-os-release
ln -s tushar-os-release %{buildroot}%{_sysconfdir}/system-release
ln -s tushar-os-release %{buildroot}%{_sysconfdir}/redhat-release
ln -s tushar-os-release %{buildroot}%{_sysconfdir}/fedora-release
echo "cpe:/o:$DISTRO_NAME:$DISTRO_NAME:%{version}" > %{buildroot}%{_prefix}/lib/system-release-cpe
ln -s ../usr/lib/system-release-cpe %{buildroot}%{_sysconfdir}/system-release-cpe

printf '\\S\nKernel \\r on \\m (\\l)\n\n' > %{buildroot}%{_prefix}/lib/issue
cp %{buildroot}%{_prefix}/lib/issue %{buildroot}%{_prefix}/lib/issue.net
ln -s ../usr/lib/issue %{buildroot}%{_sysconfdir}/issue
ln -s ../usr/lib/issue.net %{buildroot}%{_sysconfdir}/issue.net
install -d %{buildroot}%{_sysconfdir}/issue.d

# Fedora's dist macros, presets and dnf defaults (from the build root's
# fedora-release-common, so they track the Fedora release exactly)
install -Dm644 %{_rpmmacrodir}/macros.dist %{buildroot}%{_rpmmacrodir}/macros.dist
install -d %{buildroot}%{_presetdir} %{buildroot}%{_userpresetdir}
install -m644 %{_presetdir}/90-default.preset %{_presetdir}/99-default-disable.preset %{buildroot}%{_presetdir}/
install -m644 %{_userpresetdir}/*.preset %{buildroot}%{_userpresetdir}/
echo "enable sddm.service" > %{buildroot}%{_presetdir}/85-display-manager.preset
install -Dm644 %{_datadir}/dnf5/libdnf.conf.d/20-fedora-defaults.conf \
    %{buildroot}%{_datadir}/dnf5/libdnf.conf.d/20-fedora-defaults.conf
install -Dm644 LICENSE %{buildroot}%{_licensedir}/%{name}/LICENSE

%files
%license %{_licensedir}/%{name}/LICENSE
%{_prefix}/lib/os-release
%{_prefix}/lib/tushar-os-release
%{_prefix}/lib/system-release-cpe
%{_prefix}/lib/issue
%{_prefix}/lib/issue.net
%{_sysconfdir}/os-release
%{_sysconfdir}/tushar-os-release
%{_sysconfdir}/system-release
%{_sysconfdir}/redhat-release
%{_sysconfdir}/fedora-release
%{_sysconfdir}/system-release-cpe
%config(noreplace) %{_sysconfdir}/issue
%config(noreplace) %{_sysconfdir}/issue.net
%dir %{_sysconfdir}/issue.d
%{_rpmmacrodir}/macros.dist
%{_presetdir}/*.preset
%{_userpresetdir}/*.preset
%{_datadir}/dnf5/libdnf.conf.d/20-fedora-defaults.conf

%changelog
* Thu Oct 15 2026 Tushar Chavan <deepak@silverferndigital.com> - 44-2
- Drop generic-logos dependency (broke glibc install ordering)

* Thu Oct 15 2026 Tushar Chavan <tusharchavan166@gmail.com> - 44-1
- Self-contained release package (replaces generic-release)
