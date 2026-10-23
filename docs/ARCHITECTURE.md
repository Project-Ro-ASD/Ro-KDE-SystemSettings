# Independent Ro System Settings shell

The explicit independent-shell task supersedes the former wrapper-only architecture.
This repository owns only the System Settings application UI and its packaging.
Global themes belong to Ro-Theme, distribution identity to ro-asd-branding and
session defaults to ro-asd-defaults.

`ro-systemsettings` is a separate Qt Widgets executable. A QQuickWidget hosts the
original Ro QML navigation/catalog; a second hosts the module heading/actions.
The adjacent scroll area embeds `KCModule::widget()`. This supported widget bridge
allows both QML and legacy QtWidgets KCMs without reimplementing their settings.
KCMUtils' public loader wraps KQuickConfigModule and its internal page navigation.
Ro does not access that wrapper's private classes or a KCM's embedded QML resources.

All Ro QML is embedded under `/ro/org/ro/systemsettings`, URI
`org.ro.systemsettings`. Nothing occupies KDE QRC paths or global QML imports.
The installed payload consists of one ELF, one Ro desktop entry, and documentation/
license. No wrapper, loader hook, RCC sidecar, autostart, service or copied theme.

Discovery uses KPluginMetaData in the installed Plasma KCM namespaces and reads
installed `systemsettings/categories` metadata using KDesktopFile. It does not
instantiate KCModuleData or load module code to construct the catalog. Names,
descriptions and keywords come from KDE metadata; unknown categories go to Other.
Cycles and missing category parents cannot loop discovery. External application
launchers advertised as KCM entries are not embedded; stock fallback covers them.

Only the selected KCM is loaded. Navigation destroys the previous KCModule before
its widget and shared QQmlEngine. History contains plugin IDs, not resident pages.
Back/forward and selection use the same unsaved-change guard. Apply invokes save;
Reset invokes load; Defaults invokes defaults and remains subject to Apply. An
outstanding authorization prevents navigation/close/reset and repeated Apply.
KAuthorized policy is checked at discovery and load. If the module declares an
authorization action, KAuth AuthorizeOnlyMode must succeed before save is called;
the module retains responsibility for its actual privileged helper operation.
Instant-apply modules retain their upstream behavior; Reset cannot undo a change
already saved by such a module. No passwords are handled by Ro.

Ro registers no System Settings DBus service and uses its own application/desktop
identity. Each Ro invocation is an independent process. The fallback explicitly
starts stock System Settings, which may reuse its own stock instance. No Ro
navigation is forwarded to it. This choice avoids a private single-instance IPC
contract, at the cost of allowing multiple Ro windows.

No upstream source patch or metadata override is required. Upstream owners are
KDE frameworks/kcmutils (loading), kcoreaddons (metadata), kconfig (policy/category
metadata), kauth (authorization), and each KCM's provider. Systemsettings is a
behavior/reference source, not a linked or rebuilt application dependency.
See INDEPENDENT-SHELL.md for tested versions and acceptance limitations.

Some KCM cross-module links explicitly use KCMLauncher to start kcmshell6 or
stock System Settings. KCMUtils 6.31 exposes no host-routing callback. These
links retain upstream behavior and are an open full-integration acceptance
limit; Ro does not intercept the private singleton or child process commands.
See INDEPENDENT-SHELL.md for exact source evidence and the narrow upstream API
option. This does not affect Ro's own selection/search/history routing.
