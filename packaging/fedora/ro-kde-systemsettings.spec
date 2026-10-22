%global debug_package %{nil}
Name:           ro-kde-systemsettings
Version:        0.1.1
Release:        1.roasd1%{?dist}
Summary:        Ro-ASD downstream customization layer for KDE Plasma System Settings
License:        GPL-3.0-only AND GPL-3.0-or-later AND GPL-2.0-or-later AND LGPL-2.0-only AND LGPL-2.0-or-later AND LGPL-2.1-only AND LGPL-3.0-only
URL:            https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings
Source0:        https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

ExclusiveArch:  x86_64

BuildRequires:  desktop-file-utils
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
%autosetup -n Ro-KDE-SystemSettings-%{version} -p1

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

%check
desktop-file-validate packaging/fedora/ro-systemsettings.desktop
for catalog in overrides/translations/*.po; do
    msgfmt --check-format -o /dev/null "$catalog"
done

%files
%license LICENSE LICENSES/
%doc docs/LICENSING.md
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
%lang(tr) %{_datadir}/ro-kde-systemsettings/locale/
%{_datadir}/ro-kde-systemsettings/applications/
%{_datadir}/applications/ro-systemsettings.desktop

%changelog
* Thu Oct 22 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.1.1-1.roasd1
- Prepare V2 producer checks and isolate integration to the Ro launcher.

* Thu Oct 22 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.1.0-1.roasd1
- Initial release candidate v0.1.0 for Fedora 44 Ro-ASD.
