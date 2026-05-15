# Agent Harness

Repository-local agent harness for rules, reusable skills, migrated Claude sub-agents, and legacy command prompts.

## Layout

- `rules/` - shared operating rules used by skills and agents.
- `skills/` - Codex/agent skills in `skill-name/SKILL.md` format.
- `agents/` - migrated Claude sub-agent definitions from `.claude/agents`.
- `commands/` - migrated Claude command prompts from `.claude/commands`.

## Rule Loading

Skills should reference only the rules they need. Common defaults:

- Code work: `rules/code-quality.md`, `rules/tdd.md`, `rules/unit-test.md`
- Review work: `rules/code-quality.md`, `rules/ci-readiness.md`
- Documentation work: `rules/docs-maintainer.md`

