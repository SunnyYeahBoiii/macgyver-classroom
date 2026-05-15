# Review Rule

Use this rule for code review, PR review, regression-risk review, and review of tests or implementation plans.

## Required Checks

- Review the diff, nearby code, relevant tests, and changed contracts before judging.
- Findings lead the response and are ordered by severity.
- Each finding includes file/line evidence, impact, and a concrete fix direction.
- Prioritize bugs, regressions, data loss, security/privacy issues, broken contracts, missing tests, and CI risk.
- Check SOLID, DRY, KISS, naming, boundaries, dependency direction, error handling, observability, and local consistency.
- Confirm tests cover changed behavior, edge cases, and failure paths at the right level.
- Treat missing or weak tests as findings when they leave realistic regression risk.
- Do not report broad style preferences unless they affect correctness, maintainability, accessibility, performance, or testability.

## Flutter Review

- Apply `flutter.md` for Dart and Flutter changes.
- Check route typing, `ValueNotifier` state, `json_serializable` snake_case models, null safety, and `dart:developer` logging.
- Check Material 3 theming, dark mode, accessibility semantics, 4.5:1 text contrast, responsive layouts, and list/build performance.
- Verify `const`, `ListView.builder`/slivers for long lists, and `compute()` for heavy UI-thread work where relevant.
- Require `flutter test` or the Dart `run_tests` tool for changed Flutter behavior; require `integration_test` for critical flows.

## Output Standard

- If issues exist, list findings first by severity with file/line references.
- If no issues are found, say so clearly and mention residual test or CI gaps.
- Put open questions after findings.
- Keep summaries short and secondary to the findings.
