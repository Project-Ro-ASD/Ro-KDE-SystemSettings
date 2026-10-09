# Overrides

Prefer overrides over source patches when KDE provides a stable override path.

Suggested subdirectories:

- `metadata/`: System Settings/KCM metadata and category layout `.desktop` files owned by this component (`metadata/categories/`)
- `translations/`: Ro-ASD specific downstream strings and `.po` translations (`kcm_landingpage.po`, `systemsettings.po`, `kcmqtquicksettings.po`, `kcm_nighttime.po`)
- `theme/`: System Settings specific stylesheet overrides (`tabs.qss`)
- `qml/`: narrowly scoped runtime QML overrides

Do not duplicate generic Ro-Theme or branding assets here.

