#!/usr/bin/env python3
"""Check real header identities, digest binding and rejection of incomplete/extra input."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[1]
source = Path(sys.argv[1])
env = dict(os.environ, GITHUB_REPOSITORY='Project-Ro-ASD/Ro-KDE-SystemSettings',
           GITHUB_SHA=subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'], text=True).strip(),
           TAG='dry-run', RELEASE_ID='0', GITHUB_RUN_ID='0')
with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp)
    for rpm in source.glob('*.rpm'):
        shutil.copy(rpm, root)
    command = ['python3', str(repo / 'scripts/generate-manifest.py'), str(root)]
    subprocess.run(command, env=env, check=True)
    manifest = json.loads((root / 'component-artifact-manifest-v1.json').read_text())
    assert len(manifest['artifacts']) == 2
    for artifact in manifest['artifacts']:
        assert artifact['producer_artifact_sha256'] == hashlib.sha256((root / artifact['filename']).read_bytes()).hexdigest()
    subprocess.run(['sha256sum', '-c', 'SHA256SUMS'], cwd=root, check=True)
    binary = next(root.glob('*.x86_64.rpm'))
    with binary.open('ab') as out:
        out.write(b'tampered')
    assert subprocess.run(['sha256sum', '-c', 'SHA256SUMS'], cwd=root).returncode != 0
    binary.unlink()
    assert subprocess.run(command, env=env).returncode != 0
    for rpm in source.glob('*.rpm'):
        shutil.copy(rpm, root)
    shutil.copy(binary, root / 'unexpected.rpm')
    assert subprocess.run(command, env=env).returncode != 0
print('Manifest/checksum positive and negative checks passed')
