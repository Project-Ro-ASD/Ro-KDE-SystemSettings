# Fedora packaging

This directory will contain the RPM spec and source preparation required to ship Ro-KDE-SystemSettings on the Ro-ASD Fedora base.

The package should carry only the downstream System Settings integration owned by this repository. It must not silently replace unrelated KDE files.

Before the first RPM release, define:

1. exact installed file ownership
2. required KDE/Plasma package versions
3. patch application order
4. upgrade/rollback behavior
5. Ro-Repo producer/release integration
