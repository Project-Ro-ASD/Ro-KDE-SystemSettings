# Independent shell validation

Run source-only checks anywhere:

```bash
python3 scripts/validate.py
python3 tests/test-contract.py
bash tests/check-workflows.sh
```

Build Qt6/KF6 and run behavior tests in disposable Fedora 44:

```bash
cmake -S . -B .work/independent-build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr
cmake --build .work/independent-build -j2
ctest --test-dir .work/independent-build --output-on-failure
```

`run-shell-unit.sh` uses a private DBus session, temporary config/data/cache and
offscreen software rendering. Its source-only fixture is a real KCModule plugin
using KConfig persistence. Tests exercise search/result navigation, cancel on
unsaved change, save/load/defaults, dirty state, history and missing-module error.
The same suite also loads available real QtQuick settings/formats/fonts/colors
KCMs. The fixture is never installed in the product. This is automated behavior
coverage, not a physical/Polkit acceptance claim.

Use only disposable Fedora 44 x86_64 for package transactions:

```bash
bash tests/test-build-rpm.sh
bash tests/test-bundle.sh
bash tests/fetch-previous-rpm.sh
bash tests/run-fedora44.sh "" .work/previous.rpm
```

The build script archives tracked source; stage new/deleted files first. RPM
`%check` runs ctest. Smoke checks require ELF, Ro desktop entry and absence of
retired hook/QRC/override payload. Incremental QML regeneration is tested against
the actual executable. The RPM/SRPM, rpmlint, manifest/checksum negative cases,
file ownership, clean install, actual 0.1.0 upgrade/removal and stock integrity
gates remain. Runtime tests load real KCMs and run Ro/stock concurrently on the
same private DBus session, never the developer's session.

The broad KCM image must retain touchpad in its installed inventory. If stock
crashes in metadata/KCModuleData touchpad construction, preserve the FAIL and
stack; do not remove the KCM or classify it as a Ro failure without evidence.
A minimal clean Fedora CI result is a separate compatibility row.

`dbus-run-session -- python3 tests/benchmark.py --output REPORT.json` records
three isolated offscreen trials per application (RSS/PSS/CPU after 3 seconds and
process exit). It requires a container. It does not measure physical first
window, cold/warm startup, KCM input or category latency. Those require the
operator procedure in docs/PLASMA-ACCEPTANCE.md, repeated before/after upgrades
with identical Ro ELF/QML checksums. Do not compare results from different hosts.

No automatic test result constitutes real Polkit, visual, hardware, scaling,
screen-reader or future KDE compatibility acceptance. No test publishes a tag,
release, signature, Ro-Repo producer entry or changes PR #86.
