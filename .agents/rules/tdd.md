# TDD Rule

Use this rule for behavior changes, bug fixes, and risky refactors.

## Cycle

1. RED: write or update the smallest test that captures the expected behavior.
2. Verify RED: run the test and confirm it fails for the expected reason.
3. GREEN: make the smallest production change that passes the test.
4. Verify GREEN: run the focused test, then broaden verification as risk grows.
5. REFACTOR: clean up while keeping tests green.

## Exceptions

Tests may follow implementation for mechanical migration, generated files, documentation-only changes, or build/config changes where no useful failing test exists. Document the reason.

## Standard

Do not use TDD as ceremony. Use it to pin behavior, expose edge cases, and make refactors safe.

