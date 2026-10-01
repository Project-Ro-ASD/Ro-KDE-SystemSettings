# Upstream component map

Ro-KDE-SystemSettings can touch multiple KDE Plasma repositories because System Settings pages are implemented by separate KCM providers.

Initial upstream buckets:

| Area | Upstream project | Local path |
| --- | --- | --- |
| System Settings shell/navigation | KDE systemsettings | `patches/systemsettings/` |
| Workspace/Desktop KCMs | KDE plasma-desktop | `patches/plasma-desktop/` |
| Network KCMs | KDE plasma-nm | `patches/plasma-nm/` |
| Power KCMs | KDE powerdevil | `patches/powerdevil/` |
| Display KCMs | KDE kscreen | `patches/kscreen/` |

Do not add a patch until its real upstream owner is confirmed.

For every patch, document:

- upstream repository
- upstream file(s)
- upstream commit/tag used while creating the patch
- Ro-ASD reason for the change
- whether an upstreamable solution was considered
- test/verification notes
