# Code Quality Rule

Use this rule for implementation, refactoring, and code review.

## Principles

- SOLID: keep modules focused, dependencies explicit, and extension points narrow.
- DRY: remove meaningful duplication, but do not abstract incidental similarity.
- KISS: prefer the smallest clear design that solves the current requirement.
- Local consistency: follow the repository's existing naming, layout, error handling, and test style.
- Small surface area: keep changes scoped to the requested behavior and nearby contracts.

## Required Checks

- Code has one clear responsibility per function, class, component, module, or service.
- Boundaries are explicit: I/O, business rules, persistence, UI, and orchestration are not mixed without reason.
- Public APIs have stable names, typed inputs/outputs where supported, and predictable failure behavior.
- Error handling is actionable and does not swallow failures silently.
- No unrelated refactors, formatting churn, or dependency additions.
- Comments explain non-obvious intent only; code should carry ordinary meaning itself.

## Review Standard

Flag issues when the code is harder to change, test, or reason about than the requirement demands. Prefer concrete fixes over broad style opinions.

