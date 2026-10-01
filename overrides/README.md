# Overrides

Prefer overrides over source patches when KDE provides a stable override path.

Suggested subdirectories:

- `metadata/`: System Settings/KCM metadata owned by this component
- `translations/`: Ro-ASD specific downstream strings when packaging strategy permits
- `qml/`: narrowly scoped runtime QML overrides

Do not duplicate generic Ro-Theme or branding assets here.
