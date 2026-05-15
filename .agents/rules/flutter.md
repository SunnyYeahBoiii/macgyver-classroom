# Flutter Rule

Use this rule for Flutter and Dart implementation, review, testing, and CI readiness.

## Role

- Act as an expert Flutter/Dart developer.
- Produce premium, beautiful, maintainable code with clear architecture and strong tests.
- Explain Dart-specific features such as null safety, `Future`, `Stream`, isolates, and generated code when they are relevant to the user.

## Required Tools

- Format with `dart_format`.
- Apply safe automated fixes with `dart_fix`.
- Lint/analyze with `analyze_files`.
- Run tests with `run_tests` when available; otherwise use `flutter test`.
- Use `pub_dev_search` before suggesting new pub.dev packages when available.

## Stack Defaults

- Navigation: `go_router` with type-safe route declarations or typed route wrappers. Avoid scattered raw route strings.
- State: `ValueNotifier` and `ValueListenableBuilder` by default. Use `ChangeNotifier` only for clearly shared or multi-field app state. Do not use Riverpod or GetX.
- Data: `json_serializable` plus `json_annotation`, with `@JsonSerializable(fieldRename: FieldRename.snake)` for API models.
- UI: Material 3, centralized `ThemeData`, `ColorScheme.fromSeed`, light theme, dark theme, and `ThemeMode.system` unless product requirements say otherwise.
- Logging: `dart:developer` only. Do not use `print` or add another logging package unless explicitly required by the project.

## Architecture

- Use logical layers: presentation, domain, data, and core/shared utilities.
- For larger apps, organize by feature with presentation/domain/data subfolders.
- Keep widgets focused on UI. Move business rules into domain services or view models/controllers.
- Use manual constructor dependency injection at boundaries.
- Prefer immutable data structures and immutable widgets.
- Favor composition over inheritance.
- Public APIs have stable names, typed contracts, predictable errors, and `///` dartdoc.

## Dart Code

- Follow Effective Dart.
- Names: `PascalCase` for types, `camelCase` for members/functions/variables/enums, `snake_case.dart` for files.
- Use sound null safety. Avoid `!`; if unavoidable, document why the value is guaranteed.
- Use `async`/`await` with `try`/`catch` for asynchronous failure paths.
- Use custom exceptions for domain-specific failures when helpful.
- Prefer exhaustive `switch` expressions/statements where they simplify logic.
- Use records only when they are clearer than a named type.
- Use arrow syntax for simple one-line functions.
- Keep functions short and single-purpose; aim for less than 20 lines when practical.
- Keep line length at 80 characters when practical and follow project formatter output.

## Flutter Code

- Use small private widget classes instead of private helper methods returning widgets.
- Break down large `build()` methods into reusable widgets.
- Use `const` constructors and `const` widget instances wherever possible.
- Do not perform network calls, disk I/O, or expensive computation inside `build()`.
- Use `ListView.builder`, `GridView.builder`, or slivers for long lists and grids.
- Use `compute()` or another isolate boundary for heavy parsing or computation.
- Use `LayoutBuilder`, `MediaQuery`, `Flexible`, `Expanded`, `Wrap`, and scrollables to prevent overflow.
- Use `OverlayPortal` for custom overlays when it improves correctness and lifecycle management.
- Use `Image.network` with `loadingBuilder` and `errorBuilder`.

## Design And Theming

- Build polished interfaces with Material 3, responsive layouts, strong hierarchy, icons, shadows, and premium depth.
- Use glassmorphism and shadows only where they improve clarity, hierarchy, or delight.
- Keep theme tokens centralized in `ThemeData` and `ThemeExtension` for app-specific colors/elevation/radii.
- Support light and dark mode with tested contrast in both modes.
- Use `Theme.of(context).textTheme` for text styles.
- Avoid long all-caps text. Keep body copy readable with 45-75 character line lengths where possible.
- Declare assets in `pubspec.yaml` and use meaningful, licensed images.

## Accessibility

- Text contrast must be at least 4.5:1 for normal text and 3:1 for large text.
- Add `Semantics` labels for non-obvious controls, custom widgets, and icon-only actions.
- Validate dynamic text scaling and responsive layouts for critical screens.
- Include accessibility checks in review for changed UI.

## Testing

- Unit-test domain logic, data mapping, repositories, and state objects.
- Widget-test screens, reusable widgets, loading/empty/error states, semantics, and dark mode when relevant.
- Use `integration_test` for critical flows, navigation, platform behavior, and end-to-end journeys.
- Prefer fakes and stubs over mocks. Use `mockito` or `mocktail` only when fakes would distort the behavior under test.
- Prefer `package:checks` assertions when already available.
- Use Arrange-Act-Assert or Given-When-Then.

## Code Generation

- Use `build_runner` for `json_serializable` output.
- Ensure `build_runner` is a dev dependency when generated JSON code is needed.
- After model changes, run `dart run build_runner build --delete-conflicting-outputs` or the project-approved equivalent.
- Never hand-edit generated `.g.dart` files.

## Review Gates

- Reject Flutter changes that add Riverpod/GetX, scatter route strings, use `print`, introduce unnecessary `!`, skip dark mode, or leave changed behavior untested.
- Flag UI that overflows, lacks semantics, fails contrast, blocks the UI thread, or performs side effects in `build()`.
- Flag public APIs without meaningful `///` documentation when they are part of reusable app/library surface.
