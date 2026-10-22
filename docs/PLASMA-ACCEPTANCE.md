# G14 Fedora 44 KDE Plasma acceptance — manual, currently BLOCKED

Use a disposable G14 test installation or a recoverable test account. Package
transactions below belong on that test system, not the development host.
A headless/offscreen run cannot complete this acceptance. The developer host
exposes Wayland variables, but this audit does not manipulate its live settings,
authentication dialogs or login session.

1. Record `date -Is`, `cat /etc/fedora-release`, `uname -m`, `plasmashell --version`,
   `rpm -q plasma-systemsettings ro-kde-systemsettings`, source commit, RPM/SRPM
   SHA256 and hardware/GPU/session type. Save `rpm -V plasma-systemsettings`
   and the checksummed artifact manifest. Verify each release asset with
   `gh attestation verify FILE --repo Project-Ro-ASD/Ro-KDE-SystemSettings
   --signer-workflow Project-Ro-ASD/Ro-KDE-SystemSettings/.github/workflows/release.yml
   --source-digest EXACT_SOURCE_COMMIT` (one shell command).
2. Before installation, close all System Settings windows. Capture stock
   `/usr/bin/systemsettings` navigation/search, appearance/fonts, display,
   keyboard/mouse, sound, network and power pages. Record unavailable KCMs
   separately. Close the application between comparisons to avoid IPC reuse.
3. Install the exact tested RPM with `sudo dnf install ./PACKAGE.rpm`.
   Validate `/usr/share/applications/ro-systemsettings.desktop` with
   `desktop-file-validate`. Open its menu entry and independently run
   `ro-systemsettings 2>&1 | tee ro-systemsettings-session.log` in a terminal.
   Record category hierarchy, labels in Turkish and English, search results,
   back navigation and opening each available KCM. Inspect logs for missing
   imports/types, binding errors and resource failures.
4. Capture screenshots of stock and Ro navigation, tabs and each changed page.
   Custom accordion/cards/sidebar are **expected inactive in this revision**;
   record this as BLOCKED, never PASS based on window survival. QSS success
   does not establish QML activation. Check resizing, keyboard focus, scrolling,
   scaling and accessibility. Record actual differences rather than expected ones.
5. Open a KCM with legitimate privileged operations. Verify the standard KDE
   authentication prompt and cancellation, then an authorized reversible action
   using the operator's own credentials; restore its original value. Do not
   disable Polkit or record passwords. Verify Apply/Reset and unsaved-change
   handling. Display/theme changes require operator supervision and recovery.
6. Repeat stock invocation after closing Ro. Verify pages and authentication
   still behave normally. Run `rpm -V plasma-systemsettings` again.
7. On a separate test snapshot, install the published 0.1.0 RPM after verifying
   the pinned SHA256 in `tests/fetch-previous-rpm.sh`; upgrade via DNF to the
   candidate. Confirm `/usr/lib/environment.d/50-ro-kde-systemsettings.conf`
   and `/etc/profile.d/ro-kde-systemsettings.sh` disappear. Log out and log in.
   Inspect the new terminal and plasmashell process environment: no obsolete
   Ro XDG/QML/LD_PRELOAD values may survive. Repeat steps 2–6.
8. Remove with `sudo dnf remove ro-kde-systemsettings`; compare its pre-removal
   `rpm -ql` file list with remaining files, excluding shared directories.
   Confirm Fedora System Settings is still installed, unmodified and launches
   through its original desktop entry. Log out/in and repeat environment checks.

For each step record PASS/FAIL/BLOCKED, command/log location, screenshot,
expected/observed behavior, date and operator. Keep a matrix with rows for
navigation/search, each KCM, visuals, authorization/cancel, upgrade, removal,
stock integrity and logout/login. Acceptance requires a human-reviewed result
for every row; unavailable or inactive required features remain BLOCKED.
Do not tag, publish, approve admission or start Beta/Stable from this procedure.
