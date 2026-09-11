# Skill Adapter

Adapt an existing agent skill to its actual environment and task evidence.

A downloaded skill may assume a tool you do not have. A description may trigger for unrelated tasks. A patch may fix one example while breaking another. Skill Adapter identifies the specific mismatch, changes the affected part, and checks the original purpose still holds.

[中文](README.md) · [SKILL.md](../../skills/skill-adapter/SKILL.md) · [Validation](VALIDATION.md)

## Try it

```text
Use $skill-adapter to adapt this skill to current OpenAI guidance and my
available tools. Preserve its purpose, explain the changes, and report
which checks actually ran.
```

It covers specification checks, environment migration, and improvements grounded in observed failures. Missing tools remain visible blockers. A single short-answer request does not become a permanent length limit. Existing invocation policy and dependencies are preserved unless a relevant change is requested.

This is an instruction package executed by a supporting assistant. It is not a background self-modifying service. The included Python audit is read-only and checks a small structural subset; the assistant handles diagnosis, scoped edits, and behavioral checks.

## Install for local Codex

```bash
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills skill-adapter --target "$HOME/.agents/skills" --dry-run
python scripts/install.py --skills skill-adapter --target "$HOME/.agents/skills"
```

Existing folders are not overwritten. Other hosts require their own supported installation workflow. This repository is not a plugin-directory listing.

## Run the partial audit

Python 3.9+ and PyYAML are required:

```bash
python -m pip install PyYAML
python skills/skill-adapter/scripts/audit_skill.py /path/to/skill
```

The JSON result lists findings and unchecked areas. Exit codes: 0 for no errors in implemented checks, 1 for structural issues, 2 for unavailable dependencies or invalid arguments. It does not execute target scripts or modify files.

## Basis and limits

The dated source reference points to [OpenAI's skill authoring guidance](https://learn.chatgpt.com/docs/build-skills), checked 2026-09-11. The adapter refreshes documentation when possible and discloses offline uncertainty. This is an independent project, not an OpenAI certification. No general success-rate improvement has been measured.

Report a reproducible issue with a sanitized skill, environment, expected behavior, and actual result. Contributions should keep the original task contract intact.

[MIT license](../../skills/skill-adapter/LICENSE).
