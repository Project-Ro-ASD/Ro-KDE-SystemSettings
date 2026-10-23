#!/usr/bin/env python3
"""Apply the native selector delta to real pinned KDE tags, with zero fuzz.

This is source applicability, not runtime acceptance on those dependency stacks.
Requires scripts/fetch-upstream.sh systemsettings to have been run first.
"""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
upstream = root / '.work/upstream/systemsettings'
patch = root / 'patches/systemsettings/0001-opt-in-native-qml-shell.patch'
stats = subprocess.check_output(['git', 'apply', '--numstat', str(patch)], text=True).splitlines()
assert len(stats) == 1 and stats[0].endswith('\tapp/SidebarMode.cpp'), stats
results = []
for tag in ('v6.6.4', 'v6.6.5', 'v6.7.0', 'v6.7.4', 'v6.7.5', 'v6.8.1'):
    commit = subprocess.check_output(['git', '-C', str(upstream), 'rev-parse', tag + '^{commit}'], text=True).strip()
    with tempfile.TemporaryDirectory(prefix='ro-patch-matrix-') as temporary:
        source = Path(temporary) / 'app/SidebarMode.cpp'
        source.parent.mkdir()
        source.write_bytes(subprocess.check_output(['git', '-C', str(upstream), 'show', commit + ':app/SidebarMode.cpp']))
        result = subprocess.run(['patch', '--dry-run', '--fuzz=0', '-p1', '-i', str(patch)],
                                cwd=temporary, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        results.append(dict(tag=tag, commit=commit, exit_code=result.returncode, log=result.stdout,
                            scope='source application only; not runtime compatibility'))
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(dict(patch_numstat=stats, results=results), indent=2) + '\n')
assert all(result['exit_code'] == 0 for result in results), results
print('Native patch application PASS: six real KDE tags, zero fuzz')
