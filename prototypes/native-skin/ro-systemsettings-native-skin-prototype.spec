# ISOLATED DEVELOPMENT ONLY. Not used by the production/release workflow.
Name: ro-systemsettings-native-skin-prototype
Version: 0.0.1
Release: 1%{?dist}
Summary: Development prototype of a visual layer for original KDE System Settings
License: GPL-3.0-only
URL: https://github.com/Project-Ro-ASD/Ro-KDE-SystemSettings
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: gettext
Requires: plasma-systemsettings >= 6.6.4

%description
Isolated development resources only. Requires the experimental opt-in QML
selector patch in original KDE System Settings for activation. Does not ship
an executable, service, global environment override or KCM implementation.

%prep
%autosetup

%build
msgfmt --check-format tr.po -o ro-systemsettings-native-skin.mo

%install
install -Dm644 Main.qml %{buildroot}%{_datadir}/ro-kde-systemsettings/native/Main.qml
install -Dm644 ro-systemsettings-native-skin.mo %{buildroot}%{_datadir}/locale/tr/LC_MESSAGES/ro-systemsettings-native-skin.mo

%files
%license LICENSE
%{_datadir}/ro-kde-systemsettings/native/Main.qml
%lang(tr) %{_datadir}/locale/tr/LC_MESSAGES/ro-systemsettings-native-skin.mo
