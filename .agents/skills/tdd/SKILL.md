---
name: tdd
description: Drives test-first implementation for features, bug fixes, and risky refactors. Use when asked for TDD, red-green-refactor, test-first development, or behavior changes that need regression coverage.
---

# TDD

## Rules

Apply `../../rules/tdd.md` and `../../rules/unit-test.md`.

## Workflow

1. Identify the smallest externally visible behavior.
2. Write the focused failing test first.
3. Run it and confirm the failure proves the missing behavior.
4. Implement the minimum production change.
5. Run the focused test until green.
6. Refactor only after green.
7. Broaden tests or CI checks when the change touches shared contracts.

## Output

Report the RED command/result, GREEN command/result, files changed, and any skipped verification with reason.

