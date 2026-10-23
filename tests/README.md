# Fedora 44 verification

Run on the host without installing anything:

```sh
python3 scripts/validate.py
python3 tests/test-contract.py  # requires PyYAML
bash tests/check-workflows.sh  # Linux x86_64, downloads pinned actionlint
```

Use a disposable Fedora 44 x86_64 Podman container for builds and all RPM transactions. CI's dependency list is in `.github/workflows/ci.yml`; it includes dbus-daemon for event-loop smoke. Do not run install/upgrade/removal scripts on the host: they require a container marker and Fedora 44. Source should be a writable disposable copy with Git metadata; new files must be tracked for the source archive.

```sh
bash tests/test-build-rpm.sh
bash tests/test-bundle.sh
bash tests/fetch-previous-rpm.sh
bash tests/run-fedora44.sh "" .work/previous.rpm
```

Use a fresh `RPMBUILD_TOPDIR` and fresh `release-rpms` directory for each build. The bundle test runs blocking rpmlint, checks exact header identities and SRPM linkage, verifies actual SHA256 hashes and tests rejection of tampering, missing and extra RPMs. Negative tests print expected failures.

Clean install requires an absent Ro package and present Fedora System Settings. Conflict tests inspect all installed owners for every non-directory payload path, not just one KDE package. Install checks RPM verification, dynamic linking, wrapper help and Fedora integrity. Runtime smoke starts both stock and wrapped applications through D-Bus with software/offscreen rendering, requires the event loop to survive 12 seconds and rejects common QML/import errors. It cannot prove visual correctness or privileged KCM behavior.

The suite removes the clean-installed candidate, installs the pinned published 0.1.0 RPM, performs an actual DNF upgrade, checks the resulting version, removal of old global environment hooks and integrity of both packages, then removes the candidate and checks every owned path is absent and stock System Settings still works. Fedora files are checked with `rpm -V plasma-systemsettings` throughout. A real interactive Plasma session must still validate navigation, changed KCMs, authentication and session environment after logout/login before production.

Additional source tests: `python3 tests/test-launcher.py` checks argument quoting,
optional QSS, XDG defaults/deduplication, inherited QML paths and no preload using
a fake executable. `python3 tests/test-license-audit.py` rejects modified, added
and removed files against the inventory; both run in the workflow contract test.
`python3 tests/test-rcc-rebuild.py` runs during Fedora build validation and proves
a QML-only edit changes the binary RCC without touching the QRC file. It operates
on a temporary source copy. G14 human acceptance is in
[PLASMA-ACCEPTANCE.md](../docs/PLASMA-ACCEPTANCE.md); actual activation boundaries
are in [INTEGRATION-STATUS.md](../docs/INTEGRATION-STATUS.md).

Native-skin architecture diagnostics (manual, no package transactions):

```bash
python3 tests/probe-native-skin.py --output .work/native-skin-evidence --seconds 3
```

Requires `dbus-run-session` (Fedora `dbus-daemon`). Runs the unmodified KDE
executable with stock/QSS/Basic/Fusion variants in temporary HOME/XDG directories
and an isolated D-Bus session. JSON and full logs include early exits and whether
the stock QML URL appeared in import tracing. A surviving process alone does not
prove QML loading, a responsive event loop, visual changes, KCM functionality or
performance. Offscreen results are never real Plasma acceptance. Excluding a
crashing provider for diagnosis must be explicitly recorded; it invalidates any
claim that all KCMs were tested. See [the decision record](../docs/NATIVE-SKIN-DECISION.md).
