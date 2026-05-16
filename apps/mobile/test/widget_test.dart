import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/src/app/app_bootstrap.dart';
import 'package:mobile/src/app/app_config.dart';
import 'package:mobile/src/core/backend/repositories.dart';
import 'package:mobile/src/core/design_system/design_system.dart';
import 'package:mobile/src/core/media/image_picker_capture_service.dart';
import 'package:mobile/src/core/models.dart';
import 'package:mobile/src/features/mvp_screens.dart';

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
  await _expectVisibleText(tester, 'Camera Preview');
  await _tapKey(tester, 'camera_capture');
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

class _CountingInventoryRepository implements InventoryRepository {
  _CountingInventoryRepository(this.scan);

  InventoryScan scan;
  int getScanCount = 0;
  int updateItemsCount = 0;
  int confirmCount = 0;
  List<DetectedItem>? lastUpdatedItems;

  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async =>
      scan;

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async => scan;

  @override
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async => scan;

  @override
  Future<InventoryScan?> getScan(String scanId) async {
    getScanCount += 1;
    return scan;
  }

  @override
  Future<InventoryScan> updateItems(
    String scanId,
    List<DetectedItem> items,
  ) async {
    updateItemsCount += 1;
    lastUpdatedItems = items;
    scan = scan.copyWith(detectedItems: items);
    return scan;
  }

  @override
  Future<InventoryScan> confirm(String scanId) async {
    confirmCount += 1;
    return scan.copyWith(status: ScanStatus.confirmed);
  }
}

Future<void> _pumpInventoryScreen(
  WidgetTester tester, {
  required InventoryRepository inventoryRepository,
  required Widget screen,
}) async {
  final authController = AuthController(
    repository: MockAuthRepository(),
    sessionStore: MemorySessionStore(),
  );
  await authController.bootstrap();
  final lessonRepository = MockLessonRepository();
  final dependencies = AppDependencies(
    config: const AppConfig(backendMode: BackendMode.mock, apiBaseUrl: ''),
    authController: authController,
    profileRepository: MockProfileRepository(),
    inventoryRepository: inventoryRepository,
    experimentRepository: MockExperimentRepository(
      lessonRepository: lessonRepository,
    ),
    lessonRepository: lessonRepository,
    exportRepository: ExportRepository(),
    feedbackRepository: FeedbackRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    imageCaptureService: FakeImageCaptureService(),
  );

  await tester.pumpWidget(
    AppScope(
      dependencies: dependencies,
      child: MaterialApp(
        theme: McTheme.light(),
        home: Material(child: screen),
      ),
    ),
  );
}

void main() {
  test('app dependencies use device image capture by default', () async {
    final deps = await createAppDependencies(
      sessionStore: MemorySessionStore(),
    );

    expect(deps.imageCaptureService, isA<ImagePickerCaptureService>());
  });

  test('detected item preserves API catalog identity in edit payloads', () {
    final item = DetectedItem.fromJson(const {
      'id': 'item-1',
      'rawLabel': 'bouncy band on desk',
      'canonicalName': 'rubber_band',
      'displayName': 'Rubber band',
      'quantityEstimate': 3,
      'unit': 'pieces',
      'confidence': 0.83,
      'evidence': ['tray', 'desk'],
    });

    final edited = item.copyWith(quantity: 4, notes: 'Teacher verified');

    expect(edited.rawLabel, 'bouncy band on desk');
    expect(edited.canonicalName, 'rubber_band');
    expect(edited.toJson(), containsPair('rawLabel', 'bouncy band on desk'));
    expect(edited.toJson(), containsPair('canonicalName', 'rubber_band'));
    expect(edited.toJson(), containsPair('evidence', ['tray', 'desk']));
  });

  test('api inventory update sends review payload in API item shape', () async {
    Map<String, dynamic>? capturedBody;
    final authController = AuthController(
      repository: MockAuthRepository(),
      sessionStore: MemorySessionStore(),
    );
    await authController.bootstrap();
    final repository = ApiInventoryRepository(
      authController: authController,
      config: const AppConfig(
        backendMode: BackendMode.api,
        apiBaseUrl: 'https://api.test',
      ),
      client: MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'scan-1',
            'status': 'NEEDS_CONFIRMATION',
            'images': [],
            'detectedItems': capturedBody!['items'],
            'subject': 'Physics',
            'gradeBand': 'Grade 8',
            'topic': 'Forces',
            'classLabel': '8A',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final catalogItem = DetectedItem.fromJson(const {
      'id': 'item-1',
      'rawLabel': 'bouncy band on desk',
      'canonicalName': 'rubber_band',
      'displayName': 'Rubber band',
      'quantityEstimate': 3,
      'unit': 'pieces',
      'confidence': 0.83,
      'evidence': ['tray', 'desk'],
    });
    final unmatchedItem = DetectedItem.fromJson(const {
      'id': 'item-2',
      'rawLabel': 'mystery classroom object',
      'canonicalName': null,
      'displayName': 'Mystery classroom object',
      'quantityEstimate': 1,
      'unit': 'item',
      'confidence': 0.42,
      'evidence': ['back table'],
    });
    const manualItem = DetectedItem(
      id: 'manual-1',
      label: 'Paper clips',
      quantity: 20,
      unit: 'pieces',
      confidence: 1,
      evidence: 'Added manually by teacher.',
    );

    await repository.updateItems('scan-1', [
      catalogItem,
      unmatchedItem,
      catalogItem.copyWith(removed: true),
      manualItem,
    ]);

    final items = (capturedBody!['items'] as List).cast<Map<String, dynamic>>();
    expect(items[0]['rawLabel'], 'bouncy band on desk');
    expect(items[0]['canonicalName'], 'rubber_band');
    expect(items[0]['evidence'], ['tray', 'desk']);
    expect(items[1], containsPair('canonicalName', null));
    expect(items[1]['rawLabel'], 'mystery classroom object');
    expect(items[1]['evidence'], ['back table']);
    expect(items[2]['removed'], isTrue);
    expect(items[3]['rawLabel'], 'Paper clips');
    expect(items[3], containsPair('canonicalName', null));
    expect(items[3]['evidence'], ['Added manually by teacher.']);
  });

  test('mobile design system uses MacGyver brand tokens', () {
    final theme = McTheme.light();
    final inputBorder = theme.inputDecorationTheme.border;

    expect(McColors.appBg, const Color(0xFFFAFAF7));
    expect(McColors.screen, const Color(0xFFFFFFFF));
    expect(McColors.primary, const Color(0xFF1A24A8));
    expect(McColors.accent, const Color(0xFFF5B945));
    expect(McColors.earth, const Color(0xFF7A5B14));
    expect(McColors.ink, const Color(0xFF2C2C2A));
    expect(McBrandMark.assetPath, 'assets/macgyver.svg');
    expect(theme.scaffoldBackgroundColor, McColors.appBg);
    expect(theme.textTheme.headlineMedium?.fontWeight, FontWeight.w600);
    expect(theme.textTheme.titleMedium?.fontWeight, FontWeight.w500);
    expect(inputBorder, isA<OutlineInputBorder>());
    expect(
      (inputBorder! as OutlineInputBorder).borderRadius,
      BorderRadius.circular(McRadius.sm),
    );
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

  testWidgets(
    'scan camera opens a dedicated preview screen and returns a photo',
    (tester) async {
      await _pumpApp(tester);

      await _tapKey(tester, 'sign_in_submit');
      await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
      await _tapKey(tester, 'profile_save');
      await _tapKey(tester, 'home_start_scan');
      await _expectVisibleText(tester, 'Capture classroom objects');

      await _tapKey(tester, 'scan_camera');
      await _expectVisibleText(tester, 'Camera Preview');
      await _tapKey(tester, 'camera_capture');

      await _expectVisibleText(tester, 'Capture classroom objects');
      expect(find.text('camera-1.jpg'), findsOneWidget);
    },
  );

  testWidgets('account profile shows user fields and changes password', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _tapKey(tester, 'sign_in_submit');
    await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
    await _tapKey(tester, 'profile_save');
    await _tapBottomNav(tester, 'Account');

    await _expectVisibleText(tester, 'User profile');
    await _expectVisibleText(tester, 'Full name');
    await _expectVisibleText(tester, 'Linh Nguyen');
    await _expectVisibleText(tester, 'Email');
    await _expectVisibleText(tester, 'teacher@example.com');

    await _enterTextKey(tester, 'account_current_password', 'password123');
    await _enterTextKey(tester, 'account_new_password', 'newpassword123');
    await _enterTextKey(tester, 'account_confirm_password', 'newpassword123');
    await _tapKey(tester, 'account_change_password');

    await _expectVisibleText(tester, 'Password updated.');
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

  testWidgets('inventory review and confirm cache scan loads across rebuilds', (
    tester,
  ) async {
    final scan = InventoryScan(
      id: 'scan-1',
      status: ScanStatus.needsConfirmation,
      images: const [],
      detectedItems: const [
        DetectedItem(
          id: 'item-1',
          label: 'Rubber band',
          quantity: 3,
          unit: 'pieces',
          confidence: 0.83,
          evidence: 'On desk',
        ),
      ],
      subject: 'Physics',
      gradeBand: 'Grade 8',
      topic: 'Forces',
      classLabel: '8A',
    );

    final reviewRepository = _CountingInventoryRepository(scan);
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: reviewRepository,
      screen: const InventoryReviewScreen(scanId: 'scan-1'),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppScope.of(
          tester.element(find.byType(InventoryReviewScreen)),
        ),
        child: MaterialApp(
          theme: McTheme.light(),
          home: const Material(child: InventoryReviewScreen(scanId: 'scan-1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(reviewRepository.getScanCount, 1);
    expect(reviewRepository.updateItemsCount, 0);
    expect(reviewRepository.confirmCount, 0);

    final confirmRepository = _CountingInventoryRepository(scan);
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: confirmRepository,
      screen: const InventoryConfirmScreen(scanId: 'scan-1'),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      AppScope(
        dependencies: AppScope.of(
          tester.element(find.byType(InventoryConfirmScreen)),
        ),
        child: MaterialApp(
          theme: McTheme.light(),
          home: const Material(child: InventoryConfirmScreen(scanId: 'scan-1')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(confirmRepository.getScanCount, 1);
    expect(confirmRepository.updateItemsCount, 0);
    expect(confirmRepository.confirmCount, 0);
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
