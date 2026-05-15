# TDD Rule

Use this rule for behavior changes, bug fixes, and risky refactors.

## Cycle

1. RED: write or update the smallest test that captures the expected behavior.
2. Verify RED: run the test and confirm it fails for the expected reason.
3. GREEN: make the smallest production change that passes the test.
4. Verify GREEN: run the focused test, then broaden verification as risk grows.
5. REFACTOR: clean up while keeping tests green.

## Required Checks

- Start from observable behavior: user flow, API contract, domain rule, error state, or integration boundary.
- Pin the regression before changing production code when fixing a bug.
- Keep each test failure meaningful; if RED fails for setup noise, fix the test before implementation.
- Broaden from focused tests to package/app checks as blast radius grows.
- Do not weaken assertions, delete coverage, or mark tests skipped unless the reason and follow-up are explicit.
- Prefer dependency seams, fakes, and in-memory adapters over test-only conditionals in production code.

## Flutter

- Apply `flutter.md` for Flutter and Dart work.
- Use the Dart `run_tests` tool when available; otherwise run `flutter test`.
- Add or update `integration_test` coverage for changed end-to-end flows, platform navigation, or critical teacher journeys.

## Exceptions

Tests may follow implementation for mechanical migration, generated files, documentation-only changes, or build/config changes where no useful failing test exists. Document the reason.

## Standard

Do not use TDD as ceremony. Use it to pin behavior, expose edge cases, and make refactors safe.
