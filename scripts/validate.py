#!/usr/bin/env python3
import json
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
]
for path in required:
    if not path.exists():
        errors.append(f"missing required file: {path.relative_to(ROOT)}")

try:
    meta = json.loads((ROOT / ".roasd" / "component.json").read_text())
    if meta.get("component_type") != "component":
        errors.append("component_type must be 'component'")
    if meta.get("component") != "ro-kde-systemsettings":
        errors.append("component must be 'ro-kde-systemsettings'")
except Exception as exc:
    errors.append(f"invalid component metadata: {exc}")

version = (ROOT / "VERSION").read_text().strip() if (ROOT / "VERSION").exists() else ""
if not version or version.count(".") != 2:
    errors.append("VERSION must contain an initial semantic version such as 0.1.0")

if errors:
    print("validation failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Ro-KDE-SystemSettings repository contract: OK")
