import 'package:flutter/material.dart';

import '../core/backend/repositories.dart';
import 'app_config.dart';

export 'macgyver_app.dart';

class AppDependencies {
  AppDependencies({
    required this.config,
    required this.authController,
    required this.profileRepository,
    required this.inventoryRepository,
    required this.experimentRepository,
    required this.lessonRepository,
    required this.exportRepository,
    required this.feedbackRepository,
    required this.analyticsRepository,
    required this.imageCaptureService,
  });

  final AppConfig config;
  final AuthController authController;
  final ProfileRepository profileRepository;
  final InventoryRepository inventoryRepository;
  final ExperimentRepository experimentRepository;
  final LessonRepository lessonRepository;
  final ExportRepository exportRepository;
  final FeedbackRepository feedbackRepository;
  final AnalyticsRepository analyticsRepository;
  final ImageCaptureService imageCaptureService;
}

Future<AppDependencies> createAppDependencies({
  AppConfig? config,
  SessionStore? sessionStore,
}) async {
  final effectiveConfig = config ?? AppConfig.fromEnvironment();
  final lessonRepository = MockLessonRepository();
  final authRepository = effectiveConfig.useMockBackend
      ? MockAuthRepository()
      : ApiAuthRepository(config: effectiveConfig);
  final authController = AuthController(
    repository: authRepository,
    sessionStore: sessionStore ?? SecureSessionStore(),
  );
  final dependencies = AppDependencies(
    config: effectiveConfig,
    authController: authController,
    profileRepository: MockProfileRepository(),
    inventoryRepository: MockInventoryRepository(),
    experimentRepository: MockExperimentRepository(
      lessonRepository: lessonRepository,
    ),
    lessonRepository: lessonRepository,
    exportRepository: ExportRepository(),
    feedbackRepository: FeedbackRepository(),
    analyticsRepository: MockAnalyticsRepository(),
    imageCaptureService: FakeImageCaptureService(),
  );
  await authController.bootstrap();
  return dependencies;
}

class AppScope extends InheritedWidget {
  const AppScope({required this.dependencies, required super.child, super.key});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
