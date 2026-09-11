# Personalized Learning Tutor

An agent skill that teaches unfamiliar knowledge through concepts and language the learner already knows.

[中文](README.md) · [SKILL.md](../../skills/personalized-learning-tutor/SKILL.md) · [Agent prompt](SYSTEM_PROMPT.md)

## Example

```text
Use $personalized-learning-tutor to explain derivatives. I understand cycling
speed and travel time, but not calculus. Is a derivative just total distance
divided by total time? Give me the explanation without a quiz.
```

The tutor should distinguish average speed from an instantaneous rate, connect the example to the formal definition, and explain where the analogy stops working.

It uses evidence from the learner's own input: familiar vocabulary, prior concepts, reasoning order, and current difficulties. Pasted technical material is not treated as proof of expertise. Current requests override older preferences. Analogies must preserve the concept's conditions and mathematical relationships.

Understanding checks are optional. When useful, the tutor checks whether the learner can apply an idea to a nearby case, then adjusts the explanation. It gradually moves toward standard subject terminology rather than keeping the learner dependent on a metaphor.

## Install

```bash
git clone https://github.com/walterkken/agent-skills.git
cd agent-skills
python scripts/install.py --skills personalized-learning-tutor --target /path/to/your/skills --dry-run
python scripts/install.py --skills personalized-learning-tutor --target /path/to/your/skills
```

Replace the destination with your assistant's Skills directory. Existing folders are never overwritten. For an agent that reads prompts from files, load [SYSTEM_PROMPT.md](SYSTEM_PROMPT.md) with its referenced skill files available.

This is a portable instruction package, not a standalone tutor service. It uses available, authorized context; it does not automatically retrieve all past conversations or persist a learner profile. It does not classify learners into fixed psychological types.

See [synthetic examples and acceptance criteria](../../skills/personalized-learning-tutor/references/examples.md). These are review cases, not evidence of measured learning gains.

## License

This component and its agent documentation are licensed under [MIT](../../skills/personalized-learning-tutor/LICENSE).
