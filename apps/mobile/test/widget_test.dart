import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/app/app_bootstrap.dart';
import 'package:mobile/src/app/app_config.dart';
import 'package:mobile/src/core/backend/repositories.dart';
import 'package:mobile/src/core/media/image_picker_capture_service.dart';

const _phoneViewport = Size(390, 844);

Future<MacGyverApp> _testApp() async {
  final deps = await createAppDependencies(
    config: const AppConfig(backendMode: BackendMode.mock, apiBaseUrl: ''),
    sessionStore: MemorySessionStore(),
    imageCaptureService: FakeImageCaptureService(),
  );
  return MacGyverApp(dependencies: deps);
}

Finder _byKey(String key) => find.byKey(ValueKey(key));

Future<void> _waitForFinder(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _bringIntoView(
  WidgetTester tester,
  Finder finder, {
  required String description,
}) async {
  await _waitForFinder(tester, finder);
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    if (finder.hitTestable().evaluate().isNotEmpty) {
      return;
    }
  }

  final scrollables = find.byType(Scrollable).evaluate().toList().reversed;
  for (final scrollableElement in scrollables) {
    final scrollable = find.byElementPredicate(
      (element) => identical(element, scrollableElement),
      description: 'Scrollable for $description',
    );
    try {
      await tester.scrollUntilVisible(finder, 140, scrollable: scrollable);
      await tester.pumpAndSettle();
    } on StateError {
      continue;
    } on TestFailure {
      continue;
    }

    if (finder.hitTestable().evaluate().isNotEmpty) {
      return;
    }
  }

  expect(
    finder.hitTestable(),
    findsOneWidget,
    reason: 'Expected $description to be visible and tappable',
  );
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = _byKey(key);
  await _bringIntoView(tester, finder, description: 'key "$key"');
  await tester.tap(finder.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> _tapBottomNav(WidgetTester tester, String label) async {
  final finder = find
      .descendant(of: find.byType(NavigationBar), matching: find.text(label))
      .hitTestable();
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _enterTextKey(WidgetTester tester, String key, String text) async {
  final finder = _byKey(key);
  await _bringIntoView(tester, finder, description: 'key "$key"');
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<void> _expectVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await _bringIntoView(tester, finder, description: 'text "$text"');
}

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = _phoneViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(await _testApp());
  await tester.pumpAndSettle();
}

Future<void> _completeGeneratedLessonFlow(WidgetTester tester) async {
  await _tapKey(tester, 'sign_in_submit');
  await _expectVisibleText(tester, 'Classroom defaults');
  await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
  await _tapKey(tester, 'profile_save');
  await _expectVisibleText(tester, 'Teacher Dashboard');
  await _tapKey(tester, 'home_start_scan');
  await _expectVisibleText(tester, 'Capture classroom objects');
  await _tapKey(tester, 'scan_camera');
  await _tapKey(tester, 'scan_analyze');
  await _expectVisibleText(tester, 'Detected materials');
  await _tapKey(tester, 'inventory_continue_confirm');
  await _expectVisibleText(tester, 'Use this inventory for matching');
  await _tapKey(tester, 'inventory_confirm');
  await _expectVisibleText(tester, 'Suggested experiments');
  await _tapKey(tester, 'suggestion_exp-rubber-band-car');
  await _expectVisibleText(tester, 'Rubber Band Powered Car');
  await _tapKey(tester, 'open_generation_context');
  await _expectVisibleText(tester, 'Review before generation');
  await _tapKey(tester, 'start_generation');
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  await _tapKey(tester, 'open_generated_lesson');
  await _expectVisibleText(tester, 'Editable generated plan');
}

void main() {
  test('app dependencies use device image capture by default', () async {
    final deps = await createAppDependencies(
      sessionStore: MemorySessionStore(),
    );

    expect(deps.imageCaptureService, isA<ImagePickerCaptureService>());
  });

  testWidgets('signed out users see sign-in instead of Flutter counter', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('MacGyver Classroom'), findsWidgets);
    expect(find.byKey(const ValueKey('sign_in_submit')), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('app shell keeps fixed bottom navigation between tabs', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _tapKey(tester, 'sign_in_submit');
    await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
    await _tapKey(tester, 'profile_save');
    await _expectVisibleText(tester, 'Teacher Dashboard');

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await _tapBottomNav(tester, 'Scan');
    expect(find.text('Capture classroom objects'), findsOneWidget);
    expect(find.text('Teacher Dashboard'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    await tester.pump(const Duration(milliseconds: 300));

    await _tapBottomNav(tester, 'Library');
    expect(find.text('Lesson Library'), findsOneWidget);
    expect(find.text('Capture classroom objects'), findsNothing);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('mock happy path reaches generated lesson editor', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _completeGeneratedLessonFlow(tester);

    expect(find.text('Editable generated plan'), findsOneWidget);
    await _tapKey(tester, 'lesson_save');
    await _tapKey(tester, 'lesson_feedback');
    await _tapKey(tester, 'feedback_submit');

    expect(find.text('Lesson Editor'), findsOneWidget);
    expect(find.text('Lesson feedback'), findsNothing);
  });

  testWidgets('export is gated by safety confirmation', (tester) async {
    await _pumpApp(tester);

    await _completeGeneratedLessonFlow(tester);
    await _tapKey(tester, 'lesson_export');
    await _expectVisibleText(tester, 'Export lesson');

    final copyButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('copy_markdown')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(copyButton.onPressed, isNull);

    await _tapKey(tester, 'safety_confirm');
    final enabledCopyButton = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('copy_markdown')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(enabledCopyButton.onPressed, isNotNull);
  });
}
