Name:           ro-kde-systemsettings
Version:        0.1.0
Release:        1.roasd1%{?dist}
Summary:        Ro-ASD downstream customization layer for KDE Plasma System Settings
License:        GPL-2.0-or-later
URL:            https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings
Source0:        %{name}-%{version}.tar.gz

ExclusiveArch:  x86_64

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  gettext
BuildRequires:  kf6-rpm-macros
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel
BuildRequires:  qt6-qtquickcontrols2-devel

Requires:       plasma-systemsettings >= 6.0
Requires:       qt6-qtquickcontrols2
Requires:       kf6-kirigami

%description
Ro-KDE-SystemSettings is the downstream visual customization and layout layer
for KDE Plasma System Settings on Ro-ASD (Fedora 44). It provides a modern
hierarchical sidebar navigation, card layouts, pill-shaped tabs and controls,
and integrated Turkish translations without replacing or breaking standard
Fedora KDE Plasma System Settings modules.

%prep
%autosetup -p1

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

%files
%license LICENSE
%doc README.md
%{_bindir}/ro-systemsettings
%dir %{_libdir}/ro-kde-systemsettings
%{_libdir}/ro-kde-systemsettings/libsystemsettings_override.so
%{_libdir}/ro-kde-systemsettings/qml/
%dir %{_datadir}/ro-kde-systemsettings
%{_datadir}/ro-kde-systemsettings/overrides.rcc
%{_datadir}/ro-kde-systemsettings/tabs.qss
%{_datadir}/ro-kde-systemsettings/qml/
%{_datadir}/ro-kde-systemsettings/systemsettings/
%{_datadir}/ro-kde-systemsettings/locale/
%{_datadir}/ro-kde-systemsettings/applications/
%{_datadir}/applications/ro-systemsettings.desktop
/usr/lib/environment.d/50-ro-kde-systemsettings.conf
/etc/profile.d/ro-kde-systemsettings.sh

%changelog
* Thu Oct 22 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.1.0-1.roasd1
- Initial release candidate v0.1.0 for Fedora 44 Ro-ASD.
