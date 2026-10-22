#!/usr/bin/env python3
"""Generate the V2 producer manifest from exactly one binary RPM and its SRPM."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

root = Path(sys.argv[1])
version = (Path(__file__).resolve().parents[1] / 'VERSION').read_text().strip()
paths = sorted(root.glob('*.rpm'))
if len(paths) != 2:
    raise SystemExit('Expected exactly two RPMs')
artifacts = []
query = '%{NAME}\t%{EPOCHNUM}\t%{VERSION}\t%{RELEASE}\t%{ARCH}\t%{SOURCERPM}\t%|SOURCEPACKAGE?{true}:{false}|'
for path in paths:
    name, epoch, ver, release, arch, source, is_source = subprocess.check_output(
        ['rpm', '-qp', '--qf', query, str(path)], text=True).split('\t')
    if is_source == 'true':
        arch, source = 'src', None
    if (name != 'ro-kde-systemsettings' or ver != version or
            not re.fullmatch(r'[0-9]+\.roasd[0-9]+\.fc44', release) or
            arch not in ('src', 'x86_64') or
            path.name != f'{name}-{ver}-{release}.{arch}.rpm' or int(epoch) != 0):
        raise SystemExit(f'Invalid RPM identity: {path}')
    artifacts.append(dict(filename=path.name, name=name, epoch=int(epoch), version=ver,
                          release=release, architecture=arch, source_rpm=source,
                          producer_artifact_sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
if sorted(a['architecture'] for a in artifacts) != ['src', 'x86_64']:
    raise SystemExit('Expected one x86_64 RPM and one SRPM')
source = next(a for a in artifacts if a['architecture'] == 'src')
binary = next(a for a in artifacts if a['architecture'] == 'x86_64')
if binary['source_rpm'] != source['filename']:
    raise SystemExit('Binary RPM references another SRPM')
manifest = dict(schema_version=1, component='ro-kde-systemsettings',
                source_repository=os.environ['GITHUB_REPOSITORY'],
                source_commit=os.environ['GITHUB_SHA'], release_tag=os.environ['TAG'],
                release_id=int(os.environ['RELEASE_ID']), workflow_run=int(os.environ['GITHUB_RUN_ID']),
                fedora_release=44, artifacts=artifacts,
                provenance=dict(provider='github', subject_digest='sha256'),
                attestation=dict(provider='github', verification='gh attestation verify'))
if not re.fullmatch(r'[0-9a-f]{40}', manifest['source_commit']):
    raise SystemExit('Invalid source commit')
if manifest['release_tag'] != 'dry-run' and (
        manifest['release_tag'] != f'v{version}' or manifest['release_id'] <= 0 or manifest['workflow_run'] <= 0):
    raise SystemExit('Invalid release identity')
(root / 'component-artifact-manifest-v1.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')
(root / 'SHA256SUMS').write_text(''.join(f"{a['producer_artifact_sha256']}  {a['filename']}\n" for a in artifacts))
