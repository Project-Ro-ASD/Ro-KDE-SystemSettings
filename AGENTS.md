# AGENTS.md

This repository is the Ro-ASD downstream customization layer for KDE Plasma System Settings.

## Read first

Before making any implementation change, read README.md, docs/ARCHITECTURE.md, docs/UPSTREAM-COMPONENTS.md, docs/DEVELOPMENT.md, .roasd/component.json and .roasd/upstreams.json.

## Scope

This repository may own only System Settings-specific downstream changes.

Allowed examples:
- System Settings shell/navigation changes
- KCM labels, descriptions and category presentation
- System Settings-specific icons or illustrations
- narrowly scoped QML/UI adaptations
- source patches required for Ro-ASD System Settings behavior
- Fedora packaging for those changes

Do not move these responsibilities into this repository:
- global Plasma themes, icon themes, wallpapers or cursors: Ro-Theme
- generic distribution branding: ro-asd-branding
- generic desktop/system defaults: ro-asd-defaults
- unrelated KDE application modifications

## Working rules

- Never vendor a full KDE source tree into this repository.
- Use scripts/fetch-upstream.sh to create disposable upstream checkouts under .work/upstream/.
- Prefer configuration or metadata override over source patch.
- Prefer a narrow source patch over a fork.
- Confirm the real KDE upstream owner before editing or creating a patch.
- One patch should have one reason.
- Record upstream project and base commit/tag for every patch.
- Do not commit build directories, cloned upstream trees, RPM outputs, .orig or .rej files.
- Do not add a production RPM spec or release workflow until there is a concrete payload and ownership is known.
- Preserve KDE security and authentication flows. Do not replace authentication or privileged execution paths for visual customization.

## Git workflow

Do not work directly on main. Use a descriptive feature/, patch/ or docs/ branch and keep commits reviewable and scoped.

## Before editing upstream code

1. Run: bash scripts/check-env.sh
2. Fetch only the needed upstream project: bash scripts/fetch-upstream.sh PROJECT
3. Identify the exact upstream file and behavior.
4. Decide whether the requested change belongs in an override or a patch.
5. Record the upstream base revision in the resulting patch notes.

## Validation

At minimum run:

    python3 scripts/validate.py

When a real patch or override exists, add a focused smoke test for it under tests/.

## Handoff expectation

When finishing a task, report:
- what changed
- which KDE upstream project owns the affected code
- whether the solution is override or patch
- upstream base revision used
- tests run and their results
- any compatibility or upgrade risk
- files changed in this repository

If the requested change crosses an ownership boundary, stop that part of the implementation and explain which Ro-ASD repository should own it.
