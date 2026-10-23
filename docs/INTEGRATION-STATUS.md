# Runtime integration audit — 2026-10-23

Reference: KDE systemsettings `v6.7.5`, commit
`d126c08d14a2a0f44a1758fd25e945ae099e34bb`, matching the inspected
Fedora `plasma-systemsettings-6.7.5-1.fc44.x86_64`. This is a compatibility
reference, not the unrecorded original import base of the existing QML.
No upstream source patch is added.

| Payload | Actual activation path | Status |
| --- | --- | --- |
| Category desktop metadata | `SettingsBase.cpp`, `QStandardPaths::AppDataLocation/categories`, `KFileUtils::findAllUniqueFiles` | Wrapper prepends private data root; category discovery has a supported lookup path. Resulting KCM tree still needs interactive acceptance. |
| Turkish MO catalogs | Private `locale/tr/LC_MESSAGES` under XDG data root | Installed and format checked; actual localized labels need interactive verification. |
| `tabs.qss` | Explicit Qt `-stylesheet` argument | Passed by wrapper; affects Qt Widgets. Does not implement QML navigation or QML controls. |
| Custom shell Main/accordion/cards/Nav module | `overrides/qml/systemsettings` and `imports/org/kde/systemsettings/nav` | BLOCKED: installed but custom shell is not selected by the launcher. |
| KCM QML replacements | QRC aliases under `/kcm/...` | BLOCKED: neither registering RCC nor selecting these files occurs in the launcher. |
| `libsystemsettings_override.so` | Historical constructors, `dlsym(RTLD_NEXT)`, mangled Qt/Kirigami symbols, resource registration, URL redirection | Built and packaged, inactive. No preload, supported plugin entry point or `dlopen` caller in launcher/stock application. Link success is not activation evidence. |
| `overrides.rcc` | Requires explicit in-process registration or linkage | Built and packaged, inactive. Search paths cannot register an RCC. |

`app/SidebarMode.cpp` at the reference commit constructs a `QQmlComponent`
from the explicit URL `qrc:/qt/qml/org/kde/systemsettings/Main.qml`, then
passes its object through `QQuickWidget::setContent`. A filesystem import
path can supply imported modules, but does not redirect this explicit URL.
The private import root contains only the `nav` module; the stock root does
not import that custom module. The loader's historical local redirect also
looks for `qml/Main.qml`, while installation uses `qml/systemsettings/Main.qml`.
Fixing that dormant path alone would not make the loader a supported integration.

## Safe next implementation decision — BLOCKED

Keep supported process-local metadata/QSS integration. Do not advertise the
custom shell as functional, restore preload, or overwrite Fedora files.
For a custom shell, first resolve imported file provenance and the real
KCM model/context requirements. Then evaluate a narrow, version-pinned
systemsettings patch adding an explicit application-controlled shell resource
selection contract, with a separately named executable/package and stock fallback.
That requires a packaging/architecture decision and real Plasma acceptance;
it is not implemented or claimed here. Existing custom QML depends on model
and context properties and cannot safely be enabled by pointing a standalone
QML viewer at Main.qml.

Generic Breeze/QQC2/Kirigami controls belong to Ro-Theme; generic distribution
identity belongs to ro-asd-branding. Their existing dormant fragments are
recorded for licensing review only. No cross-repository behavior is enabled.

## Compatibility risks

Category names/parent identifiers and KCM availability can change between
Plasma versions. The current `>= 6.0` dependency is not a claim that custom
QML/private ABI is compatible with all those versions. Process-local data
paths are inherited by subprocesses of the Ro launcher; no login-wide
configuration is installed. A running stock System Settings instance may
receive a later Ro invocation through single-instance IPC, so manual tests
must close every existing instance before comparing launchers.
