# Development workflow

## Goal

Development happens against clean upstream KDE checkouts while this repository stores only the Ro-ASD delta. Upstream source trees live under .work/upstream/ and are ignored by Git.

## 1. Check the workstation

    bash scripts/check-env.sh

The script does not install packages or change the system. It only reports the tools that are available.

## 2. Fetch the required KDE upstream

List known projects:

    bash scripts/fetch-upstream.sh list

Fetch one project:

    bash scripts/fetch-upstream.sh systemsettings

Fetch all known projects only when genuinely needed:

    bash scripts/fetch-upstream.sh all

The checkout is created at .work/upstream/PROJECT. Running the command again performs a fetch/prune instead of creating a second copy.

## 3. Discover before patching

For every requested customization:
1. reproduce or locate the current behavior
2. identify the owning upstream repository
3. identify the exact source, metadata or QML file
4. check whether KDE already provides an override/configuration path
5. patch only if the override path is insufficient

Do not copy upstream source files into this repository merely to edit them.

## 4. Store the Ro-ASD delta

Use overrides/ for supported metadata/runtime overrides, patches/PROJECT/ for source patches, and assets/ only for System Settings-specific visual assets.

For a source patch, keep provenance next to the patch. The provenance note should include upstream URL, base commit/tag, affected files, reason and verification.

## 5. Validate

    python3 scripts/validate.py

Add targeted tests as real customizations enter the repository.

## Fedora baseline

The current Ro-ASD component contract targets Fedora 44. Do not assume the newest KDE upstream branch is identical to Fedora 44 packaging. Before generating a production patch, confirm the actual source version used by the Ro-ASD/Fedora package and record that base revision.

## Release work

RPM spec, producer manifest and trusted release workflow are intentionally deferred until the repository has a concrete installable payload. Do not invent empty release artifacts.
