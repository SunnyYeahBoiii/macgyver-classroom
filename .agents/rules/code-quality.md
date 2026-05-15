# Code Quality Rule

Use this rule for implementation, refactoring, and code review.

## Principles

- SOLID: keep modules focused, dependencies explicit, and extension points narrow.
- DRY: remove meaningful duplication, but do not abstract incidental similarity.
- KISS: prefer the smallest clear design that solves the current requirement.
- Local consistency: follow the repository's existing naming, layout, error handling, and test style.
- Small surface area: keep changes scoped to the requested behavior and nearby contracts.
- Composition first: prefer small explicit collaborators over inheritance-heavy or framework-magical designs.
- Testability is design feedback: hard-to-test code usually means boundaries, dependencies, or data flow are unclear.

## Required Checks

- Code has one clear responsibility per function, class, component, module, or service.
- Boundaries are explicit: I/O, business rules, persistence, UI, and orchestration are not mixed without reason.
- Public APIs have stable names, typed inputs/outputs where supported, and predictable failure behavior.
- Error handling is actionable and does not swallow failures silently.
- No unrelated refactors, formatting churn, or dependency additions.
- Comments explain non-obvious intent only; code should carry ordinary meaning itself.
- Dependencies are injected at boundaries when that improves testability or isolates external systems.
- New abstractions remove real complexity or match an existing local pattern; they are not added for speculation.
- Naming is domain-specific, descriptive, and consistent across production code, tests, docs, and API contracts.
- Async work has explicit loading, success, empty, and failure behavior where user-facing or externally observable.
- Logging uses the repo-approved logging mechanism and never leaks secrets, personal data, tokens, or raw credentials.
- Generated code, migrations, schema updates, lockfiles, and config changes are included only when required.

## Framework Rules

- Apply framework-specific rules when present. For Flutter and Dart work, apply `flutter.md` in addition to this rule.
- Framework convenience does not override architecture boundaries, security constraints, or testability.

## Review Standard

Flag issues when the code is harder to change, test, or reason about than the requirement demands. Prefer concrete fixes over broad style opinions.
