#!/usr/bin/env python3
"""Regression tests for the adapter's read-only audit, using synthetic files."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'skills/skill-adapter/scripts/audit_skill.py'
spec = importlib.util.spec_from_file_location('audit_skill', SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class AuditTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'skill'
        self.root.mkdir()
        (self.root / 'SKILL.md').write_text('---\nname: sample\ndescription: Describe a sample task.\n---\nDo the task.\n')

    def test_instruction_only_and_no_writes(self):
        before = {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        result = module.audit(self.root)
        self.assertEqual(result['status'], 'partial-check-passed')
        self.assertEqual(before, {p: p.read_bytes() for p in self.root.rglob('*') if p.is_file()})
        self.assertFalse(result['files_changed'])

    def test_duplicate_yaml_is_not_silently_overwritten(self):
        (self.root / 'SKILL.md').write_text('---\nname: sample\nname: other\ndescription: Task\n---\nTask')
        self.assertEqual(module.audit(self.root)['status'], 'issues-found')

    def test_required_fields(self):
        (self.root / 'SKILL.md').write_text('---\nname: sample\ndescription: []\n---\nTask')
        self.assertIn('required-field', [f['code'] for f in module.audit(self.root)['findings']])

    def test_optional_fields_and_policy_preserved(self):
        (self.root / 'SKILL.md').write_text('---\nname: sample\ndescription: Task\nmetadata:\n  custom: value\n---\nTask')
        ui = self.root / 'agents/openai.yaml'
        ui.parent.mkdir()
        ui.write_text('policy:\n  allow_implicit_invocation: false\ndependencies:\n  tools: []\n')
        before = ui.read_bytes()
        self.assertEqual(module.audit(self.root)['status'], 'partial-check-passed')
        self.assertEqual(ui.read_bytes(), before)

    def test_invalid_policy_type(self):
        ui = self.root / 'agents/openai.yaml'
        ui.parent.mkdir()
        ui.write_text('policy:\n  allow_implicit_invocation: "false"\n')
        self.assertEqual(module.audit(self.root)['status'], 'issues-found')

    def test_unsafe_yaml_tag_rejected(self):
        (self.root / 'SKILL.md').write_text('---\nname: sample\ndescription: !!python/object:builtins.object {}\n---\nTask')
        self.assertEqual(module.audit(self.root)['status'], 'issues-found')

    def test_external_file_link_is_not_read(self):
        outside = Path(self.temp.name) / 'outside.md'
        outside.write_text('---\nname: external\ndescription: External\n---\nTask')
        (self.root / 'SKILL.md').unlink()
        (self.root / 'SKILL.md').symlink_to(outside)
        self.assertEqual(module.audit(self.root)['status'], 'issues-found')


if __name__ == '__main__':
    unittest.main()
