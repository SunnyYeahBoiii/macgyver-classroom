# Unit Test Rule

Use this rule when adding or reviewing unit tests.

## Required Checks

- Tests verify observable behavior, not implementation trivia.
- Test names describe the condition and expected result.
- Each test has deterministic inputs and does not depend on wall-clock time, network, shared state, or test order.
- Mocks isolate external boundaries only; avoid mocking the code under test.
- Edge cases cover empty, invalid, boundary, and representative happy-path inputs.
- Assertions are specific enough to diagnose failure quickly.
- Arrange-Act-Assert or Given-When-Then structure is clear without excessive comments.
- External I/O is replaced with fakes, stubs, in-memory implementations, or injected adapters.
- Error-path tests assert both failure result and useful diagnostics when diagnostics are part of behavior.
- Snapshot/golden tests are used only when the visual contract is stable and reviewed intentionally.
- Tests do not depend on production ordering unless ordering is the behavior under test.

## Flutter

- Apply `flutter.md` when testing Flutter or Dart code.
- Unit-test domain logic, data mappers, repositories, and state objects.
- Widget-test reusable UI, screen state, semantics labels, empty/error/loading states, and dark mode when relevant.
- Use `integration_test` for end-to-end flows, routing, platform interactions, and critical happy paths.
- Prefer fakes and stubs over generated mocks. Use `mockito` or `mocktail` only when fakes would hide the behavior under test.
- Prefer `package:checks` assertions when available in the project.

## Maintainability

Prefer small helpers and fixtures over repeated setup. Keep fixtures readable and local unless reuse is clearly valuable.
