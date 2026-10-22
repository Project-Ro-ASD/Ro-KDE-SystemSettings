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

`.roasd/license-audit.json` records every current override, launcher and desktop entry with SHA256 and its literal SPDX declaration, or null where no SPDX declaration exists. Null is deliberately not converted to a license assertion. The four imported Turkish PO catalogs now have recovered upstream copyright comments (see the dated evidence below), but their exact original import bases and license selections remain unresolved; translator metadata alone is not a license grant. Some QML, metadata, generated qmltypes/qmldir and the local loader also lack explicit notices. The root license can describe original repository code but cannot establish the provenance or relicense imported files.

Production blocker: restore authoritative source/version and copyright/license evidence for headerless imported files, including translation catalogs, and confirm the combined binary distribution obligations. The spec now covers all *declared* licenses; it does not claim that missing grants have been resolved. Do not blanket-add GPLv3 headers to unknown upstream content. Use the owning KDE projects and exact versioned files, preserving notices, before authorizing production. The changes below restore proven upstream notices without assigning new licenses.

## 2026-10-23 evidence update

Reviewed four Turkish catalogs against official KDE `v6.7.5` sources. The exact
reference commits, paths and upstream SHA256 values are recorded in
`.roasd/translation-provenance.json`. Restored their original copyright and
package-license comments verbatim. No SPDX license was invented: three upstream
catalogs say "same license as the ... package" without selecting a unique
expression, and the upstream systemsettings catalog has copyright but no explicit
license grant in its header. KDE's [licensing policy](https://community.kde.org/Policies/Licensing_Policy)
and [licensing guide](https://community.kde.org/Guidelines_and_HOWTOs/Licensing)
require per-file notices; the general policy does not supply the missing original
import history or downstream contributors' grants.

GNU gettext compiled-message comparison (ignoring catalog header metadata) found:
landingpage: all 22 messages match; systemsettings: 38 messages, one changed
translation (`Back` was incorrectly `Genişleti`, now restored to upstream `Geri`);
nighttime: 28 messages, three translated strings differ; qtquicksettings: 13
messages, one source-message key differs. These comparisons establish useful
source correspondence, not a claim of byte-identical imports or legal clearance.

All 49 records without SPDX are listed individually in
[LICENSE-BLOCKERS.md](LICENSE-BLOCKERS.md). All 107 payload inventory records now
have CI-enforced path coverage, SHA256 and declaration freshness via
`python3 scripts/check-license-audit.py`. A PASS means inventory consistency;
production clearance remains BLOCKED. Use `--update` only after reviewing changed
files; it never assigns licenses or resolves blockers automatically.

Category evidence: `.roasd/metadata-provenance.json` compares every one of the
25 category files with the same pinned systemsettings source: eight are byte
identical and 17 are modified. The upstream category desktop files themselves
have no SPDX identifier; none is inferred from neighboring code or translations.
The six corresponding original shell QML filenames exist at that reference
but all differ downstream. `NavButton.qml` and `SubSubCategoryPage.qml` have no
same-name upstream file there; original authorship/grants remain BLOCKED.
Git history traces the custom loader through local UI commits (including
`8dc1086` and `e675642`), but those commits supply no explicit file-level grant
or authoritative provenance for any borrowed portions.
