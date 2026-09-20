# TokenOffload

> **Stop spending model tokens on work your computer can do for free.**

TokenOffload is a local-first execution discipline for AI agents. It does not merely ask the model to “be concise.” It changes **where work happens**:

```text
raw files / logs / tables / media
          ↓
OS + local software + scripts + SQL + exact search
          ↓
small, high-signal result
          ↓
AI reasoning only where needed
```

中文一句话：**先让电脑干电脑擅长的活，再让 AI 干必须思考的活。**

[Skill](../../skills/tokenoffload/SKILL.md) · [Token-saving playbook](../../skills/tokenoffload/docs/TOKEN-SAVING-PLAYBOOK.md) · [MIT](../../skills/tokenoffload/LICENSE)

## Why this is different

Many “token saver” approaches focus on shorter prompts or shorter answers. TokenOffload targets a larger source of waste: feeding deterministic intermediate work through the model.

Typical examples:

| Task | Wasteful agent loop | TokenOffload |
| --- | --- | --- |
| CSV analysis | send thousands of rows | local SQL/Python → anomalies only |
| codebase work | reread repository | git diff + symbol search → selected files |
| logs | paste logs | grep/count/dedupe → representative failures |
| PDF | send whole document | local extraction/index → selected sections |
| media | inspect everything semantically | ffprobe/ffmpeg → selected segments |
| file operations | describe every file to AI | filesystem/CLI performs exact operation |

## Execution ladder

**OS → installed software → deterministic code → local index → optional local model → external tools → frontier AI**

The agent escalates only when the lower layer cannot correctly finish the current step.

## Use it

In an agent that supports Skills:

```text
Use $tokenoffload for this task.
```

Or phrase it naturally:

```text
本地优先执行，尽量节省 token，只把必须推理的部分交给 AI。
```

For a capability check:

```bash
python skills/tokenoffload/scripts/tokenoffload.py doctor
```

The helper reports useful local commands if present and never installs software.

## Core techniques

- local-first deterministic execution
- search-before-read and range reads
- filter/aggregate before context
- delta/diff-first workflows
- progressive disclosure
- programmatic tool chaining
- output caps and top-N sampling
- structured state outside the context window
- context compaction
- prompt/result caching
- on-demand tool loading
- model routing and explicit stop conditions

## Design goal

TokenOffload optimizes:

```text
useful reasoning per model token
```

not “minimum tokens at any cost.” If shrinking context would hide evidence or reduce correctness, the skill keeps the necessary evidence.

## Research basis

The playbook incorporates current context-engineering practices documented by OpenAI and Anthropic, including prompt caching, compaction, on-demand tool loading, code-based tool orchestration, filtering before model context, and progressive disclosure. See the linked playbook for sources and implementation notes.

## Search terms

local-first AI agent, token optimization, context engineering, LLM cost optimization, AI agent skill, Codex skill, Claude skill, MCP token reduction, prompt caching, context compression, tool output compression, 本地优先, 省 token, AI 成本优化.
