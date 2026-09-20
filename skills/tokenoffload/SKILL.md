---
name: tokenoffload
description: "Reduce LLM token use and context pollution by routing deterministic input/output work to the local computer first. Use for coding, file processing, document conversion, search, extraction, data cleanup, Git operations, media inspection, repetitive transformations, or any workflow where local OS tools, installed software, scripts, SQL, regex, or lightweight local computation can finish or shrink work before AI reasoning. Trigger on TokenOffload, local-first, save tokens, reduce context, 省token, 本地优先. Do not sacrifice correctness, safety, or necessary reasoning merely to reduce tokens."
---

# TokenOffload

**Computer first. Model last.**

Minimize model context by moving deterministic work out of the LLM loop. The model should receive the smallest high-signal representation that still permits a correct decision.

## Default execution ladder

Use the first layer that can correctly complete the step. Escalate only when the current layer cannot finish the task.

1. **Native OS / filesystem** — paths, metadata, copy/move, archive, hashes, file counts, exact text lookup.
2. **Installed local software / CLI** — Git, Office/LibreOffice automation, ffmpeg, ImageMagick, pdftotext, pandoc, ripgrep, jq, sqlite3, compilers, test runners, package tools.
3. **Deterministic local code** — Python/JS/shell for parsing, filtering, sorting, joins, statistics, regex, format conversion, validation, diffing, deduplication.
4. **Local index or database** — SQL, FTS, local search, cached metadata, embeddings already present on device.
5. **Optional local model** — only when a small local model is already available and the task genuinely needs semantic interpretation.
6. **External tools / APIs** — only for data or actions unavailable locally.
7. **Cloud/frontier AI** — ambiguity resolution, synthesis, judgment, explanation, design, hard reasoning, or generation that deterministic tools cannot do well.

Never call a higher layer merely because it is convenient.

## First input/output rule

Before asking a model to inspect raw input, ask:

- Can the computer identify the file, type, size, structure, metadata, row count, headings, symbols, diffs, or exact matches without AI?
- Can local software perform the requested first transformation exactly?
- Can code reduce the input to a small exception set, summary table, diff, top-k result, or failing cases?
- Does the model need the raw content, or only the local result?

If local execution can produce the first useful output, do it there. Pass only the result required for the next reasoning step.

Examples:

- 10,000 CSV rows → local SQL/Python aggregation → send 12 anomalous rows.
- Repository → `git diff` + targeted `rg` → send changed functions, not the whole tree.
- PDF → local text extraction + heading/range selection → send relevant pages/sections.
- Video → ffprobe/ffmpeg scene timestamps → send selected frames/transcript segments.
- Folder → local filename/metadata index → send matching paths only.
- Logs → grep/regex/counts → send representative errors and frequencies.
- Reformat/rename/convert → local deterministic tool → AI only verifies edge cases.

## Context budget rules

1. **Search before read.** Locate relevant files/lines first; do not open entire corpora by default.
2. **Read ranges, not blobs.** Prefer line/page/range selection and pagination.
3. **Filter before return.** Tool output should contain only fields needed for the decision.
4. **Aggregate before explain.** Count, sort, group, dedupe, diff, and validate locally.
5. **Delta over snapshot.** Prefer Git diff, changed rows, new messages, modified timestamps, and hashes.
6. **Persist state outside context.** Store durable decisions, indexes, manifests, and handoff notes in files; reload only what is relevant.
7. **Compact long sessions.** Replace stale raw tool output with a faithful task state: goals, decisions, unresolved issues, changed artifacts, next action.
8. **Load tools on demand.** Do not expose large tool catalogs when only one or two tools are needed.
9. **Batch deterministic calls.** Use code/loops to chain operations and return one compact result instead of repeated model round trips.
10. **Cache stable prefixes/results.** Reuse unchanged instructions, schemas, summaries, indexes, and expensive deterministic outputs.
11. **Stop when acceptance criteria pass.** Do not spend tokens on optional polishing unless requested.
12. **Keep final output proportional.** Return the answer, changed files, and unresolved risks; do not narrate every local operation.

## Routing heuristic

For each subtask assign:

- **D0 — exact/deterministic:** local only.
- **D1 — deterministic with small validation:** local first; model sees exceptions.
- **S1 — semantic but narrow:** retrieve/filter locally; model sees targeted evidence.
- **R1 — reasoning/generation:** model handles the irreducible core.

A good workflow pushes as much work as possible toward D0/D1 without changing task semantics.

## High-value token-saving patterns

### 1. Programmatic tool orchestration
When several tools can be chained in code, keep intermediate data inside the execution environment and return only the final filtered result.

### 2. Progressive disclosure
Start with names, metadata, schemas, headings, or summaries. Load full definitions/content only for selected items.

### 3. Diff-first editing
For an existing project, inspect changed files and relevant symbols before scanning the repository. After editing, validate using tests/lint/diff rather than rereading everything.

### 4. Query-first documents
Use indexes, exact search, headings, page ranges, SQL, or local grep before sending document bodies.

### 5. Structured handoff
Maintain a small `TOKENOFFLOAD_STATE.md` when a task spans sessions:
- goal
- constraints
- decisions
- changed files
- unresolved items
- next command/action

Do not store raw logs unless they are needed as evidence.

### 6. Cache-aware prompts
Keep stable instructions/tool definitions in a stable prefix and append changing task data later when the host/model supports prompt caching.

### 7. Output caps
Limit command output by default. Prefer top-N, counts, selected columns, error-only output, or representative samples. Expand only when the compact result is insufficient.

## Quality and safety floor

Token reduction is subordinate to correctness.

- Do not omit evidence necessary for a high-stakes decision.
- Do not silently truncate data when omitted records could change the conclusion; report the selection rule.
- Do not run destructive local commands, overwrite files, install software, send external data, or change accounts without the same authorization normally required by the host agent.
- Treat local files as potentially sensitive. Keep data local when remote access is unnecessary.
- Do not use a local model merely to avoid cloud tokens if its lower capability would materially reduce reliability.
- If a local tool fails, inspect the error once, adjust specifically, then escalate. Avoid blind retry loops.

## Minimal operating loop

1. Parse the user's end goal and acceptance criteria.
2. Inventory local capabilities relevant to the task.
3. Split work into D0/D1/S1/R1.
4. Execute D0/D1 locally.
5. Compress results into the smallest sufficient evidence set.
6. Use AI only for S1/R1.
7. Validate locally where possible.
8. Return the artifact/result and any unresolved limitation.

For a quick local capability inventory, run:

```bash
python scripts/tokenoffload.py doctor
```

The helper is read-only and uses only the Python standard library.
