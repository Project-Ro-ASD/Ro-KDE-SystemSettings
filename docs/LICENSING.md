# Payload licensing audit

The root LICENSE is the GNU GPL version 3 text, not a declaration that every imported KDE file is GPL-3.0-or-later. The original README's `GPL-3.0` and spec's sole `GPL-2.0-or-later` both failed to describe the installed mixed-license payload. Existing file notices are preserved; no upstream copyright or license is rewritten.

The spec aggregates the standard-license choices below with AND. OR choices are exercised for this distribution, not removed from the source notices. LICENSES contains the corresponding unmodified standard texts downloaded verbatim from the FSF old-licenses collection (GPL2/LGPL2) and SPDX license-list-data standard text collection (GPL3/LGPL3). The LGPL2.1 text is taken from Fedora's cockpit-ws package copy of the current FSF text. Current FSF texts use the fsf.org URL instead of obsolete postal addresses; no lint filter or manual license-text edits are used.

| Existing declaration | Package selection | Examples |
| --- | --- | --- |
| GPL-2.0-or-later | GPL-2.0-or-later | kcm_workspace, kcm_componentchooser, kcm_mouse, kcm_about-distro |
| GPL-2.0-only OR GPL-3.0-only [OR KDE accepted GPL] | GPL-3.0-only | accessibility, powerdevil, updates, animations, notifications, pulseaudio |
| GPL-3.0-only OR KDE accepted GPL | GPL-3.0-only | kcm_plasmalogin |
| GPL-3.0-or-later | GPL-3.0-or-later | landingpage |
| LGPL-2.0-only | LGPL-2.0-only | systemsettings shell, fonts |
| LGPL-2.0-or-later | LGPL-2.0-or-later | forms, layouts, breeze Units, separator |
| LGPL-2.1-only OR LGPL-3.0-only OR KDE accepted LGPL | LGPL-2.1-only | breeze backgrounds |
| LGPL-3.0-only OR GPL-2.0-or-later | LGPL-3.0-only | desktop controls |

`.roasd/license-audit.json` records every current override, launcher and desktop entry with SHA256 and its literal SPDX declaration, or null where no header exists. Null is deliberately not converted to a license assertion. In particular the four imported Turkish PO catalogs lack copyright/license comments; translator metadata is not a license grant. Some QML, metadata, generated qmltypes/qmldir and the local loader also lack explicit notices. The root license can describe original repository code but cannot establish the provenance or relicense imported files.

Production blocker: restore authoritative source/version and copyright/license evidence for headerless imported files, including translation catalogs, and confirm the combined binary distribution obligations. The spec now covers all *declared* licenses; it does not claim that missing grants have been resolved. Do not blanket-add GPLv3 headers to unknown upstream content. Use the owning KDE projects and exact versioned files, preserving notices, before authorizing production. This task changes packaging and producer validation, not these upstream-derived source files.
