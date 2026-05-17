import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

Future<MacGyverApp> _testApp({
  InventoryRepository? inventoryRepository,
  ImageCaptureService? imageCaptureService,
}) async {
  final deps = await createAppDependencies(
    config: const AppConfig(backendMode: BackendMode.mock, apiBaseUrl: ''),
    sessionStore: MemorySessionStore(),
    imageCaptureService: imageCaptureService ?? FakeImageCaptureService(),
  );
  if (inventoryRepository == null) {
    return MacGyverApp(dependencies: deps);
  }
  return MacGyverApp(
    dependencies: AppDependencies(
      config: deps.config,
      authController: deps.authController,
      profileRepository: deps.profileRepository,
      inventoryRepository: inventoryRepository,
      experimentRepository: deps.experimentRepository,
      lessonRepository: deps.lessonRepository,
      exportRepository: deps.exportRepository,
      feedbackRepository: deps.feedbackRepository,
      analyticsRepository: deps.analyticsRepository,
      imageCaptureService: deps.imageCaptureService,
    ),
  );
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

Future<void> _pumpApp(
  WidgetTester tester, {
  InventoryRepository? inventoryRepository,
  ImageCaptureService? imageCaptureService,
}) async {
  tester.view.physicalSize = _phoneViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    await _testApp(
      inventoryRepository: inventoryRepository,
      imageCaptureService: imageCaptureService,
    ),
  );
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
  Completer<void>? createDraftGate;
  int createDraftCount = 0;
  int attachImagesCount = 0;
  int analyzeCount = 0;
  int getScanCount = 0;
  int updateItemsCount = 0;
  int confirmCount = 0;
  List<ScanImage>? lastAnalyzeImages;
  List<DetectedItem>? lastUpdatedItems;

  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async {
    createDraftCount += 1;
    final gate = createDraftGate;
    if (gate != null) await gate.future;
    return scan;
  }

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async {
    attachImagesCount += 1;
    scan = scan.copyWith(status: ScanStatus.uploaded, images: images);
    return scan;
  }

  @override
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async {
    analyzeCount += 1;
    lastAnalyzeImages = images;
    return scan;
  }

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
  AppConfig config = const AppConfig(
    backendMode: BackendMode.mock,
    apiBaseUrl: '',
  ),
  ExperimentRepository? experimentRepository,
  LessonRepository? lessonRepository,
  ImageCaptureService? imageCaptureService,
}) async {
  final authController = AuthController(
    repository: MockAuthRepository(),
    sessionStore: MemorySessionStore(),
  );
  await authController.bootstrap();
  final resolvedLessonRepository = lessonRepository ?? MockLessonRepository();
  final dependencies = AppDependencies(
    config: config,
    authController: authController,
    profileRepository: MockProfileRepository(),
    inventoryRepository: inventoryRepository,
    experimentRepository:
        experimentRepository ??
        MockExperimentRepository(lessonRepository: resolvedLessonRepository),
    lessonRepository: resolvedLessonRepository,
    exportRepository: ExportRepository(),
    feedbackRepository: FeedbackRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    imageCaptureService: imageCaptureService ?? FakeImageCaptureService(),
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

class _FailingAnalyzeInventoryRepository implements InventoryRepository {
  final _profileScan = const InventoryScan(
    id: 'scan-failed',
    status: ScanStatus.created,
    images: [],
    detectedItems: [],
    subject: 'Physics',
    gradeBand: 'Grade 8',
    topic: 'Forces',
    classLabel: '8A',
  );

  int analyzeCount = 0;
  InventoryScan? _scan;

  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async {
    _scan = _profileScan;
    return _profileScan;
  }

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async {
    final next = _profileScan.copyWith(
      status: ScanStatus.uploaded,
      images: images,
    );
    _scan = next;
    return next;
  }

  @override
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async {
    analyzeCount += 1;
    final next = (_scan ?? _profileScan).copyWith(
      status: ScanStatus.failed,
      errorMessage: 'Camera blur prevented analysis.',
    );
    _scan = next;
    return next;
  }

  @override
  Future<InventoryScan?> getScan(String scanId) async => _scan;

  @override
  Future<InventoryScan> updateItems(
    String scanId,
    List<DetectedItem> items,
  ) async => (_scan ?? _profileScan).copyWith(detectedItems: items);

  @override
  Future<InventoryScan> confirm(String scanId) async =>
      (_scan ?? _profileScan).copyWith(status: ScanStatus.confirmed);
}

class _FailingCreateInventoryRepository implements InventoryRepository {
  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async =>
      throw StateError('api unavailable');

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async => throw StateError('scan missing');

  @override
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async => throw StateError('scan missing');

  @override
  Future<InventoryScan> confirm(String scanId) async =>
      throw StateError('scan missing');

  @override
  Future<InventoryScan?> getScan(String scanId) async => null;

  @override
  Future<InventoryScan> updateItems(
    String scanId,
    List<DetectedItem> items,
  ) async => throw StateError('scan missing');
}

class _RetryInventoryRepository extends _CountingInventoryRepository {
  _RetryInventoryRepository(super.scan);

  var failNextLoad = true;

  @override
  Future<InventoryScan?> getScan(String scanId) async {
    getScanCount += 1;
    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('network unavailable');
    }
    return scan;
  }
}

class _ThrowingLostDataCaptureService extends FakeImageCaptureService {
  @override
  Future<List<ScanImage>> retrieveLostData() async =>
      throw StateError('lost data unsupported');
}

class _GalleryImagesCaptureService implements ImageCaptureService {
  _GalleryImagesCaptureService({required this.imageCount});

  final int imageCount;
  int? lastLimit;

  @override
  Future<ScanImage?> captureCamera() async => _scanImage('camera-1.png');

  @override
  Future<List<ScanImage>> pickGallery({int? limit}) async {
    lastLimit = limit;
    return [
      for (var index = 1; index <= imageCount; index += 1)
        _scanImage('gallery-$index.png', source: 'gallery'),
    ];
  }

  @override
  Future<List<ScanImage>> retrieveLostData() async => const [];
}

const _tinyPngBytes = <int>[137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3, 4];

ScanImage _scanImage(String id, {String source = 'camera'}) => ScanImage(
  id: id,
  source: source,
  path: '',
  mimeType: 'image/png',
  bytes: Uint8List.fromList(_tinyPngBytes),
);

class _ThrowingSessionStore implements SessionStore {
  @override
  Future<void> clear() async => throw StateError('missing entitlement');

  @override
  Future<UserSession?> read() async => throw StateError('missing entitlement');

  @override
  Future<void> write(UserSession session) async =>
      throw StateError('missing entitlement');
}

void main() {
  test('environment defaults target the local API backend', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final config = AppConfig.fromEnvironment();

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://127.0.0.1:4000');
  });

  test('environment defaults use the Android emulator host alias', () {
    final config = AppConfig.fromEnvironmentValues(
      isWeb: false,
      targetPlatform: TargetPlatform.android,
    );

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://10.0.2.2:4000');
  });

  test('environment API port defines the fallback local API URL', () {
    final config = AppConfig.fromEnvironmentValues(
      apiPort: '3000',
      isWeb: false,
      targetPlatform: TargetPlatform.iOS,
    );

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://127.0.0.1:3000');
  });

  test('desktop web does not use the Android emulator host alias', () {
    final config = AppConfig.fromEnvironmentValues(
      apiBaseUrl: 'http://10.0.2.2:4000',
      isWeb: true,
      targetPlatform: TargetPlatform.macOS,
    );

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://127.0.0.1:4000');
  });

  test('iOS simulator does not use the Android emulator host alias', () {
    final config = AppConfig.fromEnvironmentValues(
      apiBaseUrl: 'http://10.0.2.2:4000',
      isWeb: false,
      targetPlatform: TargetPlatform.iOS,
    );

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://127.0.0.1:4000');
  });

  test('Android web keeps an explicitly configured emulator host alias', () {
    final config = AppConfig.fromEnvironmentValues(
      apiBaseUrl: 'http://10.0.2.2:4000',
      isWeb: true,
      targetPlatform: TargetPlatform.android,
    );

    expect(config.backendMode, BackendMode.api);
    expect(config.apiBaseUrl, 'http://10.0.2.2:4000');
  });

  test('app dependencies use device image capture by default', () async {
    final deps = await createAppDependencies(
      sessionStore: MemorySessionStore(),
    );

    expect(deps.imageCaptureService, isA<ImagePickerCaptureService>());
  });

  test(
    'session storage falls back when secure storage is unavailable',
    () async {
      final authController = AuthController(
        repository: MockAuthRepository(),
        sessionStore: ResilientSessionStore(primary: _ThrowingSessionStore()),
      );

      await authController.bootstrap();
      await authController.signIn('teacher@example.com', 'password123');

      expect(authController.value.isSignedIn, isTrue);
      expect(authController.value.session?.email, 'teacher@example.com');
    },
  );

  test(
    'API mode wires scan and experiment calls to API repositories',
    () async {
      final deps = await createAppDependencies(
        config: const AppConfig(
          backendMode: BackendMode.api,
          apiBaseUrl: 'https://api.test',
        ),
        sessionStore: MemorySessionStore(),
      );

      expect(deps.inventoryRepository, isA<ApiInventoryRepository>());
      expect(deps.experimentRepository, isA<ApiExperimentRepository>());
      await deps.authController.signIn('teacher@example.com', 'password123');
      expect(deps.authController.value.session?.email, 'teacher@example.com');
    },
  );

  test(
    'mock inventory includes paper cup paper plate and wooden fork materials',
    () async {
      final repository = MockInventoryRepository();
      final scan = await repository.createDraft(
        profile: const TeacherProfile(
          schoolName: 'Pilot Secondary School',
          subjects: ['Physics'],
          gradeBands: ['Grade 8'],
          classLabels: ['8A'],
          defaultTopic: 'Sound and vibration',
          teachingNotes: 'Use low-cost classroom disposables safely.',
        ),
      );

      final analyzed = await repository.analyze(scan.id);

      expect(
        analyzed.detectedItems.map((item) => item.label),
        containsAll(const ['Paper cup', 'Paper plate', 'Wooden fork']),
      );
    },
  );

  test(
    'mock experiment repository generates a lesson using paper cup paper plate and wooden fork',
    () async {
      final lessonRepository = MockLessonRepository();
      final repository = MockExperimentRepository(
        lessonRepository: lessonRepository,
      );

      final suggestions = await repository.suggestionsForScan('scan-1');
      final soundLesson = suggestions.singleWhere(
        (suggestion) => suggestion.id == 'exp-paper-cup-sound',
      );
      final lesson = await repository.generateLesson('scan-1', soundLesson.id);

      expect(soundLesson.title, 'Paper Cup Sound Amplifier');
      expect(
        lesson.materials,
        containsAll(const ['Paper cup', 'Paper plate', 'Wooden fork']),
      );
      expect(lesson.topic, 'Sound and vibration');
      expect(await lessonRepository.get(lesson.id), lesson);
    },
  );

  test('api experiment generation posts to the AI lesson endpoint', () async {
    final lessonRepository = MockLessonRepository();
    final authController = AuthController(
      repository: MockAuthRepository(),
      sessionStore: MemorySessionStore(),
    );
    await authController.bootstrap();
    final requests = <http.Request>[];
    final repository = ApiExperimentRepository(
      authController: authController,
      config: const AppConfig(
        backendMode: BackendMode.api,
        apiBaseUrl: 'https://api.test',
      ),
      lessonRepository: lessonRepository,
      client: MockClient((request) async {
        requests.add(request);
        return http.Response(
          jsonEncode({
            'id': 'lesson-paper-cup-sound-amplifier',
            'title': 'Paper Cup Sound Amplifier: STEM sound tutorial',
            'gradeBand': 'Grade 8',
            'subject': 'Physics',
            'topic': 'Sound and vibration',
            'durationMinutes': 35,
            'sourceExperimentId': 'paper-cup-sound-amplifier',
            'sourceInventoryScanId': 'scan-1',
            'objectives': ['Describe sound as vibration.'],
            'materials': ['Paper cup', 'Paper plate', 'Wooden fork'],
            'flow': [
              'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
            ],
            'questions': ['What was vibrating when you heard the sound?'],
            'assessment':
                'Exit ticket: explain how the paper cup changed the sound.',
            'safetyNotes': ['Use gentle tapping only.'],
            'teacherChecksRequired': ['Replace cracked wooden forks.'],
            'aiRunId': 'ai-run-lesson-1',
            'version': 1,
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final lesson = await repository.generateLesson(
      'scan-1',
      'paper-cup-sound-amplifier',
    );

    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/lessons/generate');
    expect(jsonDecode(requests.single.body), {
      'scanId': 'scan-1',
      'experimentId': 'paper-cup-sound-amplifier',
    });
    expect(lesson.id, 'lesson-paper-cup-sound-amplifier');
    expect(lesson.title, 'Paper Cup Sound Amplifier: STEM sound tutorial');
    expect(lesson.sourceInventoryScanId, 'scan-1');
    expect(lesson.aiRunId, 'ai-run-lesson-1');
    expect(lesson.teacherChecksRequired, ['Replace cracked wooden forks.']);
    expect(
      lesson.flow,
      contains(
        'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
      ),
    );
    expect(
      lesson.materials,
      containsAll(['Paper cup', 'Paper plate', 'Wooden fork']),
    );
    expect(await lessonRepository.get(lesson.id), lesson);
  });

  testWidgets('lesson editor displays the STEM experiment tutorial', (
    tester,
  ) async {
    const lesson = LessonPlan(
      id: 'lesson-paper-cup-sound-amplifier',
      title: 'Paper Cup Sound Amplifier: STEM sound tutorial',
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Sound and vibration',
      durationMinutes: 35,
      objectives: ['Describe sound as vibration.'],
      materials: ['Paper cup', 'Paper plate', 'Wooden fork'],
      flow: [
        'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
        'Step 2: Tap the paper plate gently with the wooden fork and listen for vibration.',
      ],
      questions: ['What was vibrating when you heard the sound?'],
      assessment: 'Exit ticket: explain how the cup changed the sound.',
      safetyNotes: ['Use gentle tapping only.'],
      sourceExperimentId: 'paper-cup-sound-amplifier',
    );
    final lessonRepository = MockLessonRepository();
    await lessonRepository.save(lesson);

    await _pumpInventoryScreen(
      tester,
      inventoryRepository: _CountingInventoryRepository(
        const InventoryScan(
          id: 'scan-1',
          status: ScanStatus.confirmed,
          images: [],
          detectedItems: [],
          subject: 'Physics',
          gradeBand: 'Grade 8',
          topic: 'Sound and vibration',
          classLabel: '8A',
        ),
      ),
      lessonRepository: lessonRepository,
      screen: const LessonEditorScreen(
        lessonId: 'lesson-paper-cup-sound-amplifier',
      ),
    );
    await tester.pumpAndSettle();

    await _expectVisibleText(tester, 'STEM experiment tutorial');
    await _expectVisibleText(
      tester,
      'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
    );
  });

  test('api inventory analysis posts captured image bytes to NestJS', () async {
    String? capturedMethod;
    Uri? capturedUrl;
    Map<String, dynamic>? capturedBody;
    final imageBytes = <int>[137, 80, 78, 71, 13, 10, 26, 10, 1, 2, 3, 4];
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
        capturedMethod = request.method;
        capturedUrl = request.url;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'scan-1',
            'status': 'NEEDS_CONFIRMATION',
            'images': [],
            'detectedItems': [
              {
                'id': 'item-bottle',
                'rawLabel': 'plastic bottle',
                'canonicalName': 'plastic_bottle',
                'displayName': 'Plastic bottle',
                'quantityEstimate': 1,
                'unit': 'piece',
                'confidence': 0.91,
                'evidence': ['visible bottle'],
                'safetyFlags': [],
                'removed': false,
              },
            ],
            'subject': 'Physics',
            'gradeBand': 'Grade 8',
            'topic': 'Forces',
            'classLabel': '8A',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final scan = await repository.analyze(
      'scan-1',
      images: [
        ScanImage(
          id: 'classroom.png',
          source: 'camera',
          path: '',
          mimeType: 'image/png',
          bytes: Uint8List.fromList(imageBytes),
        ),
      ],
    );

    final images = (capturedBody!['images'] as List)
        .cast<Map<String, dynamic>>();
    expect(capturedMethod, 'POST');
    expect(capturedUrl?.path, '/inventory/scans/scan-1/analyze');
    expect(images, hasLength(1));
    expect(images.single['mimeType'], 'image/png');
    expect(images.single['dataBase64'], base64Encode(imageBytes));
    expect(scan.detectedItems.single.canonicalName, 'plastic_bottle');
  });

  test(
    'api inventory analysis sends in-memory image data and surfaces API errors',
    () async {
      Map<String, dynamic>? capturedBody;
      final authController = AuthController(
        repository: MockAuthRepository(),
        sessionStore: MemorySessionStore(),
      );
      await authController.bootstrap();
      await authController.signIn('teacher@example.com', 'password123');
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
              'code': 'scan_images_too_many',
              'message': 'At most 3 scan images are allowed.',
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      Object? caught;
      try {
        await repository.analyze(
          'scan-1',
          images: [_scanImage('gallery-1.png')],
        );
      } catch (error) {
        caught = error;
      }

      final images = (capturedBody!['images'] as List)
          .cast<Map<String, dynamic>>();
      expect(images.single['mimeType'], 'image/png');
      expect(images.single['dataBase64'], base64Encode(_tinyPngBytes));
      expect(caught.toString(), contains('At most 3 scan images are allowed.'));
    },
  );

  test('api experiment matching posts the confirmed scan id', () async {
    String? capturedMethod;
    Uri? capturedUrl;
    Map<String, dynamic>? capturedBody;
    final authController = AuthController(
      repository: MockAuthRepository(),
      sessionStore: MemorySessionStore(),
    );
    await authController.bootstrap();
    final repository = ApiExperimentRepository(
      authController: authController,
      config: const AppConfig(
        backendMode: BackendMode.api,
        apiBaseUrl: 'https://api.test',
      ),
      lessonRepository: MockLessonRepository(),
      client: MockClient((request) async {
        capturedMethod = request.method;
        capturedUrl = request.url;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'suggestions': [
              {
                'templateId': 'exp-api-match',
                'title': 'API Rubber Band Car',
                'subject': 'Physics',
                'topic': 'Forces',
                'estimatedMinutes': 45,
                'difficulty': 'Medium',
                'safetyCategory': 'SAFE',
                'matchedMaterials': [
                  {'displayName': 'Rubber band'},
                ],
                'missingMaterials': ['Bottle caps'],
                'summary': 'Matched from confirmed scan items.',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final suggestions = await repository.suggestionsForScan('scan-confirmed');

    expect(capturedMethod, 'POST');
    expect(capturedUrl?.path, '/experiments/match');
    expect(capturedBody, containsPair('scanId', 'scan-confirmed'));
    expect(suggestions.single.title, 'API Rubber Band Car');
    expect(suggestions.single.id, 'exp-api-match');
    expect(suggestions.single.availableMaterials, ['Rubber band']);
  });

  test(
    'api experiment detail parses NestJS template material fields',
    () async {
      String? capturedMethod;
      Uri? capturedUrl;
      final authController = AuthController(
        repository: MockAuthRepository(),
        sessionStore: MemorySessionStore(),
      );
      await authController.bootstrap();
      final repository = ApiExperimentRepository(
        authController: authController,
        config: const AppConfig(
          backendMode: BackendMode.api,
          apiBaseUrl: 'https://api.test',
        ),
        lessonRepository: MockLessonRepository(),
        client: MockClient((request) async {
          capturedMethod = request.method;
          capturedUrl = request.url;
          return http.Response(
            jsonEncode({
              'id': 'bottle-fountain-air-pressure',
              'title': 'Bottle Fountain Air Pressure',
              'summary': 'Observe pressure changes.',
              'estimatedMinutes': 20,
              'safetyCategory': 'LOW',
              'requiredMaterials': [
                {
                  'canonicalName': 'plastic_bottle',
                  'displayName': 'Plastic bottle',
                },
              ],
              'optionalMaterials': [
                {'canonicalName': 'straw', 'displayName': 'Straw'},
              ],
              'safetyNotes': [
                {'category': 'LOW', 'message': 'Use clean water.'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final detail = await repository.detail('bottle-fountain-air-pressure');

      expect(capturedMethod, 'GET');
      expect(capturedUrl?.path, '/experiments/bottle-fountain-air-pressure');
      expect(detail.id, 'bottle-fountain-air-pressure');
      expect(detail.durationMinutes, 20);
      expect(detail.availableMaterials, ['Plastic bottle', 'Straw']);
    },
  );

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

  testWidgets('failed analysis shows retryable error and stays on scan', (
    tester,
  ) async {
    final repository = _FailingAnalyzeInventoryRepository();
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: repository,
      imageCaptureService: FakeImageCaptureService(),
      screen: const InventoryCaptureScreen(),
    );
    await tester.pumpAndSettle();

    await _tapKey(tester, 'scan_gallery');
    await _tapKey(tester, 'scan_analyze');

    expect(repository.analyzeCount, 1);
    expect(find.text('Capture classroom objects'), findsOneWidget);
    expect(find.text('Detected materials'), findsNothing);
    await _expectVisibleText(tester, 'Camera blur prevented analysis.');
  });

  testWidgets(
    'camera and gallery photos preview locally when scan draft is unavailable',
    (tester) async {
      await _pumpApp(
        tester,
        inventoryRepository: _FailingCreateInventoryRepository(),
        imageCaptureService: _GalleryImagesCaptureService(imageCount: 1),
      );
      await _tapKey(tester, 'sign_in_submit');
      await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
      await _tapKey(tester, 'profile_save');
      await _tapKey(tester, 'home_start_scan');
      await _expectVisibleText(tester, 'Capture classroom objects');

      await _tapKey(tester, 'scan_gallery');
      await tester.pumpAndSettle();

      expect(find.text('gallery-1.png'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('scan_image_preview_gallery-1.png')),
        findsOneWidget,
      );

      await _tapKey(tester, 'scan_camera');
      await _expectVisibleText(tester, 'Camera Preview');
      await _tapKey(tester, 'camera_capture');
      await tester.pumpAndSettle();

      expect(find.text('camera-1.png'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('scan_image_preview_camera-1.png')),
        findsOneWidget,
      );
    },
  );

  testWidgets('photo attach stays local until inventory analysis', (
    tester,
  ) async {
    final repository = _CountingInventoryRepository(
      const InventoryScan(
        id: 'scan-1',
        status: ScanStatus.created,
        images: [],
        detectedItems: [],
        subject: 'Physics',
        gradeBand: 'Grade 8',
        topic: 'Forces',
        classLabel: '8A',
      ),
    );

    await _pumpInventoryScreen(
      tester,
      inventoryRepository: repository,
      imageCaptureService: FakeImageCaptureService(),
      screen: const InventoryCaptureScreen(),
    );
    await tester.pump();
    await _tapKey(tester, 'scan_gallery');
    await tester.pumpAndSettle();

    expect(find.text('gallery-1.jpg'), findsOneWidget);
    expect(find.text('gallery-2.jpg'), findsOneWidget);
    expect(repository.createDraftCount, 0);
    expect(repository.attachImagesCount, 0);

    await _tapKey(tester, 'scan_analyze');

    expect(repository.createDraftCount, 1);
    expect(repository.analyzeCount, 1);
    expect(repository.lastAnalyzeImages, hasLength(2));
  });

  testWidgets('analyze inventory navigates to detected materials review', (
    tester,
  ) async {
    final repository = _CountingInventoryRepository(
      const InventoryScan(
        id: 'scan-1',
        status: ScanStatus.needsConfirmation,
        images: [],
        detectedItems: [
          DetectedItem(
            id: 'item-1',
            label: 'Plastic bottle',
            quantity: 1,
            unit: 'piece',
            confidence: .72,
            evidence: 'Visible classroom material.',
          ),
        ],
        subject: 'Physics',
        gradeBand: 'Grade 8',
        topic: 'Forces',
        classLabel: '8A',
      ),
    );

    await _pumpApp(
      tester,
      inventoryRepository: repository,
      imageCaptureService: _GalleryImagesCaptureService(imageCount: 1),
    );
    await _tapKey(tester, 'sign_in_submit');
    await _enterTextKey(tester, 'profile_school', 'Pilot Secondary School');
    await _tapKey(tester, 'profile_save');
    await _tapKey(tester, 'home_start_scan');
    await _tapKey(tester, 'scan_gallery');
    await _tapKey(tester, 'scan_analyze');

    expect(repository.createDraftCount, 1);
    expect(repository.analyzeCount, 1);
    await _expectVisibleText(tester, 'Detected materials');
    await _expectVisibleText(tester, 'Plastic bottle');
  });

  testWidgets(
    'gallery attach caps images, previews them, and removes before analyze',
    (tester) async {
      final repository = _CountingInventoryRepository(
        const InventoryScan(
          id: 'scan-1',
          status: ScanStatus.created,
          images: [],
          detectedItems: [],
          subject: 'Physics',
          gradeBand: 'Grade 8',
          topic: 'Forces',
          classLabel: '8A',
        ),
      );
      final captureService = _GalleryImagesCaptureService(imageCount: 4);

      await _pumpInventoryScreen(
        tester,
        inventoryRepository: repository,
        imageCaptureService: captureService,
        screen: const InventoryCaptureScreen(),
      );
      await tester.pumpAndSettle();

      await _tapKey(tester, 'scan_gallery');
      await tester.pumpAndSettle();

      expect(captureService.lastLimit, 3);
      expect(repository.attachImagesCount, 0);
      expect(
        find.byKey(const ValueKey('scan_image_preview_gallery-1.png')),
        findsOneWidget,
      );
      await _expectVisibleText(
        tester,
        'Only 3 photos can be analyzed at once.',
      );

      await _tapKey(tester, 'scan_image_remove_gallery-2.png');
      await tester.pumpAndSettle();

      expect(find.text('gallery-1.png'), findsOneWidget);
      expect(find.text('gallery-2.png'), findsNothing);
      expect(find.text('gallery-3.png'), findsOneWidget);

      await _tapKey(tester, 'scan_analyze');

      expect(repository.createDraftCount, 1);
      expect(repository.analyzeCount, 1);
      expect(repository.lastAnalyzeImages, hasLength(2));
    },
  );

  testWidgets('lost data recovery errors stay silent on desktop scan screen', (
    tester,
  ) async {
    final scan = InventoryScan(
      id: 'scan-1',
      status: ScanStatus.created,
      images: const [],
      detectedItems: const [],
      subject: 'Physics',
      gradeBand: 'Grade 8',
      topic: 'Forces',
      classLabel: '8A',
    );
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: _CountingInventoryRepository(scan),
      imageCaptureService: _ThrowingLostDataCaptureService(),
      screen: const InventoryCaptureScreen(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not restore interrupted image pick.'),
      findsNothing,
    );
    await _expectVisibleText(tester, 'Capture classroom objects');
  });

  testWidgets('api scan start failure shows configured API URL on analyze', (
    tester,
  ) async {
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: _FailingCreateInventoryRepository(),
      imageCaptureService: FakeImageCaptureService(),
      config: const AppConfig(
        backendMode: BackendMode.api,
        apiBaseUrl: 'http://127.0.0.1:4000',
      ),
      screen: const InventoryCaptureScreen(),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Could not reach the API at http://127.0.0.1:4000. Start the NestJS API and check MCG_API_BASE_URL.',
      ),
      findsNothing,
    );

    await _tapKey(tester, 'scan_gallery');
    await _tapKey(tester, 'scan_analyze');

    await _expectVisibleText(
      tester,
      'Could not reach the API at http://127.0.0.1:4000. Start the NestJS API and check MCG_API_BASE_URL.',
    );
  });

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

  testWidgets('suggested experiments can generate a lesson directly with AI', (
    tester,
  ) async {
    await _pumpApp(tester);

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

    await _tapKey(tester, 'generate_lesson_exp-rubber-band-car');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    await _tapKey(tester, 'open_generated_lesson');

    await _expectVisibleText(tester, 'Editable generated plan');
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

  testWidgets('inventory review supports rename, quantity, and manual add', (
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
    final repository = _CountingInventoryRepository(scan);
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: repository,
      screen: const InventoryReviewScreen(scanId: 'scan-1'),
    );
    await tester.pumpAndSettle();

    await _tapKey(tester, 'inventory_edit_item-1');
    await _enterTextKey(tester, 'inventory_item_label', 'Rubber bands');
    await _enterTextKey(tester, 'inventory_item_quantity', '5');
    await _tapKey(tester, 'inventory_item_save');

    expect(repository.lastUpdatedItems?.first.label, 'Rubber bands');
    expect(repository.lastUpdatedItems?.first.quantity, 5);
    await _expectVisibleText(tester, 'Rubber bands');

    await _tapKey(tester, 'inventory_add_item');
    await _enterTextKey(tester, 'inventory_item_label', 'Binder clips');
    await _enterTextKey(tester, 'inventory_item_quantity', '12');
    await _tapKey(tester, 'inventory_item_save');

    expect(repository.lastUpdatedItems?.last.label, 'Binder clips');
    expect(repository.lastUpdatedItems?.last.quantity, 12);
    await _expectVisibleText(tester, 'Binder clips');
  });

  testWidgets('inventory review load error can retry', (tester) async {
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
    final repository = _RetryInventoryRepository(scan);
    await _pumpInventoryScreen(
      tester,
      inventoryRepository: repository,
      screen: const InventoryReviewScreen(scanId: 'scan-1'),
    );
    await tester.pumpAndSettle();

    await _expectVisibleText(tester, 'Could not load detected materials.');
    await _tapKey(tester, 'inventory_retry_load');

    await _expectVisibleText(tester, 'Rubber band');
    expect(repository.getScanCount, 2);
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
