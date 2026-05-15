# Claude To Agents Migration Manifest

Generated on 2026-05-15.

## Migrated

- `.claude/agents/*.md` -> `.agents/agents/*.md`
- `.claude/commands/*.md` -> `.agents/commands/*.md`
- `.claude/settings.json` -> `.agents/claude-settings.json`

## Generated

- `.agents/rules/code-quality.md`
- `.agents/rules/docs-maintainer.md`
- `.agents/rules/ci-readiness.md`
- `.agents/rules/tdd.md`
- `.agents/rules/unit-test.md`
- `.agents/skills/security-review/SKILL.md`
- `.agents/skills/code-review/SKILL.md`
- `.agents/skills/debug/SKILL.md`
- `.agents/skills/tdd/SKILL.md`

## Added After Migration

- `.agents/rules/review.md`
- `.agents/rules/flutter.md`
- `.agents/agents/flutter-implementer.md`

## Notes

- Source `.claude/skills` was not present in this repository.
- Source `.claude/rules` was present but empty.
- Legacy Claude commands are preserved under `.agents/commands` instead of being rewritten as Codex skills, so generated example skills can stay clean and conflict-free.
