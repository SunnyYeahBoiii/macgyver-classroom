# Unit Test Rule

Use this rule when adding or reviewing unit tests.

## Required Checks

- Tests verify observable behavior, not implementation trivia.
- Test names describe the condition and expected result.
- Each test has deterministic inputs and does not depend on wall-clock time, network, shared state, or test order.
- Mocks isolate external boundaries only; avoid mocking the code under test.
- Edge cases cover empty, invalid, boundary, and representative happy-path inputs.
- Assertions are specific enough to diagnose failure quickly.

## Maintainability

Prefer small helpers and fixtures over repeated setup. Keep fixtures readable and local unless reuse is clearly valuable.

