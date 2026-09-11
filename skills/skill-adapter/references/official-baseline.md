# Official baseline

Checked: 2026-09-11. Refresh these sources when adapting; this file is a dated reference, not a live specification or an endorsement.

Primary source: [OpenAI — Build skills](https://learn.chatgpt.com/docs/build-skills). The [Codex skills URL](https://developers.openai.com/codex/skills/) redirected there when checked.

The documented baseline is a skill folder with `SKILL.md`, including `name` and `description`. Scripts, references, assets, and `agents/openai.yaml` are optional. Discovery uses the name and description before full instructions are loaded. Descriptions should make the intended scope clear. UI metadata may declare dependencies and invocation policy. Automatic invocation defaults to enabled; setting it false retains explicit invocation.

The page recommends a focused job and testing trigger behavior. It documents local Codex skill locations separately from plugin distribution. Verify the target host's current install procedure rather than treating a directory used by one environment as universal. For broad installable distribution, the page recommends plugins; a GitHub skill folder alone is not a plugin-directory listing.

## Adapter decisions, not official rules

The audit script is deliberately a partial local check. Its warnings and review reminders are this project's heuristics. It does not contact OpenAI, validate tools, certify safety, or decide semantic quality. The two-revision stopping condition, preservation contract, and adaptation cases are project choices.

Keep requirement evidence in a compact table when useful:

| Finding | Kind | Evidence | Intended fix | Verification |
| --- | --- | --- | --- | --- |
| Missing description | Documented field | Official page, checked date | Describe the actual task | Parse metadata and test matching |
| Solver unavailable | Environment | Tool inventory / command result | Explain blocker; preserve deliverable | Native run remains untested |
| One response too long | Task evidence | Authorized example | Respect requested length in that mode | Check same and nearby requests |
