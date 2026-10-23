# Fedora 44 x86_64 packaging — 0.2.0

Build in a disposable Fedora 44 environment, not the development user session.
The spec BuildRequires public KF6 KCMUtils/CoreAddons/Config/Auth/I18n development
packages, plasma-workspace-libs for real fonts/colors smoke, and Qt6 base/declarative/quickcontrols2. QtTest builds source-only KCM
fixtures and behavior tests under `%check`. Runtime ELF dependencies are generated
by RPM. Kirigami/QuickControls and stock plasma-systemsettings provide installed
KCM dependencies/categories and the explicit fallback; no exact Plasma version pin.

Installed files: `/usr/bin/ro-systemsettings` (ELF),
`/usr/share/applications/ro-systemsettings.desktop`, GPL LICENSE and docs.
QML is embedded under the Ro namespace. No Fedora-owned file is replaced;
no Conflicts/Obsoletes, triggers, autostart or environment files are installed.

`bash tests/test-build-rpm.sh` creates a tracked-source archive and builds RPM/SRPM.
Stage new files before this test; missing/deleted tracked paths are filtered out.
`tests/test-bundle.sh` verifies RPM/SRPM association, rpmlint, manifest and checksums.
`tests/run-fedora44.sh "" .work/previous.rpm` tests clean install, runtime, actual
0.1.0 upgrade/removal and stock integrity. Upgrading removes old wrapper payload,
libsystemsettings_override, QML/RCC/QSS, copied catalogs and old global files through
normal RPM ownership. A logout/login remains necessary to clear environment values
already inherited from the historical 0.1.0 package. Remove leaves stock installed.

Source contract/attestation gates remain. No release/tag, production signing or
Ro-Repo registration is authorized by this implementation. Physical G14 tests
require an operator-approved disposable/recoverable installation.
