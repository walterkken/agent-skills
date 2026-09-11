# Validation record

Date: 2026-09-11. Cases contain synthetic material only.

## Executed checks

- The canonical skill passed the skill creator structure validator.
- The bundled audit ran against the adapter itself without finding structural errors in its implemented subset.
- Seven Python regression tests passed: instruction-only packages and no writes, duplicate YAML keys, required field types, optional metadata/policy preservation, invalid invocation type, unsafe YAML tag rejection, and an entrypoint symlink outside the requested folder.
- Repository validation and installer dry-run passed. The audit regression tests are included in repository CI.

Run the reproducible local checks from the repository root with Python 3.9+ and PyYAML:

```bash
python scripts/test_skill_adapter.py
python scripts/validate.py
```

## Independent behavior check

A separate agent loaded Skill Adapter and received a synthetic Abaqus beam skill plus a request to adapt it to a Python/file-editing environment with no Abaqus and no documentation access. It was restricted to a read-only response. It received the original workflow and existing policy/dependency facts, without an expected solution.

Observed: it produced a reviewable replacement that kept INP generation and the original final goal; marked solving and displacement extraction blocked; preserved explicit-only invocation and dependencies; and disclosed the dated offline source baseline. It did not edit, install, or publish files.

Limitation: this was one qualitative scenario. No Abaqus job ran, no whole-host compatibility was established, and no improvement percentage was measured. Planned examples in the skill reference are not all executed evaluations.
