# Runtime integration — independent shell, 0.2.0

This replaces the wrapper audit at main `7f12bac`. The old wrapper, interposition
library, mirrored KDE QRC paths, theme imports and copied categories/translations
are removed, including from SRPM sources.

| Function | Activation |
| --- | --- |
| Ro sidebar/accordion/cards/search | src/qml/Main.qml embedded in the ELF, org.ro.systemsettings |
| Module title/actions | src/qml/ModuleHeader.qml in a second QQuickWidget |
| KCM discovery | KPluginMetaData, metadata-only, no KCModuleData constructors |
| QML/QtWidgets KCM content | public KCModuleLoader::loadModule and KCModule::widget |
| KCM subpages/tabs | supplied by KCMUtils/KCM, no replacement of internal layouts |
| Categories | installed KDE metadata, no downstream global override |
| Apply/Reset/Defaults | real save/load/defaults and change state, protected navigation |
| Authorization | KAuthorized policy and KAuth authorize-only before declared privileged save |
| TR/EN shell | original literal shell texts selected using QLocale |
| Stock fallback | explicit /usr/bin/systemsettings launch |

Every activation is source/testable, but functional claims still require the
recorded tests in [INDEPENDENT-SHELL.md](INDEPENDENT-SHELL.md). In particular,
window survival is not visual or Polkit acceptance. No general theme/branding
changes are made. KDE resources are not replaced.

KCM cross-module links through KDE KCMLauncher still explicitly launch
kcmshell6/stock System Settings. This public API has no host callback in 6.31;
all-links-in-Ro integration remains BLOCKED. No private interception is used.
