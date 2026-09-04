#!/usr/bin/env python3
"""Copy selected skills to an explicit destination without overwriting files."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    catalog = json.loads((ROOT / 'catalog/skills.json').read_text(encoding='utf-8'))
    available = {item['name']: item for item in catalog['skills']}
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', type=Path, help='Explicit destination skills directory')
    parser.add_argument('--skills', nargs='+', help='Names to install; prefix a leading-hyphen name using --skills=-21risk-automation')
    parser.add_argument('--list', action='store_true', help='List available skills')
    parser.add_argument('--dry-run', action='store_true', help='Print the plan without writing')
    args = parser.parse_args()
    if args.list:
        for name, item in available.items():
            print(f"{name}: {item['description_zh']}")
        return 0
    if args.target is None:
        parser.error('--target is required for installation or --dry-run')
    names = args.skills if args.skills else [n for n, i in available.items() if not i['windows_only']]
    unknown = sorted(set(names) - set(available))
    if unknown:
        parser.error('Unknown skills: ' + ', '.join(unknown))
    names = list(dict.fromkeys(names))
    if any(available[n]['dependencies'] for n in names):
        names.append('_shared')
    target = args.target.expanduser().resolve()
    if target == ROOT or ROOT in target.parents:
        parser.error('Choose a destination outside this repository')
    # Check every destination before writing anything. Existing identical shared
    # resources can be reused; all other collisions require manual resolution.
    plan = []
    for name in names:
        source = ROOT / 'skills' / name
        dest = target / name
        if dest.exists() or dest.is_symlink():
            if name == '_shared' and dest.is_dir() and all(
                (dest / p.relative_to(source)).is_file()
                and p.read_bytes() == (dest / p.relative_to(source)).read_bytes()
                for p in source.rglob('*') if p.is_file()
            ):
                print(f'REUSE {dest}')
                continue
            parser.error(f'Destination already exists; no files were copied: {dest}')
        plan.append((source, dest))
    for source, dest in plan:
        print(f'{"PLAN" if args.dry_run else "COPY"} {source.name} -> {dest}')
    if not args.dry_run:
        for source, dest in plan:
            shutil.copytree(source, dest)
    if args.skills is None:
        print('sync-overleaf-local requires separate installation; see docs/INSTALL.md.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
