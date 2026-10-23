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

The installable payload is built with CMake and packaged by `packaging/fedora/ro-kde-systemsettings.spec`. CI and release builds share the RPM, manifest/checksum, install, runtime, actual upgrade/removal and Fedora integrity gates. See `tests/README.md` and `packaging/fedora/README.md`.

Do not run transaction tests on the host. Use a disposable Fedora 44 x86_64 container. Do not publish `v0.1.1` until the release blockers in `docs/PRODUCER-READINESS.md` are resolved.

## Independent shell development (0.2.0)

The task explicitly replaces the former wrapper-only architecture. Application
sources live in src/; use public KF6 headers and the Ro QML namespace. Do not
restore archived override code. `cmake -S . -B build && cmake --build build -j2`
followed by `ctest --test-dir build --output-on-failure` runs the real KConfig
fixture behavior tests on a private offscreen DBus session. The fixture is never
installed. Real installed module smoke uses tests/test-runtime.py in a disposable
Fedora container. Physical Plasma/Polkit acceptance remains separate.
