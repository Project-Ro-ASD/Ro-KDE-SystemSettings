# Native QML selector prototype

Development only. Authorized for isolated tests, not host replacement or release.

- Owner: KDE `plasma/systemsettings`, `app/SidebarMode.cpp`.
- Primary base: `v6.7.5`, `d126c08d14a2a0f44a1758fd25e945ae099e34bb`.
- Fedora bases: real `plasma-systemsettings` SRPMs 6.6.4-1.fc44 and
  6.7.5-1.fc44. Neither inspected spec carries an additional source patch.
  Source identities and SHA256 values: `.roasd/native-prototype-bases.json`.
- Reason: the original application loads an explicit embedded QRC URL. Public
  control styles/import paths cannot replace its navigation layout.
- Delta: **one file, 29 insertions / 8 deletions**. No CMake, ModuleView,
  SettingsBase, KCM, policy, privileged helper or authentication code change.
- License: modifications to this GPL-2.0-or-later upstream file are offered under
  GPL-2.0-or-later, matching its preserved notices. New standalone visual resources
  have their own GPL-3.0-only notices. No historical provenance blocker is reused.

`RO_SYSTEMSETTINGS_SKIN=1` opts the original System Settings application into the
fixed package-managed `/usr/share/ro-kde-systemsettings/native/Main.qml` file.
There is no arbitrary path/URL environment selector. InfoCenter is excluded.
The same original QQmlEngine, context, MenuModel/proxy models and ModuleView stay
in use. The native root contract (`QQuickItem`, finite positive implicit width,
finite nonnegative `headerHeight`) is checked. Each attempt owns a fresh
QQmlComponent: reusing a failed component retained its error state in actual
tests and broke fallback. Missing/import/syntax/construction/contract failures
fall back to the original embedded root. Failure of the original root retains
KDE's fatal behavior.

This cannot recover every later JavaScript binding error or semantic model/API
change after a successful root creation. QML context/model properties are KDE's
internal application interface, **not a promised public skin ABI**. No private
C++ ABI hook is used or added. Runtime tests must gate each supported update.
If context adaptation becomes recurring or expands beyond this small boundary,
stop rather than grow a parallel navigation/backend implementation.

## Checks

`tests/test-native-patch-matrix.py` applies the unchanged patch with zero fuzz to
six actual tags: 6.6.4, 6.6.5, 6.7.0, 6.7.4, 6.7.5, 6.8.1. A one-line offset on
some tags is accepted; manual edits and fuzzy context matching are not.

Native test-driver builds from real 6.6.5 and 6.7.5 sources exercise the same
visual file on the same Fedora 44 SDK/runtime. These are original upstream
`systemsettings` targets with test-only QtTest instrumentation, not another
settings application. Instrumentation is excluded from the RPM patch and RPMs.
See the Turkish [prototype report](../../docs/NATIVE-SKIN-PROTOTYPE-REPORT.md)
for provider exclusions, test results and the narrower compatibility claim.

## Upstream possibility

A general package-controlled, opt-in sidebar source selector with fallback could
be proposed upstream. The Ro-specific environment/path names should be replaced
with an agreed generic interface, and KDE would need to define which context and
root properties it supports and how incompatible shells are rejected. A small
loader patch alone does not establish a stable plugin API. An upstream design
discussion and negative tests are appropriate before requesting such a promise.
No upstream issue/PR/message was sent by this task.
