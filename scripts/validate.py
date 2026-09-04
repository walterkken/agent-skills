#!/usr/bin/env python3
"""Validate the package structure, referenced resources, and common secret patterns.

This is a deterministic packaging check, not a guarantee that every external
service, skill workflow, or future credential format is covered.
"""
from __future__ import annotations

import ast
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
OMIT = {'.git', '__pycache__', '.pytest_cache'}
SECRET_PATTERNS = {
    'private-key': r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    'github-token': r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})\b',
    'openai-key': r'\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{30,}\b',
    'aws-access-key': r'\bAKIA[0-9A-Z]{16}\b',
    'bearer-token': r'(?i)bearer\s+[A-Za-z0-9_.-]{35,}',
    'credential-url': r'https?://[^\s/@:]+:[^\s/@]+@',
    'personal-windows-path': r'(?i)[A-Z]:[\\/]+Users[\\/]+(?!Public\b|<)[A-Za-z0-9_-]+[\\/]',
}


def main() -> int:
    errors = []
    catalog = json.loads((ROOT / 'catalog/skills.json').read_text(encoding='utf-8'))
    names = []
    for item in catalog['skills']:
        skill = ROOT / item['path']
        entry = skill / 'SKILL.md'
        if not entry.is_file():
            errors.append(f'{item["path"]}: missing SKILL.md')
            continue
        text = entry.read_text(encoding='utf-8')
        front = re.match(r'\A---\n(.*?)\n---(?:\n|$)', text, re.S)
        if not front:
            errors.append(f'{item["path"]}: missing frontmatter')
            continue
        name = re.search(r'^name:\s*(.+)$', front[1], re.M)
        if not name or name[1].strip().strip('\"\'') != item['name']:
            errors.append(f'{item["path"]}: name mismatch')
        if not re.search(r'^description:\s*\S', front[1], re.M):
            errors.append(f'{item["path"]}: missing description')
        names.append(item['name'])
        for dep in item['dependencies']:
            if not (ROOT / 'skills' / dep).is_dir():
                errors.append(f'{item["name"]}: missing dependency {dep}')
        manifest = skill / 'manifest.yaml'
        if manifest.exists():
            for line in manifest.read_text(encoding='utf-8').splitlines():
                match = re.search(r'(?:^\s*-\s+|:\s+)((?:\.\./|static/|references/)[^\s#]+\.md)\s*(?:#.*)?$', line)
                if match and not (skill / match[1]).is_file():
                    errors.append(f'{manifest.relative_to(ROOT)}: missing {match[1]}')
    if len(names) != len(set(names)):
        errors.append('Duplicate skill names')
    files = [p for p in ROOT.rglob('*') if p.is_file() and not any(v in OMIT for v in p.relative_to(ROOT).parts)]
    for path in files:
        rel = path.relative_to(ROOT).as_posix()
        if path.name in {'auth.json', 'credentials.json', '.env'} or path.suffix in {'.pem', '.key', '.sqlite', '.db'}:
            errors.append(f'{rel}: excluded file type')
        data = path.read_bytes()
        try:
            text = data.decode('utf-8')
        except UnicodeDecodeError:
            continue
        if '\r' in text or text.startswith('\ufeff'):
            errors.append(f'{rel}: expected UTF-8 without BOM and LF line endings')
        for label, pattern in SECRET_PATTERNS.items():
            for m in re.finditer(pattern, text):
                errors.append(f'{rel}:{text.count(chr(10), 0, m.start()) + 1}: {label} (value withheld)')
        if path.suffix == '.json':
            try:
                json.loads(text)
            except ValueError:
                errors.append(f'{rel}: invalid JSON')
        if path.suffix == '.py':
            try:
                ast.parse(text, filename=rel)
            except SyntaxError as exc:
                errors.append(f'{rel}:{exc.lineno}: invalid Python syntax')
    for error in errors:
        print('ERROR ' + error)
    if errors:
        print(f'FAILED: {len(errors)} issue(s)')
        return 1
    print(f'OK: {len(names)} skills; {len(files)} files; structure, resource paths, syntax, text format and common secret-pattern checks passed.')
    print('External services and end-to-end skill behaviors were not exercised.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
