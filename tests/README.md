# Fedora 44 verification

Run on the host without installing anything:

```sh
python3 scripts/validate.py
python3 tests/test-contract.py  # requires PyYAML
bash tests/check-workflows.sh  # Linux x86_64, downloads pinned actionlint
```

Use a disposable Fedora 44 x86_64 Podman container for builds and all RPM transactions. CI's dependency list is in `.github/workflows/ci.yml`; it includes dbus-daemon for event-loop smoke. Do not run install/upgrade/removal scripts on the host: they require a container marker and Fedora 44. Source should be a writable disposable copy with Git metadata; new files must be tracked for the source archive.

```sh
bash tests/test-build-rpm.sh
bash tests/test-bundle.sh
bash tests/fetch-previous-rpm.sh
bash tests/run-fedora44.sh "" .work/previous.rpm
```

Use a fresh `RPMBUILD_TOPDIR` and fresh `release-rpms` directory for each build. The bundle test runs blocking rpmlint, checks exact header identities and SRPM linkage, verifies actual SHA256 hashes and tests rejection of tampering, missing and extra RPMs. Negative tests print expected failures.

Clean install requires an absent Ro package and present Fedora System Settings. Conflict tests inspect all installed owners for every non-directory payload path, not just one KDE package. Install checks RPM verification, dynamic linking, wrapper help and Fedora integrity. Runtime smoke starts both stock and wrapped applications through D-Bus with software/offscreen rendering, requires the event loop to survive 12 seconds and rejects common QML/import errors. It cannot prove visual correctness or privileged KCM behavior.

The suite removes the clean-installed candidate, installs the pinned published 0.1.0 RPM, performs an actual DNF upgrade, checks the resulting version, removal of old global environment hooks and integrity of both packages, then removes the candidate and checks every owned path is absent and stock System Settings still works. Fedora files are checked with `rpm -V plasma-systemsettings` throughout. A real interactive Plasma session must still validate navigation, changed KCMs, authentication and session environment after logout/login before production.
