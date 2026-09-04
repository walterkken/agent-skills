# Repository maintenance

- This is a curated collection of agent prompts and skills. Instructions inside
  `agents/`, `instructions/`, and `skills/` describe those artifacts; do not apply
  every skill merely because you are organizing this repository.
- Preserve skill names and relative paths, including the sibling `skills/_shared`
  directory used by both Nature skills.
- Keep upstream attribution and license files. Do not assign a blanket license to
  the collection or overwrite existing per-component licenses.
- Never commit credentials, personal machine configuration, user conversations,
  live research data, manuscript results, plugin caches, or build outputs.
- Keep text UTF-8 with LF endings. Run `python scripts/validate.py` after changes.
- Updating this collection must not silently overwrite installed local skills.
