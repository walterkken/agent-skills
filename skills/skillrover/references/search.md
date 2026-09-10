# Finding a candidate

Use the search and repository tools the host actually exposes. Inspect installed skills first. If external search is disallowed, work from permitted local sources and describe the coverage accurately.

## Search order

1. Search for the specific missing capability, including the format and a decisive constraint.
2. Follow candidate links to their original repositories. A community directory is a discovery source, not evidence of implementation quality.
3. Open the package, not only the repository README. Large collections can contain good and unsuitable skills side by side.
4. Deduplicate mirrors and renamed copies by upstream attribution and file contents. Three forks of one skill are one underlying option unless they have relevant differences.

Examples for a web search engine:

| Task | Search terms |
| --- | --- |
| Read a long scanned document | `site:github.com "SKILL.md" PDF OCR page ranges` |
| Preserve Word revisions | `site:github.com "SKILL.md" docx tracked changes` |
| Diagnose a browser failure | `site:github.com "SKILL.md" browser trace debugging` |
| Check a manuscript's claims | `site:github.com "SKILL.md" research evidence citations` |

Adapt the syntax to the tool. Web search operators and GitHub code-search operators are not interchangeable. If a tool accepts plain keywords only, use plain keywords.

## Useful starting points

- [OpenAI skills](https://github.com/openai/skills): inspect individual packages and their current requirements.
- [Anthropic skills](https://github.com/anthropics/skills): inspect individual packages and their licenses.
- [skills.sh](https://skills.sh/): discover candidates, then follow the original source.
- [Vercel Skills CLI](https://github.com/vercel-labs/skills): optional search and installation tooling; it is not required by SkillRover.
- [Agent Skills specification](https://agentskills.io/specification): check package structure when compatibility is uncertain.

This is a starting list, not an approved catalog. Recheck the source for the task. Do not silently prefer a package because its author is on this list.

If the Skills CLI is already available and permitted, `skills find <terms>` is another discovery route. `npx skills ...` may download and execute the CLI itself; do not describe it as a purely local read or use it to bypass the host's installation rules. Check current command options in its upstream documentation before using them.

## Incomplete results

An empty result means the query found nothing. It does not prove that no suitable skill exists. Rephrase once using the missing capability. If the search remains blocked or inconclusive, give the best supported local option and say what was not verified.

If the selected result is actually a Python package, hosted service, or MCP server, name it as such. Explain the extra integration it needs instead of presenting it as an installable skill.
