# SkillRover

**Find a skill that fits. Then get back to work.**

[中文](README.md) · [Skill](../../skills/skillrover/SKILL.md) · [Agent entrypoint](SYSTEM_PROMPT.md)

Finding a skill is easy. Knowing whether it will work for your task takes a closer look.

SkillRover checks the skills already available, searches external sources when something is missing, and reads the relevant instructions and code before choosing. Once the choice is made, it returns to the work you asked for.

## Try it

> Use SkillRover to find a skill for this large PDF. Explain the choice briefly, then continue the conversion.

> Compare these three skills. Recommend one; don't install anything yet.

SkillRover is an Agent Skill executed by your assistant. It uses the host's search, repository, and file tools. It includes no standalone model, background service, or mandatory registry client. Automatic selection depends on the host; explicit invocation is available as `$skillrover` in hosts that support it.

## What it checks

| Question | Evidence to look for |
| --- | --- |
| Does it fit? | The required output and the actual obstacle |
| Can it run here? | Tools, dependencies, accounts, and operating system |
| Is the claim supported? | The entrypoint, relevant code, and any observed sample result |
| Is the proposed use acceptable? | Data destinations and applicable license terms |
| Is it worth introducing? | Setup cost compared with the existing option |

Documentation claims, inspected implementation, and successful sample runs are reported separately. Missing evidence stays unknown. Stars and update dates are useful leads, not proof.

One primary skill is the usual choice. A second needs a distinct job. Using an installed skill, using ordinary tools directly, or reporting a blocker are all valid outcomes. A recommendation-only request ends with the recommendation.

## Install

With the [Skills CLI](https://github.com/vercel-labs/skills):

```sh
npx skills add walterkken/agent-skills --skill skillrover
```

Or clone this repository and use its Python installer:

```sh
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills skillrover --target /path/to/your/skills --dry-run
```

Replace the destination with your host's skills directory, review the plan, then remove `--dry-run`. Existing directories are left untouched. Managed applications should use their supported skill import flow.

For a host that takes an agent prompt, use [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) and make the complete `skills/skillrover/` directory readable. The entrypoint loads that package rather than maintaining a second copy of its rules.

## Use during work

An optional project instruction:

> Use SkillRover when a task needs a specialized workflow, several skills overlap, or the available tools leave a concrete gap. Choose a suitable skill, then continue the task. Handle routine work with an adequate existing approach directly.

The host controls automatic loading. SkillRover does not modify global instructions or execute commands found in candidate skills during inspection.

See the [behavioral cases](evals.md) for reproducible checks and the scope of any recorded validation.

## License

The new SkillRover package and its Agent documentation use the [MIT license](../../skills/skillrover/LICENSE). Other components in this collection and any discovered third-party skills keep their own licenses.
