# License and source provenance — independent shell

The 0.2.0 active application is newly implemented for this task. Its C++, QML,
CMake and Ro desktop entry carry GPL-3.0-or-later notices. The root LICENSE is the
GPLv3 license text. Public API use and reading upstream implementations do not
copy their source into the executable. KDE libraries/plugins retain their own
licenses and are dependencies supplied by Fedora, not bundled here.

No old QML, translation, metadata, illustration, QSS, generated qmltypes or symbol
hook source is reused. `bin/ro-systemsettings`, `overrides/`, and the unused stock
.desktop copy are removed from the current source tree, and thus from its source
archive, SRPM and binary RPM. The old 49-file review in LICENSE-BLOCKERS.md is a
historical record, not a license clearance. It must be reopened if any old file is
restored. Deletion does not retroactively clear old releases or their source.

The source inventory `.roasd/license-audit.json` hashes every active application
source, CMake and desktop entry. `scripts/check-license-audit.py` rejects drift,
addition and removal. This check verifies inventory freshness, not legal advice.
New tests are GPL-3.0-or-later; they are source-only and their fixture KCM is never
installed. Existing repository tooling/docs originate in the repository history
and remain under its root GPL license; their prior notices are preserved. No
external image, font, catalog or code snippet is imported into the active UI.

RPM License is GPL-3.0-or-later for the new payload. The historical mixture of
GPL/LGPL expressions no longer describes active packaged code. License texts for
retired imports may remain in source history/documentation but are not bundled
as claims of permission for retired files.

Primary API references and inspected revisions are recorded in INDEPENDENT-SHELL.md.
No random SPDX assignment has been made to an imported file.
