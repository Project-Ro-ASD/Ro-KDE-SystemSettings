# Fedora 44 V2 producer preparation

## Baseline inspected

- Repository main: `4a0f33ad2b6689307dc3bc67e0ff937f0212b809`.
- Existing annotated `v0.1.0` tag object: `4c51977ab34f3712f1fd6f8fa66e70f538217609`, targeting that main commit.
- Existing release: ID `420767797`, `immutable: false`, four assets. Left unchanged. Its successful release build did not exercise the full install/upgrade/runtime suite.
- CI at that commit failed immediately; `path: **/*.rpm` is invalid YAML (an unquoted alias token). Artifact output also lived outside the workspace previously.
- Disposable Fedora 44 resolves `plasma-systemsettings-6.7.5-1.fc44.x86_64`. KDE `systemsettings` owns the shell/category lookup and executable. Inspection reference `v6.7.5` commit is `d126c08d14a2a0f44a1758fd25e945ae099e34bb`. It is not retroactively claimed as the original base for existing overrides.

## Ownership and implementation

This change hardens packaging/producer validation and fixes the local loader glue to reference the resource compiler's actual `qInitResources_overrides` / `qCleanupResources_overrides` symbols. `--no-undefined` now catches this defect at link time. No upstream source patch is added. The independent wrapper executes Fedora's original System Settings and does not preload the private interposition library. Process-local metadata/QSS remains supported by the wrapper; the existence of the private RCC/library does not prove full custom shell activation.

The previous package globally prepended XDG_DATA_DIRS and shadowed the stock `systemsettings.desktop`. The new package removes those global hooks, keeping a separate `ro-systemsettings.desktop`. The actual old-version upgrade test checks obsolete hooks disappear. Existing logged-in users need a new session to discard inherited environment values.

Existing QML spans systemsettings, plasma-desktop, powerdevil, kscreen, plasma-workspace, plasma-pa, plasma-discover, plasmalogin, Kirigami and QQC2/Breeze desktop style owners. Generic control/theme fragments belong to Ro-Theme; generic identity belongs to ro-asd-branding. This task does not extend or alter those cross-boundary fragments. Their ownership split and authoritative original source bases must be resolved before enabling dormant global-style overrides. `systemsettings` is the upstream owner affected by launcher/category behavior; no upstream base is needed for a new patch because none is added.

## Release blockers and remaining risk

1. Headerless imported sources and PO catalogs lack authoritative license/source records. See LICENSING.md and the per-file audit. The SPDX correction covers declared licenses and preserves every existing notice; absent grants cannot be inferred.
2. Existing overrides have no recorded exact original upstream bases. The inspected Fedora tag is a compatibility reference only. Version-sensitive QML/private ABI must not be advertised as verified by a package build.
3. Interactive Plasma acceptance must verify stock and wrapped navigation, changed KCM discovery, visual behavior, authentication and logout/login environment. Offscreen tests do not prove these properties.
4. Live GitHub OIDC signing and immutable publication can only be verified in a trusted workflow/release context. No tag or release is created by this work. A future failure after draft creation leaves that draft for investigation; automatic deletion/reuse is forbidden.

The preparation PR must remain reviewable with these limitations. Do not call the component production-ready solely because RPM tests pass. Ro-Repo and its PR #86 are outside this change.

## Validation evidence

Local disposable Podman validation on Fedora 44 x86_64 passed:

- `bash scripts/check-env.sh`, `python3 scripts/validate.py`, workflow YAML and embedded Bash/version contract checks.
- actionlint 1.7.12 (official release tar SHA256 `8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8`): both workflows valid. CI now runs this pinned check too.
- RPM/SRPM build; `%check` validates the desktop file and translation formats. Binary name/version/release/arch, declared SPDX expression, 25 category entries and four compiled catalogs passed.
- rpmlint 2.8.0: **0 errors, 5 warnings, 0 badness**. Warnings: unstripped private library, missing wrapper man page, container en_US locale unavailable during spec parsing, and two duplicate standard-license texts. These are reported, not filtered; an explicit E diagnostic gate supplements rpmlint's scored return status.
- Real RPM-header manifest generation, binary/SRPM association, SHA256 verification and negative tests for changed bytes/missing/extra input passed. Deliberate negative checksum messages in the logs are expected.
- All installed-package file-owner checks and forbidden global/replacement paths passed. No Fedora System Settings replacement dependencies are added.
- Clean DNF install, `rpm -V` on both packages, `ldd -r` and help smoke passed. The stronger test found and led to fixing two unresolved local loader symbols.
- Stock and wrapped shell event loops survived 12 seconds each under D-Bus/offscreen/software rendering without the checked QML/import/linker failures. Headless GTK portal warnings are expected and do not prove a graphical session works.
- Pinned original 0.1.0 RPM SHA256 verified, actual DNF upgrade to 0.1.1 passed, old global hooks disappeared, candidate removal left no owned paths, stock Fedora package remained installed, unmodified and runnable.

No DNF operation ran on the host. Live signing/immutable publication and interactive KCM acceptance are still unverified; they are not represented as local successes. Future `v0.1.1` release steps are in packaging/fedora/README.md.
