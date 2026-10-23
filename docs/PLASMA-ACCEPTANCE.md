# G14 Fedora 44 independent-shell acceptance — operator required

Status: BLOCKED until an operator performs the physical session tests. Do not
install or change settings in the developer's live user session. Use an approved
disposable/recoverable G14 installation and record restoration steps first.
Headless tests do not establish visual, Polkit or hardware acceptance.

1. Record date/time, source commit, RPM/SRPM SHA256, Fedora release, architecture,
   Qt/KF6/Plasma versions, GPU, Wayland/X11, resolution/scaling and hardware.
   Save `rpm -V plasma-systemsettings`, RPM file ownership and process/bus inventory.
   For attested artifacts verify the exact source digest with the existing
   trusted release.yml workflow identity. No unsigned local build is a release.
2. Capture stock navigation/search and real appearance/fonts, display, input,
   touchpad, sound, network and power KCMs. Keep touchpad in scope. If stock
   crashes, collect coredump/GDB version/plugin stack and reproduce independently
   before assigning ownership. Record unavailable modules rather than hiding them.
3. Install the candidate only with operator approval. Open Ro via its own menu
   entry and executable. Confirm actual Ro sidebar, expanding categories, paths,
   cards, search (name/description/keyword), result opening, back/forward and
   unsaved-change cancellation. KCM internal tabs/subpages must remain usable. Test KCMLauncher cross-module links separately; these currently launch upstream external windows and remain an integration blocker.
   Capture Ro/stock screenshots, TR/EN, light/dark, 100/150/200% scaling,
   resizing/minimum size, keyboard-only Ctrl+F/Tab/Enter/Alt+arrows and screen reader.
4. For each real tested KCM record ID/provider/version and original state.
   Make an operator-approved reversible change; verify Apply, Reset, Defaults
   (does not save until required), and cancel/discard/apply on page/close changes.
   Record instant-apply behavior separately and restore the original state.
5. For a legitimately privileged KCM verify standard Polkit prompt, wrong/denied
   credentials and cancellation leave pending settings unsaved. Then authorize
   a reversible change using operator credentials and restore it. Never log
   passwords or bypass authentication. Close/navigation must be blocked while
   an authorization job is outstanding. Confirm restricted KCMs obey Kiosk policy.
6. Run stock and Ro simultaneously in both startup orders. Stock must retain its
   own UI; Ro selection must stay within Ro. A second Ro call opens another Ro
   process by design. Explicit stock fallback may reuse the stock instance.
   On Ro close, compare process tree/bus names with the baseline: no Ro-owned
   daemon/service or descendant may remain. Recheck `rpm -V plasma-systemsettings`.
7. In a separate snapshot install verified historical 0.1.0; upgrade to 0.2.0.
   Confirm old global environment/profile files, private QML/import directories,
   RCC/QSS/catalogs and hook library are removed. Logout/login clears inherited
   old environment. Repeat UI/auth/stock tests. Remove candidate and verify all
   Ro-owned files disappear, stock remains installed and unmodified, and its
   original menu entry still works.
8. With candidate ELF/Ro QML checksums unchanged, record discovery IDs/categories,
   search, module navigation and Apply/Reset/Polkit before and after the approved
   Fedora KDE/KF6 package update. Record actual versions and failures. Restore the
   snapshot on failure and use explicit stock fallback. Do not claim future compatibility.
9. Benchmark on the same snapshot/hardware/session, at least five trials per app:
   genuinely cold start (document cache/reboot conditions), warm start, physical
   first displayed window, RSS/PSS/CPU at matched idle time, first KCM opening,
   category transition and post-close process state. Separate first-use cache
   creation from warm runs; report median/range and raw evidence. Do not claim
   a speed/memory advantage from the offscreen helper or unmatched environments.

For every row record PASS/FAIL/BLOCKED, operator, date, command/log, screenshots,
expected/observed behavior and restore evidence. Physical install/upgrade/setting
changes require operator approval. No tag/release/signing, Ro-Repo/PR #86 change,
merge, secret/environment or Beta/Stable publication is part of this procedure.
