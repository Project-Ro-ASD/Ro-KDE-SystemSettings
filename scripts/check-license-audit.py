#!/usr/bin/env python3
"""Check inventory freshness, not legal clearance. --update records current bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def inventory(root):
    paths = [root / 'bin/ro-systemsettings', *sorted((root / 'overrides').rglob('*')),
             *sorted((root / 'packaging/fedora').glob('*.desktop'))]
    records = []
    for path in sorted(p for p in paths if p.is_file()):
        data = path.read_bytes()
        # Header lines may end in an XML/C++ comment delimiter.
        match = re.search(r'SPDX-License-Identifier:\s*([^\r\n]+)', data.decode('utf-8'))
        spdx = match[1].removesuffix('-->').removesuffix('*/').strip() if match else None
        records.append(dict(path=str(path.relative_to(root)),
                            sha256=hashlib.sha256(data).hexdigest(), declared_spdx=spdx))
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--update', action='store_true')
    args = parser.parse_args()
    target = ROOT / '.roasd/license-audit.json'
    audit = json.loads(target.read_text())
    actual = inventory(ROOT)
    if args.update:
        audit['files'] = actual
        target.write_text(json.dumps(audit, indent=2) + '\n')
    elif audit['files'] != actual:
        print('FAIL: license audit is stale or incomplete; review provenance then run '
              'python3 scripts/check-license-audit.py --update', file=sys.stderr)
        return 1
    missing = [entry['path'] for entry in actual if entry['declared_spdx'] is None]
    print(f'License inventory PASS: {len(actual)} files; {len(missing)} without SPDX. '
          'Production license clearance remains BLOCKED (see docs/LICENSING.md).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
