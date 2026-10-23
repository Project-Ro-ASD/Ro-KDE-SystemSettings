# Isolated native-skin prototype

No production integration is enabled by this directory. The existing production
CMake/spec/launcher and release workflow do not consume these resources.

`Main.qml` is newly authored GPL-3.0-only presentation code. It uses original
KDE category/search/subcategory models and calls `SidebarMode::loadModule` and
the original action menu. KCM discovery, dirty-state decisions, Apply, Reset,
Defaults and authorization stay in KDE. No helper/service/executable is shipped
by the skin RPM. The native `plasma-systemsettings` package continues to own
`/usr/bin/systemsettings`; its SRPM is rebuilt only for isolated tests.

The selectors/context are version-sensitive application interfaces, not a public
KDE skin API. See [patch notes](../../patches/systemsettings/README.md) and the
[Turkish report](../../docs/NATIVE-SKIN-PROTOTYPE-REPORT.md) before using results.

## Reproduce in a disposable Fedora 44 builder

Prepare only the needed KDE source checkout using `scripts/check-env.sh` and
`scripts/fetch-upstream.sh systemsettings`. Download one exact official SRPM URL
from `.roasd/native-prototype-bases.json` into `.work/`. Hashes are checked by:

```bash
python3 scripts/prepare-native-prototype.py .work/native-prototype/downloads/plasma-systemsettings-6.7.5-1.fc44.src.rpm --topdir .work/reproduce-native-675
```

The output directory must be new. Unreviewed SRPMs and changed source archives are
rejected. A future update requires reviewing its source identity/spec and adding
metadata, rather than automatically trusting arbitrary downloaded spec scripts.
Only a derived copy of Fedora's spec is edited under `.work/`; original source,
RPM/SRPM artifacts and cloned upstream trees must not be committed.

Run the rest **inside a disposable container** with this checkout mounted as
`/src`, `--security-opt label=disable` and a writable container root filesystem.
Do not run package transactions on the desktop host. The builder needs
`git`, `python3`, `cpio`, `rpm-build`, `dnf5-plugins`, `gcc-c++`, `cmake`,
`ninja-build`, `gettext` and `dbus-daemon`, followed by:

```bash
dnf builddep -y /src/.work/reproduce-native-675/SPECS/plasma-systemsettings.spec
bash /src/tests/build-native-prototype.sh /src/.work/reproduce-native-675
```

Use a consistent SDK. An already installed older development package may need
an explicit upgrade when the repository now supplies a newer KF6 development
stack. Do not weaken CMake dependency checks to force mixed versions.

## Test paths

```bash
python3 /src/tests/test-native-patch-matrix.py --output /src/.work/native-matrix.json
python3 /src/tests/build-native-test-driver.py --tag v6.7.5 --patched --output /src/.work/reproduce-driver-675
```

The driver links QtTest into the **original upstream `systemsettings` target**
in a disposable copy. There is no new host application. Driver code and its CMake
overlay are excluded from the Fedora patch/RPM. It writes structured assertions
and a client-window screenshot, then exits. Test-only access to Fonts settings
uses QObject properties; production skin code does not manipulate settings.

Install the two local prototype RPMs inside the container. The skin activation
contract is only `RO_SYSTEMSETTINGS_SKIN=1 /usr/bin/systemsettings`. It is never
installed as a login-wide environment setting. Use the instruments separately:

```bash
python3 /src/tests/run-native-case.py /src/.work/reproduce-driver-675/build/bin/systemsettings --output /src/.work/native-ui --expect ro --case ui
python3 /src/tests/test-native-fallback.py /src/.work/reproduce-driver-675/build/bin/systemsettings --output /src/.work/native-fallback
```

Real Fonts KCM requires `plasma-workspace-libs`; broad provider testing also uses
`plasma-desktop`. Standard KDE presentation uses `plasma-integration`,
`kf6-qqc2-desktop-style` and `breeze-icon-theme`. A C-only/minimal locale image is
insufficient for translation acceptance: install `glibc-langpack-en`/`tr` and
both native KDE and Ro TR catalogs. The test runner uses `en_US.UTF-8` with KDE's
selected UI language. An image `%_install_langs en_US` filter deliberately omits
TR files; use `%_install_langs all` in the disposable RPM test environment.

For an actual Wayland connection, bind only the compositor socket into the
container and pass its absolute path in `WAYLAND_DISPLAY`. `--platform wayland
--platform-theme kde --controls-style org.kde.desktop` selects standard KDE
rendering. The runner still isolates HOME/XDG and D-Bus; it does not connect to
the host's KWin/system D-Bus services. Full session/hardware/Polkit acceptance
cannot be inferred. A Wayland popup may require a compositor input serial that
synthetic QtTest events do not provide; this is recorded as a limitation.

In this environment stock touchpad initialization crashes without its backend.
Record the stock crash/backtrace first. If the plugin is temporarily excluded
inside the container to continue diagnostics, explicitly record that exclusion
and restore it afterwards. Never claim an all-KCM pass or remove it from shipping
packages as a workaround. The supplied scripts do not silently exclude providers.

`test-native-rpm-transactions.py` performs real DNF transitions using explicit
`--older-rpm`, `--stock-rpm`, `--patched-rpm`, `--skin-rpm`, `--output` inputs.
It checks each transition and file ownership, resource persistence, removal and
stock binary restoration. It leaves the disposable container on the supplied
stock Fedora RPM. `measure-native-process.py` observes only the application PID
at a fixed age; it cannot measure first-frame latency or full-session cost.
