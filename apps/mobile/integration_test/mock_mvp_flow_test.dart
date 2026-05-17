import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/src/app/app_bootstrap.dart';
import 'package:mobile/src/app/app_config.dart';
import 'package:mobile/src/core/backend/repositories.dart';

Future<MacGyverApp> _testApp() async {
  final deps = await createAppDependencies(
    config: const AppConfig(backendMode: BackendMode.mock, apiBaseUrl: ''),
    sessionStore: MemorySessionStore(),
    imageCaptureService: FakeImageCaptureService(),
  );
  return MacGyverApp(dependencies: deps);
}

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _verticalScrollable() => find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
      description: 'vertical Scrollable',
    )
    .last;

Future<void> _ensureVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final scrollable = _verticalScrollable();
    try {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: scrollable,
        maxScrolls: 20,
      );
    } catch (_) {
      await tester.scrollUntilVisible(
        finder,
        -300,
        scrollable: scrollable,
        maxScrolls: 20,
      );
    }
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = _key(key);
  await _ensureVisible(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enterTextKey(WidgetTester tester, String key, String text) async {
  final finder = _key(key);
  await _ensureVisible(tester, finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<void> _expectTextVisible(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await _ensureVisible(tester, finder);
  expect(finder, findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('teacher completes mock photo-to-lesson flow', (tester) async {
    await tester.pumpWidget(await _testApp());
    await tester.pumpAndSettle();

    await _tapKey(tester, 'sign_in_submit');
    await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
    await _tapKey(tester, 'profile_save');
    await _expectTextVisible(tester, 'Teacher Dashboard');

    await _tapKey(tester, 'home_start_scan');
    await _tapKey(tester, 'scan_camera');
    await _expectTextVisible(tester, 'Camera Preview');
    await _tapKey(tester, 'camera_capture');
    await _tapKey(tester, 'scan_analyze');
    await _expectTextVisible(tester, 'Detected materials');

    await _tapKey(tester, 'inventory_continue_confirm');
    await _tapKey(tester, 'inventory_confirm');
    await _expectTextVisible(tester, 'Suggested experiments');

    await _tapKey(tester, 'suggestion_exp-rubber-band-car');
    await _tapKey(tester, 'open_generation_context');
    await _tapKey(tester, 'start_generation');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    await _tapKey(tester, 'open_generated_lesson');
    await _expectTextVisible(tester, 'Editable generated plan');

    await _tapKey(tester, 'lesson_save');
    await _tapKey(tester, 'lesson_feedback');
    await _tapKey(tester, 'feedback_submit');
    await _expectTextVisible(tester, 'Lesson Editor');
    await _expectTextVisible(tester, 'Editable generated plan');
  });
}
