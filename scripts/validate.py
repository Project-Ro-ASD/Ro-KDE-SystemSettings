#!/usr/bin/env python3
import json
import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

required = [
    ROOT / "README.md",
    ROOT / "VERSION",
    ROOT / ".roasd" / "component.json",
    ROOT / "docs" / "ARCHITECTURE.md",
    ROOT / "docs" / "UPSTREAM-COMPONENTS.md",
    ROOT / "docs" / "DEVELOPMENT.md",
    ROOT / "AGENTS.md",
    ROOT / ".roasd" / "upstreams.json",
]
for path in required:
    if not path.exists():
        errors.append(f"missing required file: {path.relative_to(ROOT)}")

meta = {}
try:
    meta = json.loads((ROOT / ".roasd" / "component.json").read_text())
    if meta.get("component_type") != "component":
        errors.append("component_type must be 'component'")
    if meta.get("component") != "ro-kde-systemsettings":
        errors.append("component must be 'ro-kde-systemsettings'")
except Exception as exc:
    errors.append(f"invalid component metadata: {exc}")

version = (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").exists() else ""
if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
    errors.append("VERSION must contain an initial semantic version such as 0.1.0")

spec = (ROOT / "packaging/fedora/ro-kde-systemsettings.spec").read_text()
if not re.search(r"^Version:\s+" + re.escape(version) + r"$", spec, re.M):
    errors.append("RPM spec version must match VERSION")
if f"VERSION {version} LANGUAGES" not in (ROOT / "CMakeLists.txt").read_text():
    errors.append("CMake version must match VERSION")
if meta.get("fedora_release") != 44 or meta.get("architectures") != ["x86_64"]:
    errors.append("component must target Fedora 44 x86_64")
if meta.get("package_names") != ["ro-kde-systemsettings"] or meta.get("source_rpm") is not True:
    errors.append("component must declare exactly its package and SRPM")

if errors:
    print("validation failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Ro-KDE-SystemSettings repository contract: OK")
