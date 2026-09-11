#!/usr/bin/env python3
"""Read-only, partial skill structure audit. Requires Python 3.9+ and PyYAML."""
import argparse
import json
from pathlib import Path
import sys

try:
    import yaml
except ImportError:
    print(json.dumps({'status': 'unavailable', 'error': 'PyYAML is required; no files were changed.'}))
    sys.exit(2)


class UniqueSafeLoader(yaml.SafeLoader):
    """Reject duplicate keys instead of silently accepting the last value."""


def unique_mapping(loader, node, deep=False):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        try:
            duplicate = key in result
        except TypeError as exc:
            raise ValueError('YAML mapping keys must be hashable') from exc
        if duplicate:
            raise ValueError('Duplicate YAML mapping key')
        result[key] = loader.construct_object(value_node, deep=deep)
    return result


UniqueSafeLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, unique_mapping)


def audit(root):
    root = Path(root).resolve()
    findings = []

    def add(level, code, message):
        findings.append(dict(level=level, code=code, message=message))

    def read(relative):
        path = root / relative
        if not path.resolve().is_relative_to(root):
            raise ValueError('File resolves outside the requested skill folder')
        return path.read_text(encoding='utf-8-sig')

    try:
        lines = read('SKILL.md').splitlines()
        if not lines or lines[0].strip() != '---':
            raise ValueError('Missing opening YAML frontmatter delimiter')
        end = next((i for i in range(1, len(lines)) if lines[i].strip() == '---'), None)
        if end is None:
            raise ValueError('Missing closing YAML frontmatter delimiter')
        meta = yaml.load('\n'.join(lines[1:end]), Loader=UniqueSafeLoader)
        if not isinstance(meta, dict):
            raise ValueError('Frontmatter must be a YAML mapping')
        for key in ('name', 'description'):
            if not isinstance(meta.get(key), str) or not meta[key].strip():
                add('error', 'required-field', key + ' must be a nonempty string')
        if not '\n'.join(lines[end + 1:]).strip():
            add('warning', 'empty-body', 'No task instructions found; inspect intended behavior')
        # Preserve optional fields. Their validity belongs to the selected host/spec.
        extras = sorted(str(k) for k in meta if k not in ('name', 'description'))
        if extras:
            add('review', 'optional-metadata', 'Additional frontmatter fields retained for host-specific review')
    except (OSError, UnicodeError, ValueError, yaml.YAMLError, RecursionError):
        add('error', 'entrypoint-unreadable', 'Cannot read or parse SKILL.md; inspect file, encoding, delimiters, and YAML keys')

    ui_path = root / 'agents/openai.yaml'
    if ui_path.exists() or ui_path.is_symlink():
        try:
            ui = yaml.load(read('agents/openai.yaml'), Loader=UniqueSafeLoader)
            if not isinstance(ui, dict):
                raise ValueError('UI configuration must be a mapping')
            for key in ('interface', 'policy', 'dependencies'):
                if key in ui and not isinstance(ui[key], dict):
                    raise ValueError('UI section must be a mapping')
            policy = ui.get('policy', {})
            if 'allow_implicit_invocation' in policy and type(policy['allow_implicit_invocation']) is not bool:
                add('error', 'invocation-type', 'allow_implicit_invocation must be a YAML boolean')
        except (OSError, UnicodeError, ValueError, yaml.YAMLError, RecursionError):
            add('error', 'ui-unreadable', 'Cannot read or parse agents/openai.yaml; inspect mappings and file access')

    return dict(
        status='issues-found' if any(f['level'] == 'error' for f in findings) else 'partial-check-passed',
        findings=findings,
        unchecked=['current official documentation', 'complete specification and naming rules',
                   'resource links', 'script safety and execution', 'tool availability',
                   'trigger behavior', 'task success'],
        files_changed=False,
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('skill', type=Path, help='One skill folder; never modified')
    args = parser.parse_args()
    result = audit(args.skill)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 1 if result['status'] == 'issues-found' else 0


if __name__ == '__main__':
    sys.exit(main())
