# TokenOffload Token-Saving Playbook

This document collects practical methods for reducing LLM token consumption without turning “shorter” into “less correct.”

## 1. Move deterministic work outside the model

The highest-leverage pattern is often not prompt compression. It is **execution offload**.

Use local software or code for:
- file discovery and metadata
- exact search and regex
- parsing and format conversion
- sorting, grouping, joins, statistics
- compilation, linting, tests
- Git diffs and hashes
- archive operations
- media metadata and deterministic transforms
- SQL queries
- schema validation

Return only the result needed for model reasoning.

Anthropic describes the same architectural benefit for code execution with MCP: tool definitions can be loaded only when needed, and large results can be filtered in the execution environment before reaching the model. In one documented example, their tool-loading approach reduced context from 150,000 tokens to 2,000 for that workflow.

Source: https://www.anthropic.com/engineering/code-execution-with-mcp

## 2. Search before read

Use:
- filename/path search
- ripgrep/grep
- symbol search
- headings/table of contents
- PDF page ranges
- SQL WHERE clauses
- indexed retrieval

Then read the selected range. Avoid “open everything and let the model find it.”

## 3. Progressive disclosure

Expose cheap metadata first:
1. names
2. descriptions
3. schemas/headings
4. selected excerpts
5. full content only if needed

This applies to both files and tool definitions.

## 4. Filter and aggregate tool results

A tool should not return 10,000 records if the model needs:
- count by category
- top 10
- rows failing a rule
- changed records
- a few representative examples

Prefer code/SQL aggregation before the LLM.

## 5. Delta over full state

Prefer:
- `git diff` over repository rereads
- modified files over whole folders
- newly arrived messages over inbox snapshots
- changed cells over whole sheets
- incremental indexes over full re-indexing
- hashes/mtime to skip unchanged inputs

## 6. Persist compact state outside context

For long tasks, save a small state file with:
- goal
- constraints
- decisions
- current artifact/version
- unresolved issues
- next action

Reload this state instead of replaying raw history.

Anthropic's context-engineering guidance discusses compaction and structured note-taking as ways to maintain long-running agents while reducing context pollution.

Source: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

## 7. Compact stale history

After a milestone:
- preserve decisions and constraints
- preserve unresolved errors
- preserve artifact references
- discard redundant raw tool output
- discard resolved exploration paths

Compaction should maximize recall first; aggressive compression can lose details that later matter.

## 8. Load tools on demand

Large tool schemas themselves consume input context. Use tool search/deferred loading when supported. Keep only high-frequency core tools loaded.

OpenAI's Agents API describes tool search as a way to load relevant tool definitions as needed, and programmatic tool calling as a way to chain/filter operations before returning results to the model.

Source: https://openai.com/index/introducing-the-agents-api/

## 9. Programmatic orchestration

If a workflow needs 20 deterministic tool operations, prefer one code block/loop that:
- performs all calls
- handles branching/errors
- filters results
- returns one compact summary

This avoids repeated model round trips and intermediate-result context.

## 10. Prompt caching

When the API/host supports it:
- keep stable system/developer instructions first
- keep stable tool definitions/order
- append dynamic user/task data later
- use explicit cache breakpoints where available and useful
- monitor cached-token metrics instead of assuming savings

OpenAI documents prompt caching for reusable prefixes and notes that stable prefixes/tool definitions improve cache reuse.

Source: https://developers.openai.com/api/docs/guides/prompt-caching

## 11. Result caching

Cache deterministic expensive outputs keyed by:
- file hash
- command/version
- parameters
- schema version

Examples:
- extracted PDF text
- code index
- media probe metadata
- test discovery
- dataset schema/profile
- dependency graph

Invalidate when inputs change.

## 12. Route by task difficulty

Do not use the strongest model for every step.

A practical routing policy:
- deterministic → no model
- narrow semantic classification → small/cheap model if reliable
- complex reasoning/generation → strong model
- verification → deterministic tests first, model second

Model routing should be benchmarked on the actual task; token savings are not useful if error/rework rates rise.

## 13. Cap outputs

For commands/tools, set default caps:
- top N
- first/last N lines
- error-only
- selected columns
- counts + samples
- pagination

Always state the selection rule when omitted data could matter.

## 14. RAG discipline

For retrieval:
- query narrowly
- use metadata filters
- deduplicate chunks
- rerank
- cap top-k
- expand only on insufficient evidence
- avoid sending near-duplicate chunks

## 15. Separate evidence from explanation

Keep raw evidence in files or tool state. Send the model only:
- identifiers
- relevant excerpts
- computed statistics
- citations/pointers

Do not duplicate the same evidence in prompt, tool result, and assistant narration.

## 16. Use structured outputs only when they help

Schemas can reduce retries and parsing ambiguity, but large schemas also cost tokens. Use the smallest schema that downstream code actually needs.

## 17. Stop conditions

Define acceptance criteria before execution:
- tests pass
- requested fields generated
- output validates
- target file exists
- diff contains only scoped changes

Stop when criteria pass. Optional polishing is a separate task.

## 18. Measure real savings

Track:
- input tokens
- cached input tokens
- output tokens
- number of model calls
- tool-result bytes/tokens
- latency
- task success / rework rate

A token optimizer should improve **cost per successful task**, not just token count.

## TokenOffload rule of thumb

> If a CPU can deterministically reduce the input before the model sees it, let the CPU do it.
