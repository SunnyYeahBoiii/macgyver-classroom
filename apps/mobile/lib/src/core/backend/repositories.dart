import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models.dart';
import '../../app/app_config.dart';

abstract class SessionStore {
  Future<UserSession?> read();
  Future<void> write(UserSession session);
  Future<void> clear();
}

class MemorySessionStore implements SessionStore {
  UserSession? _session;

  @override
  Future<void> clear() async => _session = null;

  @override
  Future<UserSession?> read() async => _session;

  @override
  Future<void> write(UserSession session) async => _session = session;
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'macgyver_session';
  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<UserSession?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(UserSession session) =>
      _storage.write(key: _key, value: session.encode());
}

abstract class AuthRepository {
  Future<UserSession> signIn(String email, String password);
  Future<UserSession> register(String email, String password);
  Future<UserSession> refresh(String refreshToken);
  Future<void> signOut(UserSession session);
}

class MockAuthRepository implements AuthRepository {
  int _counter = 0;

  @override
  Future<UserSession> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (password != 'password123' || !email.contains('@')) {
      throw const AuthException(
        'INVALID_CREDENTIALS',
        'Use teacher@example.com / password123.',
      );
    }
    return UserSession(
      userId: 'teacher-1',
      email: email,
      accessToken: 'mock-access-${++_counter}',
      refreshToken: 'mock-refresh',
      profileComplete: email == 'ready@example.com',
    );
  }

  @override
  Future<UserSession> register(String email, String password) async {
    if (password.length < 8) {
      throw const AuthException(
        'WEAK_PASSWORD',
        'Password must be at least 8 characters.',
      );
    }
    return UserSession(
      userId: 'teacher-new',
      email: email,
      accessToken: 'mock-access-${++_counter}',
      refreshToken: 'mock-refresh',
      profileComplete: false,
    );
  }

  @override
  Future<UserSession> refresh(String refreshToken) async {
    if (refreshToken != 'mock-refresh') {
      throw const AuthException('SESSION_EXPIRED', 'Please sign in again.');
    }
    return UserSession(
      userId: 'teacher-1',
      email: 'teacher@example.com',
      accessToken: 'mock-access-${++_counter}',
      refreshToken: refreshToken,
      profileComplete: true,
    );
  }

  @override
  Future<void> signOut(UserSession session) async {}
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required AppConfig config, http.Client? client})
    : _config = config,
      _client = client ?? http.Client();

  final AppConfig _config;
  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${_config.apiBaseUrl}$path');

  Future<UserSession> _postSession(
    String path,
    Map<String, Object?> body,
  ) async {
    final response = await _client.post(
      _uri(path),
      headers: const {
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(
        'HTTP_${response.statusCode}',
        'Authentication failed.',
      );
    }
    return UserSession.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<UserSession> signIn(String email, String password) =>
      _postSession('/auth/login', {'email': email, 'password': password});

  @override
  Future<UserSession> register(String email, String password) =>
      _postSession('/auth/register', {'email': email, 'password': password});

  @override
  Future<UserSession> refresh(String refreshToken) =>
      _postSession('/auth/refresh', {'refresh_token': refreshToken});

  @override
  Future<void> signOut(UserSession session) async {
    await _client.post(
      _uri('/auth/logout'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${session.accessToken}',
      },
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.code, this.message);

  final String code;
  final String message;
}

class AuthState {
  const AuthState._({
    required this.isLoading,
    required this.session,
    this.error,
  });

  const AuthState.loading() : this._(isLoading: true, session: null);
  const AuthState.signedOut({String? error})
    : this._(isLoading: false, session: null, error: error);
  const AuthState.signedIn(UserSession session)
    : this._(isLoading: false, session: session);

  final bool isLoading;
  final UserSession? session;
  final String? error;

  bool get isSignedIn => session != null;
  bool get profileComplete => session?.profileComplete ?? false;
}

class AuthController extends ValueNotifier<AuthState> {
  AuthController({
    required AuthRepository repository,
    required SessionStore sessionStore,
  }) : _repository = repository,
       _sessionStore = sessionStore,
       super(const AuthState.loading());

  final AuthRepository _repository;
  final SessionStore _sessionStore;

  Future<void> bootstrap() async {
    try {
      final session = await _sessionStore.read();
      value = session == null
          ? const AuthState.signedOut()
          : AuthState.signedIn(session);
    } catch (_) {
      await _sessionStore.clear();
      value = const AuthState.signedOut(
        error: 'Session could not be restored.',
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    value = const AuthState.loading();
    try {
      final session = await _repository.signIn(email.trim(), password);
      await _sessionStore.write(session);
      value = AuthState.signedIn(session);
    } on AuthException catch (error) {
      value = AuthState.signedOut(error: error.message);
    }
  }

  Future<void> register(String email, String password) async {
    value = const AuthState.loading();
    try {
      final session = await _repository.register(email.trim(), password);
      await _sessionStore.write(session);
      value = AuthState.signedIn(session);
    } on AuthException catch (error) {
      value = AuthState.signedOut(error: error.message);
    }
  }

  Future<void> markProfileComplete() async {
    final session = value.session;
    if (session == null) return;
    final updated = session.copyWith(profileComplete: true);
    await _sessionStore.write(updated);
    value = AuthState.signedIn(updated);
  }

  Future<void> signOut() async {
    final session = value.session;
    if (session != null) {
      await _repository.signOut(session);
    }
    await _sessionStore.clear();
    value = const AuthState.signedOut();
  }
}

abstract class AnalyticsRepository {
  void track(String eventName, [Map<String, Object?> properties = const {}]);
  List<String> get events;
}

class MockAnalyticsRepository implements AnalyticsRepository {
  final _events = <String>[];

  @override
  List<String> get events => List.unmodifiable(_events);

  @override
  void track(String eventName, [Map<String, Object?> properties = const {}]) {
    _events.add(eventName);
  }
}

abstract class ProfileRepository {
  Future<TeacherProfile> getProfile();
  Future<TeacherProfile> saveProfile(TeacherProfile profile);
}

class MockProfileRepository implements ProfileRepository {
  TeacherProfile _profile = const TeacherProfile(
    schoolName: '',
    subjects: ['Physics'],
    gradeBands: ['Grade 8'],
    classLabels: ['8A1'],
    defaultTopic: 'Forces and motion',
    teachingNotes: '45-minute activity with low-cost materials.',
  );

  @override
  Future<TeacherProfile> getProfile() async => _profile;

  @override
  Future<TeacherProfile> saveProfile(TeacherProfile profile) async {
    _profile = profile;
    return _profile;
  }
}

abstract class ImageCaptureService {
  Future<ScanImage?> captureCamera();
  Future<List<ScanImage>> pickGallery();
  Future<List<ScanImage>> retrieveLostData();
}

class FakeImageCaptureService implements ImageCaptureService {
  int _count = 0;

  ScanImage _next(String source) => ScanImage(
    id: 'image-${++_count}',
    source: source,
    path: source == 'camera'
        ? 'mock://camera/classroom-cabinet.jpg'
        : 'mock://gallery/lab-table.jpg',
  );

  @override
  Future<ScanImage?> captureCamera() async => _next('camera');

  @override
  Future<List<ScanImage>> pickGallery() async => [
    _next('gallery'),
    _next('gallery'),
  ];

  @override
  Future<List<ScanImage>> retrieveLostData() async => [];
}

abstract class InventoryRepository {
  Future<InventoryScan> createDraft({required TeacherProfile profile});
  Future<InventoryScan> attachImages(String scanId, List<ScanImage> images);
  Future<InventoryScan> analyze(String scanId);
  Future<InventoryScan?> getScan(String scanId);
  Future<InventoryScan> updateItems(String scanId, List<DetectedItem> items);
  Future<InventoryScan> confirm(String scanId);
}

class MockInventoryRepository implements InventoryRepository {
  final _scans = <String, InventoryScan>{};
  int _counter = 0;

  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async {
    final scan = InventoryScan(
      id: 'scan-${++_counter}',
      status: ScanStatus.created,
      images: const [],
      detectedItems: const [],
      subject: profile.subjects.firstOrNull ?? 'Physics',
      gradeBand: profile.gradeBands.firstOrNull ?? 'Grade 8',
      topic: profile.defaultTopic.isEmpty
          ? 'Forces and motion'
          : profile.defaultTopic,
      classLabel: profile.classLabels.firstOrNull ?? 'Pilot class',
    );
    _scans[scan.id] = scan;
    return scan;
  }

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async {
    final scan = _required(
      scanId,
    ).copyWith(status: ScanStatus.uploaded, images: images);
    _scans[scanId] = scan;
    return scan;
  }

  @override
  Future<InventoryScan> analyze(String scanId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final scan = _required(scanId).copyWith(
      status: ScanStatus.needsConfirmation,
      detectedItems: const [
        DetectedItem(
          id: 'item-ruler',
          label: 'Plastic ruler',
          quantity: 2,
          unit: 'pieces',
          confidence: .92,
          evidence: 'Long translucent edges visible on desk.',
        ),
        DetectedItem(
          id: 'item-cup',
          label: 'Plastic cup',
          quantity: 8,
          unit: 'pieces',
          confidence: .86,
          evidence: 'Stacked disposable cups near cabinet.',
        ),
        DetectedItem(
          id: 'item-band',
          label: 'Rubber band',
          quantity: 12,
          unit: 'pieces',
          confidence: .78,
          evidence: 'Small elastic loops in tray.',
        ),
        DetectedItem(
          id: 'item-magnet',
          label: 'Bar magnet',
          quantity: 1,
          unit: 'piece',
          confidence: .71,
          evidence: 'Red-blue rectangular object on shelf.',
          safetyFlags: ['Keep away from electronics'],
        ),
      ],
    );
    _scans[scanId] = scan;
    return scan;
  }

  @override
  Future<InventoryScan?> getScan(String scanId) async => _scans[scanId];

  @override
  Future<InventoryScan> updateItems(
    String scanId,
    List<DetectedItem> items,
  ) async {
    final scan = _required(scanId).copyWith(detectedItems: items);
    _scans[scanId] = scan;
    return scan;
  }

  @override
  Future<InventoryScan> confirm(String scanId) async {
    final scan = _required(scanId);
    if (scan.confirmedItems.isEmpty) {
      throw StateError('Inventory must contain at least one confirmed item.');
    }
    final confirmed = scan.copyWith(status: ScanStatus.confirmed);
    _scans[scanId] = confirmed;
    return confirmed;
  }

  InventoryScan _required(String scanId) {
    final scan = _scans[scanId];
    if (scan == null) throw StateError('Scan not found.');
    return scan;
  }
}

abstract class ExperimentRepository {
  Future<List<ExperimentSuggestion>> suggestionsForScan(String scanId);
  Future<ExperimentSuggestion> detail(String experimentId);
  Future<LessonPlan> generateLesson(String scanId, String experimentId);
}

class MockExperimentRepository implements ExperimentRepository {
  MockExperimentRepository({required LessonRepository lessonRepository})
    : _lessonRepository = lessonRepository;

  final LessonRepository _lessonRepository;

  final _suggestions = const [
    ExperimentSuggestion(
      id: 'exp-rubber-band-car',
      title: 'Rubber Band Powered Car',
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Forces and motion',
      durationMinutes: 45,
      difficulty: 'Medium',
      safetyCategory: SafetyCategory.safe,
      availableMaterials: ['Plastic ruler', 'Rubber band', 'Plastic cup'],
      missingMaterials: ['Bottle caps'],
      reasoning:
          'The scan contains elastic material and rigid pieces suitable for exploring stored energy and motion.',
    ),
    ExperimentSuggestion(
      id: 'exp-magnet-map',
      title: 'Magnetic Field Mapping',
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Magnetism',
      durationMinutes: 35,
      difficulty: 'Easy',
      safetyCategory: SafetyCategory.caution,
      availableMaterials: ['Bar magnet', 'Paper clips'],
      missingMaterials: ['Iron filings'],
      reasoning:
          'The magnet can demonstrate field direction with low-risk classroom objects.',
    ),
  ];

  @override
  Future<ExperimentSuggestion> detail(String experimentId) async =>
      _suggestions.firstWhere(
        (item) => item.id == experimentId,
        orElse: () => _suggestions.first,
      );

  @override
  Future<LessonPlan> generateLesson(String scanId, String experimentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final experiment = await detail(experimentId);
    final lesson = LessonPlan(
      id: 'lesson-$experimentId',
      title: '${experiment.title}: 45-minute STEM lesson',
      gradeBand: experiment.gradeBand,
      subject: experiment.subject,
      topic: experiment.topic,
      durationMinutes: 45,
      sourceExperimentId: experiment.id,
      objectives: const [
        'Explain how stored energy can become motion.',
        'Predict how material changes affect distance traveled.',
      ],
      materials: [
        ...experiment.availableMaterials,
        ...experiment.missingMaterials,
      ],
      flow: const [
        'Warm-up: predict which classroom object can store energy.',
        'Build: assemble a simple test rig in small groups.',
        'Test: record three trials and compare distance.',
        'Explain: connect evidence to force and energy vocabulary.',
      ],
      questions: const [
        'Which variable changed the result most?',
        'What evidence shows energy was transferred?',
      ],
      assessment:
          'Exit ticket: one claim, one piece of evidence, one safety reminder.',
      safetyNotes: const [
        'Teacher checks materials before use.',
        'No sharp cutting tools required for the MVP version.',
      ],
    );
    await _lessonRepository.save(lesson);
    return lesson;
  }

  @override
  Future<List<ExperimentSuggestion>> suggestionsForScan(String scanId) async =>
      _suggestions;
}

abstract class LessonRepository {
  Future<List<LessonPlan>> list({
    String query = '',
    bool includeArchived = false,
  });
  Future<LessonPlan?> get(String lessonId);
  Future<LessonPlan> save(LessonPlan lesson);
  Future<LessonPlan> toggleFavorite(String lessonId);
  Future<LessonPlan> archive(String lessonId);
  Future<void> delete(String lessonId);
}

class MockLessonRepository implements LessonRepository {
  final _lessons = <String, LessonPlan>{};

  @override
  Future<LessonPlan?> get(String lessonId) async => _lessons[lessonId];

  @override
  Future<List<LessonPlan>> list({
    String query = '',
    bool includeArchived = false,
  }) async {
    final q = query.toLowerCase().trim();
    return _lessons.values
        .where((lesson) => includeArchived || !lesson.archived)
        .where(
          (lesson) =>
              q.isEmpty ||
              lesson.title.toLowerCase().contains(q) ||
              lesson.topic.toLowerCase().contains(q),
        )
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));
  }

  @override
  Future<LessonPlan> save(LessonPlan lesson) async {
    final next = _lessons.containsKey(lesson.id)
        ? lesson.copyWith(version: lesson.version + 1)
        : lesson;
    _lessons[lesson.id] = next;
    return next;
  }

  @override
  Future<LessonPlan> toggleFavorite(String lessonId) async {
    final lesson = _required(lessonId);
    final next = lesson.copyWith(favorite: !lesson.favorite);
    _lessons[lessonId] = next;
    return next;
  }

  @override
  Future<LessonPlan> archive(String lessonId) async {
    final lesson = _required(lessonId).copyWith(archived: true);
    _lessons[lessonId] = lesson;
    return lesson;
  }

  @override
  Future<void> delete(String lessonId) async {
    _lessons.remove(lessonId);
  }

  LessonPlan _required(String lessonId) {
    final lesson = _lessons[lessonId];
    if (lesson == null) throw StateError('Lesson not found.');
    return lesson;
  }
}

class ExportRepository {
  Future<String> copyMarkdown(LessonPlan lesson) async {
    await Clipboard.setData(ClipboardData(text: lesson.toMarkdown()));
    return 'Markdown copied';
  }

  Future<String> exportPdf(LessonPlan lesson) async =>
      'mock://lesson-exports/${lesson.id}-v${lesson.version}.pdf';

  Future<String> createShareLink(LessonPlan lesson) async =>
      'https://mock.macgyver.local/lessons/${lesson.id}';
}

class FeedbackRepository {
  final submitted = <FeedbackEntry>[];

  Future<void> submit(FeedbackEntry feedback) async {
    submitted.add(feedback);
  }
}

extension FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
