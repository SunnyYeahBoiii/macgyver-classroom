---
name: code-review
description: Reviews code for bugs, maintainability, tests, and clean-code issues. Use when asked for code review, PR review, regression risk, SOLID/DRY/KISS assessment, or review against code-quality rules.
---

# Code Review

## Rules

Apply `../../rules/review.md` and `../../rules/code-quality.md` first. Also apply `../../rules/unit-test.md` and `../../rules/ci-readiness.md` when tests or CI are in scope. Apply `../../rules/flutter.md` for Dart or Flutter changes.

## Workflow

1. Read the diff and nearby code before judging.
2. Prioritize bugs, regressions, data loss, security issues, and missing tests.
3. Check SOLID, DRY, KISS, naming, boundaries, and local consistency.
4. Confirm tests cover the changed behavior and meaningful edge cases.
5. Check framework-specific gates, including Flutter gates when Dart or Flutter files are touched.
6. Report findings first. Summaries come after issues.

## Output

If issues exist, list them by severity with file/line references. If no issues are found, say that clearly and mention residual test or CI gaps.
