%global debug_package %{nil}
Name:           ro-kde-systemsettings
Version:        0.2.0
Release:        1.roasd1%{?dist}
Summary:        Ro-ASD downstream customization layer for KDE Plasma System Settings
License:        GPL-3.0-or-later
URL:            https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings
Source0:        https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings/archive/refs/tags/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

ExclusiveArch:  x86_64

BuildRequires:  desktop-file-utils
BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  gettext
BuildRequires:  python3
BuildRequires:  dbus-daemon
BuildRequires:  kf6-rpm-macros
BuildRequires:  kf6-kcmutils-devel
BuildRequires:  kf6-kconfig-devel
BuildRequires:  kf6-kcoreaddons-devel
BuildRequires:  kf6-kauth-devel
BuildRequires:  kf6-ki18n-devel
BuildRequires:  qt6-qtbase-devel
BuildRequires:  qt6-qtdeclarative-devel
BuildRequires:  qt6-qtquickcontrols2-devel

Requires:       plasma-systemsettings
Requires:       qt6-qtquickcontrols2
Requires:       kf6-kirigami

%description
Ro System Settings is an independent application shell using public KDE
Frameworks KCM APIs. Its own QML navigation, search and category cards load
installed KDE configuration modules on demand. The Fedora System Settings
application and standard KDE authorization paths are preserved.

%prep
%autosetup -n Ro-KDE-SystemSettings-%{version} -p1

%build
%cmake -DCMAKE_BUILD_TYPE=Release
%cmake_build

%install
%cmake_install

%check
desktop-file-validate packaging/fedora/ro-systemsettings.desktop
QT_QPA_PLATFORM=offscreen %ctest

%files
%license LICENSE
%doc README.md docs/INDEPENDENT-SHELL.md docs/LICENSING.md
%{_bindir}/ro-systemsettings
%{_datadir}/applications/ro-systemsettings.desktop

%changelog
* Fri Oct 23 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.2.0-1.roasd1
- Replace wrapper and inactive overrides with an independent public-API KCM shell.

* Thu Oct 22 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.1.1-1.roasd1
- Prepare V2 producer checks and isolate integration to the Ro launcher.

* Thu Oct 22 2026 Ro-ASD Maintainers <maintainers@project-ro-asd.org> - 0.1.0-1.roasd1
- Initial release candidate v0.1.0 for Fedora 44 Ro-ASD.
