# Architecture

## Purpose

Ro-KDE-SystemSettings is the Ro-ASD downstream customization layer for KDE Plasma System Settings.
It is not a replacement settings application and it does not own general desktop theming.

## Ownership boundaries

This repository may own:

- System Settings specific patches
- System Settings category, page, label and description changes
- System Settings specific icons or illustrations when they are not general theme assets
- QML/UI adaptations that belong specifically to System Settings
- Fedora packaging required to ship those downstream changes

This repository must not become the source of truth for:

- global Plasma themes, icon themes, wallpapers or cursors: Ro-Theme
- distribution identity and generic branding contracts: ro-asd-branding
- generic desktop/system defaults: ro-asd-defaults
- unrelated KDE application patches

## Downstream model

Prefer the smallest possible downstream delta.

1. Use configuration or metadata overrides when possible.
2. Use asset overrides when the upstream contract allows them.
3. Use patches only when an override cannot express the required change.
4. Keep each patch scoped to one upstream project and one reason.
5. Never vendor a complete KDE source tree into this repository.

## Repository layers

- `patches/`: source patches grouped by upstream KDE project
- `overrides/`: metadata, translations and QML/runtime overrides
- `assets/`: System Settings specific visual assets
- `packaging/`: Fedora/RPM integration
- `scripts/`: validation and maintenance helpers
- `tests/`: smoke and contract tests
- `docs/`: architecture and upstream mapping

## Compatibility

Every downstream change should record the upstream project and compatible version or commit range before it is considered release-ready.
