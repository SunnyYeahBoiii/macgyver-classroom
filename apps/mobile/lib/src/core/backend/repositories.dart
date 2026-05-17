import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models.dart';
import '../../app/app_config.dart';

const maxScanAnalyzeImages = 3;
const maxScanImageBase64Length = 5000000;
const maxScanImageBytesLength = maxScanImageBase64Length * 3 ~/ 4;
const _authorizationHeader = 'authorization';
const _contentTypeHeader = 'content-type';

class InventoryRequestException implements Exception {
  const InventoryRequestException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

Future<String> _buildAnalyzeImagesRequestBody(List<ScanImage> images) async {
  final imagePayloads = <Map<String, Object>>[];
  for (final image in images) {
    final bytes = image.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      if (bytes.length > maxScanImageBytesLength) {
        throw const InventoryRequestException(
          'scan_image_too_large',
          'Selected image is too large. Choose a smaller photo.',
        );
      }
      imagePayloads.add({'mimeType': image.mimeType, 'bytes': bytes});
      continue;
    }

    final dataBase64 = image.dataBase64;
    if (dataBase64 == null || dataBase64.trim().isEmpty) {
      throw const InventoryRequestException(
        'scan_image_data_unavailable',
        'Selected image data is unavailable. Choose the photo again.',
      );
    }
    if (dataBase64.length > maxScanImageBase64Length) {
      throw const InventoryRequestException(
        'scan_image_too_large',
        'Selected image is too large. Choose a smaller photo.',
      );
    }
    imagePayloads.add({'mimeType': image.mimeType, 'dataBase64': dataBase64});
  }

  return compute(_encodeAnalyzeImagesRequestBody, imagePayloads);
}

String _encodeAnalyzeImagesRequestBody(List<Map<String, Object>> images) {
  final encodedImages = <Map<String, String>>[];
  for (final image in images) {
    final dataBase64 =
        image['dataBase64'] as String? ??
        base64Encode(image['bytes'] as Uint8List);
    if (dataBase64.length > maxScanImageBase64Length) {
      throw const InventoryRequestException(
        'scan_image_too_large',
        'Selected image is too large. Choose a smaller photo.',
      );
    }
    encodedImages.add({
      'mimeType': image['mimeType'] as String? ?? 'image/jpeg',
      'dataBase64': dataBase64,
    });
  }

  return jsonEncode({'images': encodedImages});
}

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

class ResilientSessionStore implements SessionStore {
  ResilientSessionStore({required SessionStore primary, SessionStore? fallback})
    : _primary = primary,
      _fallback = fallback ?? MemorySessionStore();

  final SessionStore _primary;
  final SessionStore _fallback;
  var _useFallback = false;

  @override
  Future<UserSession?> read() async {
    if (_useFallback) return _fallback.read();
    try {
      return await _primary.read();
    } catch (_) {
      _useFallback = true;
      return _fallback.read();
    }
  }

  @override
  Future<void> write(UserSession session) async {
    if (!_useFallback) {
      try {
        await _primary.write(session);
        return;
      } catch (_) {
        _useFallback = true;
      }
    }
    await _fallback.write(session);
  }

  @override
  Future<void> clear() async {
    if (!_useFallback) {
      try {
        await _primary.clear();
      } catch (_) {
        _useFallback = true;
      }
    }
    await _fallback.clear();
  }
}

abstract class AuthRepository {
  Future<UserSession> signIn(String email, String password);
  Future<UserSession> register(String email, String password);
  Future<UserSession> refresh(String refreshToken);
  Future<void> changePassword(
    UserSession session,
    String currentPassword,
    String newPassword,
  );
  Future<void> signOut(UserSession session);
}

class MockAuthRepository implements AuthRepository {
  int _counter = 0;
  final _passwords = <String, String>{
    'teacher@example.com': 'password123',
    'ready@example.com': 'password123',
  };

  String _fullNameForEmail(String email) => switch (email) {
    'teacher@example.com' => 'Linh Nguyen',
    'ready@example.com' => 'Ready Teacher',
    _ => email.split('@').first.replaceAll('.', ' '),
  };

  @override
  Future<UserSession> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final normalizedEmail = email.trim();
    final expectedPassword = _passwords[normalizedEmail] ?? 'password123';
    if (password != expectedPassword || !normalizedEmail.contains('@')) {
      throw const AuthException(
        'INVALID_CREDENTIALS',
        'Use teacher@example.com / password123.',
      );
    }
    _passwords.putIfAbsent(normalizedEmail, () => expectedPassword);
    return UserSession(
      userId: 'teacher-1',
      fullName: _fullNameForEmail(normalizedEmail),
      email: normalizedEmail,
      accessToken: 'mock-access-${++_counter}',
      refreshToken: 'mock-refresh',
      profileComplete: normalizedEmail == 'ready@example.com',
    );
  }

  @override
  Future<UserSession> register(String email, String password) async {
    final normalizedEmail = email.trim();
    if (password.length < 8) {
      throw const AuthException(
        'WEAK_PASSWORD',
        'Password must be at least 8 characters.',
      );
    }
    _passwords[normalizedEmail] = password;
    return UserSession(
      userId: 'teacher-new',
      fullName: _fullNameForEmail(normalizedEmail),
      email: normalizedEmail,
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
      fullName: _fullNameForEmail('teacher@example.com'),
      email: 'teacher@example.com',
      accessToken: 'mock-access-${++_counter}',
      refreshToken: refreshToken,
      profileComplete: true,
    );
  }

  @override
  Future<void> changePassword(
    UserSession session,
    String currentPassword,
    String newPassword,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (newPassword.length < 8) {
      throw const AuthException(
        'WEAK_PASSWORD',
        'Password must be at least 8 characters.',
      );
    }
    final expectedPassword = _passwords[session.email] ?? 'password123';
    if (currentPassword != expectedPassword) {
      throw const AuthException(
        'INVALID_PASSWORD',
        'Current password is incorrect.',
      );
    }
    _passwords[session.email] = newPassword;
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
      headers: const {_contentTypeHeader: 'application/json; charset=utf-8'},
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
  Future<void> changePassword(
    UserSession session,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _client.post(
      _uri('/auth/change-password'),
      headers: {
        _authorizationHeader: 'Bearer ${session.accessToken}',
        _contentTypeHeader: 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw AuthException(
        'HTTP_${response.statusCode}',
        'Password update failed.',
      );
    }
  }

  @override
  Future<void> signOut(UserSession session) async {
    await _client.post(
      _uri('/auth/logout'),
      headers: {_authorizationHeader: 'Bearer ${session.accessToken}'},
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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = value.session;
    if (session == null) {
      throw const AuthException('SIGNED_OUT', 'Please sign in again.');
    }
    await _repository.changePassword(session, currentPassword, newPassword);
    await _sessionStore.write(session);
    value = AuthState.signedIn(session);
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
  Future<List<ScanImage>> pickGallery({int? limit});
  Future<List<ScanImage>> retrieveLostData();
}

class FakeImageCaptureService implements ImageCaptureService {
  int _count = 0;

  ScanImage _next(String source) {
    final count = ++_count;
    return ScanImage(
      id: source == 'camera' ? 'camera-$count.jpg' : 'gallery-$count.jpg',
      source: source,
      path: source == 'camera'
          ? 'mock://camera/classroom-cabinet.jpg'
          : 'mock://gallery/lab-table.jpg',
      mimeType: 'image/jpeg',
      bytes: Uint8List.fromList([255, 216, 255, count, 255, 217]),
    );
  }

  @override
  Future<ScanImage?> captureCamera() async => _next('camera');

  @override
  Future<List<ScanImage>> pickGallery({int? limit}) async =>
      [_next('gallery'), _next('gallery')].take(limit ?? 2).toList();

  @override
  Future<List<ScanImage>> retrieveLostData() async => [];
}

abstract class InventoryRepository {
  Future<InventoryScan> createDraft({required TeacherProfile profile});
  Future<InventoryScan> attachImages(String scanId, List<ScanImage> images);
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  });
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
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async {
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
          label: 'Paper cup',
          quantity: 10,
          unit: 'pieces',
          confidence: .86,
          evidence: 'Stacked white paper cups near cabinet.',
          rawLabel: 'paper cup',
          canonicalName: 'paper_cup',
        ),
        DetectedItem(
          id: 'item-paper-plate',
          label: 'Paper plate',
          quantity: 6,
          unit: 'pieces',
          confidence: .84,
          evidence: 'Round shallow paper plates visible beside the cup stack.',
          rawLabel: 'paper plate',
          canonicalName: 'paper_plate',
        ),
        DetectedItem(
          id: 'item-wooden-fork',
          label: 'Wooden fork',
          quantity: 12,
          unit: 'pieces',
          confidence: .81,
          evidence: 'Disposable wooden forks grouped in the tray.',
          rawLabel: 'wooden fork',
          canonicalName: 'wooden_fork',
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

class ApiInventoryRepository implements InventoryRepository {
  ApiInventoryRepository({
    required AppConfig config,
    required AuthController authController,
    http.Client? client,
  }) : _authController = authController,
       _client = client ?? http.Client(),
       _config = config;

  final AuthController _authController;
  final http.Client _client;
  final AppConfig _config;

  Uri _uri(String path) => Uri.parse('${_config.apiBaseUrl}$path');

  Map<String, String> get _headers {
    final token = _authController.value.session?.accessToken;
    return {
      if (token != null) _authorizationHeader: 'Bearer $token',
      _contentTypeHeader: 'application/json; charset=utf-8',
    };
  }

  @override
  Future<InventoryScan> createDraft({required TeacherProfile profile}) async {
    final response = await _client.post(
      _uri('/inventory/scans'),
      headers: _headers,
      body: jsonEncode({
        'subject': profile.subjects.firstOrNull,
        'gradeBand': profile.gradeBands.firstOrNull,
        'classLabel': profile.classLabels.firstOrNull,
        'topic': profile.defaultTopic,
      }),
    );
    return _scanFromResponse(response);
  }

  @override
  Future<InventoryScan> attachImages(
    String scanId,
    List<ScanImage> images,
  ) async {
    final scan = await getScan(scanId);
    if (scan == null) throw StateError('Scan not found.');
    return scan.copyWith(status: ScanStatus.uploaded, images: images);
  }

  @override
  Future<InventoryScan> analyze(
    String scanId, {
    List<ScanImage> images = const [],
  }) async {
    final body = await _buildAnalyzeImagesRequestBody(images);
    final response = await _client.post(
      _uri('/inventory/scans/$scanId/analyze'),
      headers: _headers,
      body: body,
    );
    return _scanFromResponse(response);
  }

  @override
  Future<InventoryScan?> getScan(String scanId) async {
    final response = await _client.get(
      _uri('/inventory/scans/$scanId'),
      headers: _headers,
    );
    if (response.statusCode == 404) return null;
    return _scanFromResponse(response);
  }

  @override
  Future<InventoryScan> updateItems(
    String scanId,
    List<DetectedItem> items,
  ) async {
    final response = await _client.patch(
      _uri('/inventory/scans/$scanId/items'),
      headers: _headers,
      body: jsonEncode({'items': items.map((item) => item.toJson()).toList()}),
    );
    return _scanFromResponse(response);
  }

  @override
  Future<InventoryScan> confirm(String scanId) async {
    final response = await _client.post(
      _uri('/inventory/scans/$scanId/confirm'),
      headers: _headers,
    );
    return _scanFromResponse(response);
  }

  InventoryScan _scanFromResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromResponse(response, 'Inventory request failed.');
    }
    return InventoryScan.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  InventoryRequestException _exceptionFromResponse(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final message = body['message'];
        return InventoryRequestException(
          body['code'] as String? ?? 'HTTP_${response.statusCode}',
          switch (message) {
            String value when value.trim().isNotEmpty => value,
            List value when value.isNotEmpty => value.join(' '),
            _ => fallbackMessage,
          },
        );
      }
    } catch (_) {
      // Fall through to the retry-safe generic message.
    }
    return InventoryRequestException(
      'HTTP_${response.statusCode}',
      fallbackMessage,
    );
  }
}

abstract class ExperimentRepository {
  Future<List<ExperimentSuggestion>> suggestionsForScan(String scanId);
  Future<ExperimentSuggestion> detail(String experimentId);
  Future<LessonPlan> generateLesson(String scanId, String experimentId);
}

bool _isPaperCupSoundExperiment(ExperimentSuggestion experiment) =>
    experiment.id == 'exp-paper-cup-sound' ||
    experiment.id == 'paper-cup-sound-amplifier';

LessonPlan _paperCupSoundTutorialLesson(
  ExperimentSuggestion experiment,
) => LessonPlan(
  id: 'lesson-${experiment.id}',
  title: '${experiment.title}: STEM sound tutorial',
  gradeBand: experiment.gradeBand,
  subject: experiment.subject,
  topic: experiment.topic,
  durationMinutes: 35,
  sourceExperimentId: experiment.id,
  objectives: const [
    'Describe sound as vibration that travels through materials.',
    'Use a paper cup, paper plate, and wooden fork to compare loudness.',
    'Use observations to explain simple sound amplification.',
  ],
  materials: const [
    'Paper cup',
    'Paper plate',
    'Wooden fork',
    'Tape',
    'Student notebook',
  ],
  flow: const [
    'Step 1: Place the paper plate flat on the desk and set the paper cup upright at the center.',
    'Step 2: Tap the paper plate gently with the wooden fork and listen for vibration.',
    'Step 3: Move the paper cup to the edge of the plate and repeat the same gentle taps.',
    'Step 4: Compare which cup position makes the sound louder, clearer, or softer.',
    'Step 5: Record one claim, one observation, and one design change for better amplification.',
  ],
  questions: const [
    'What was vibrating when you heard the sound?',
    'When did the paper cup make the sound louder or clearer?',
    'How did the wooden fork strike position change the result?',
  ],
  assessment:
      'Exit ticket: explain how the paper cup changed the sound using the word vibration.',
  safetyNotes: const [
    'Use gentle tapping only; do not strike near faces or ears.',
    'Do not use cracked wooden forks or sharp broken pieces.',
    'Keep volume low enough for neighboring groups to hear instructions.',
  ],
);

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
    ExperimentSuggestion(
      id: 'exp-paper-cup-sound',
      title: 'Paper Cup Sound Amplifier',
      gradeBand: 'Grade 8',
      subject: 'Physics',
      topic: 'Sound and vibration',
      durationMinutes: 35,
      difficulty: 'Easy',
      safetyCategory: SafetyCategory.safe,
      availableMaterials: ['Paper cup', 'Paper plate', 'Wooden fork'],
      missingMaterials: ['Tape'],
      reasoning:
          'The scan contains lightweight disposable items that can safely demonstrate vibration, sound transfer, and simple resonance.',
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
    if (_isPaperCupSoundExperiment(experiment)) {
      final lesson = _paperCupSoundTutorialLesson(experiment);
      await _lessonRepository.save(lesson);
      return lesson;
    }

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

class ApiExperimentRepository implements ExperimentRepository {
  ApiExperimentRepository({
    required AppConfig config,
    required AuthController authController,
    required LessonRepository lessonRepository,
    http.Client? client,
  }) : _authController = authController,
       _client = client ?? http.Client(),
       _config = config,
       _lessonRepository = lessonRepository;

  final AuthController _authController;
  final http.Client _client;
  final AppConfig _config;
  final LessonRepository _lessonRepository;
  final _detailsById = <String, ExperimentSuggestion>{};

  Uri _uri(String path) => Uri.parse('${_config.apiBaseUrl}$path');

  Map<String, String> get _headers {
    final token = _authController.value.session?.accessToken;
    return {
      if (token != null) _authorizationHeader: 'Bearer $token',
      _contentTypeHeader: 'application/json; charset=utf-8',
    };
  }

  @override
  Future<List<ExperimentSuggestion>> suggestionsForScan(String scanId) async {
    final response = await _client.post(
      _uri('/experiments/match'),
      headers: _headers,
      body: jsonEncode({'scanId': scanId}),
    );
    final suggestions = _suggestionsFromResponse(response);
    for (final suggestion in suggestions) {
      _detailsById[suggestion.id] = suggestion;
    }
    return suggestions;
  }

  @override
  Future<ExperimentSuggestion> detail(String experimentId) async {
    final cached = _detailsById[experimentId];
    if (cached != null) return cached;

    final response = await _client.get(
      _uri('/experiments/$experimentId'),
      headers: _headers,
    );
    final detail = _suggestionFromJson(_objectFromResponse(response));
    _detailsById[detail.id] = detail;
    return detail;
  }

  @override
  Future<LessonPlan> generateLesson(String scanId, String experimentId) async {
    final response = await _client.post(
      _uri('/lessons/generate'),
      headers: _headers,
      body: jsonEncode({'scanId': scanId, 'experimentId': experimentId}),
    );
    final lesson = _lessonFromJson(_lessonObjectFromResponse(response));
    await _lessonRepository.save(lesson);
    return lesson;
  }

  List<ExperimentSuggestion> _suggestionsFromResponse(http.Response response) {
    final body = _jsonFromResponse(response);
    final rawSuggestions = switch (body) {
      final List<dynamic> list => list,
      final Map<String, dynamic> map =>
        map['suggestions'] as List<dynamic>? ??
            map['matches'] as List<dynamic>? ??
            map['results'] as List<dynamic>? ??
            map['items'] as List<dynamic>? ??
            const <dynamic>[],
      _ => const <dynamic>[],
    };
    return rawSuggestions
        .whereType<Map<String, dynamic>>()
        .map(_suggestionFromJson)
        .toList();
  }

  Map<String, dynamic> _objectFromResponse(http.Response response) {
    final body = _jsonFromResponse(response);
    if (body is Map<String, dynamic>) {
      return (body['experiment'] as Map<String, dynamic>?) ?? body;
    }
    throw StateError('Experiment response was not an object.');
  }

  Object? _jsonFromResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('API request failed: ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  Map<String, dynamic> _lessonObjectFromResponse(http.Response response) {
    final body = _jsonFromResponse(response);
    if (body is Map<String, dynamic>) {
      return (body['lesson'] as Map<String, dynamic>?) ?? body;
    }
    throw StateError('Lesson response was not an object.');
  }

  LessonPlan _lessonFromJson(Map<String, dynamic> json) => LessonPlan(
    id: json['id'] as String? ?? 'lesson',
    title: json['title'] as String? ?? 'Generated lesson',
    gradeBand:
        json['gradeBand'] as String? ?? json['grade_band'] as String? ?? '',
    subject: json['subject'] as String? ?? 'Science',
    topic: json['topic'] as String? ?? 'STEM',
    durationMinutes:
        (json['durationMinutes'] as num?)?.round() ??
        (json['duration_minutes'] as num?)?.round() ??
        45,
    objectives: _stringList(json['objectives']),
    materials: _stringList(json['materials']),
    flow: _stringList(
      json['flow'] ?? json['lessonFlow'] ?? json['lesson_flow'],
    ),
    questions: _stringList(
      json['questions'] ??
          json['guidingQuestions'] ??
          json['guiding_questions'],
    ),
    assessment: json['assessment'] as String? ?? '',
    safetyNotes: _stringList(json['safetyNotes'] ?? json['safety_notes']),
    sourceExperimentId:
        json['sourceExperimentId'] as String? ??
        json['source_experiment_id'] as String? ??
        json['experimentId'] as String? ??
        '',
    teacherChecksRequired: _stringList(
      json['teacherChecksRequired'] ?? json['teacher_checks_required'],
    ),
    sourceInventoryScanId:
        json['sourceInventoryScanId'] as String? ??
        json['source_inventory_scan_id'] as String?,
    aiRunId: json['aiRunId'] as String? ?? json['ai_run_id'] as String?,
    favorite: json['favorite'] as bool? ?? false,
    archived: json['archived'] as bool? ?? false,
    version: (json['version'] as num?)?.round() ?? 1,
  );

  ExperimentSuggestion _suggestionFromJson(Map<String, dynamic> json) {
    final experiment = (json['experiment'] as Map<String, dynamic>?) ?? json;
    final matchedMaterials = _materialList(
      json['availableMaterials'] ??
          json['available_materials'] ??
          json['available'] ??
          json['matchedMaterials'],
    );
    final templateMaterials = [
      ..._materialList(
        experiment['requiredMaterials'] ??
            experiment['required_materials'] ??
            json['requiredMaterials'] ??
            json['required_materials'],
      ),
      ..._materialList(
        experiment['optionalMaterials'] ??
            experiment['optional_materials'] ??
            json['optionalMaterials'] ??
            json['optional_materials'],
      ),
    ];
    return ExperimentSuggestion(
      id:
          json['id'] as String? ??
          json['matchId'] as String? ??
          json['experimentId'] as String? ??
          json['templateId'] as String? ??
          experiment['id'] as String? ??
          experiment['templateId'] as String? ??
          'experiment',
      title:
          experiment['title'] as String? ??
          experiment['name'] as String? ??
          json['title'] as String? ??
          'Suggested experiment',
      gradeBand:
          experiment['gradeBand'] as String? ??
          experiment['grade_band'] as String? ??
          json['gradeBand'] as String? ??
          'Grade 8',
      subject:
          experiment['subject'] as String? ??
          json['subject'] as String? ??
          'Science',
      topic:
          experiment['topic'] as String? ?? json['topic'] as String? ?? 'STEM',
      durationMinutes:
          (experiment['durationMinutes'] as num?)?.round() ??
          (experiment['duration_minutes'] as num?)?.round() ??
          (json['durationMinutes'] as num?)?.round() ??
          (json['estimatedMinutes'] as num?)?.round() ??
          45,
      difficulty:
          experiment['difficulty'] as String? ??
          json['difficulty'] as String? ??
          'Medium',
      safetyCategory: _safetyCategoryFromJson(
        experiment['safetyCategory'] ??
            experiment['safety_category'] ??
            json['safetyCategory'] ??
            json['safety_category'],
      ),
      availableMaterials: matchedMaterials.isNotEmpty
          ? matchedMaterials
          : templateMaterials,
      missingMaterials: _stringList(
        json['missingMaterials'] ??
            json['missing_materials'] ??
            json['missing'],
      ),
      reasoning:
          json['reasoning'] as String? ??
          json['explanation'] as String? ??
          json['summary'] as String? ??
          'Matched from confirmed scan items.',
    );
  }

  List<String> _materialList(Object? value) => switch (value) {
    final List<dynamic> list =>
      list
          .map(
            (item) => switch (item) {
              final String text => text,
              final Map<String, dynamic> map =>
                map['displayName'] as String? ??
                    map['canonicalName'] as String? ??
                    '',
              _ => '',
            },
          )
          .where((text) => text.trim().isNotEmpty)
          .toList(),
    final String text when text.trim().isNotEmpty => [text.trim()],
    _ => const <String>[],
  };

  List<String> _stringList(Object? value) => switch (value) {
    final List<dynamic> list => list.whereType<String>().toList(),
    final String text when text.trim().isNotEmpty => [text.trim()],
    _ => const <String>[],
  };

  SafetyCategory _safetyCategoryFromJson(Object? value) {
    final normalized = value?.toString().toLowerCase() ?? '';
    if (normalized.contains('block') || normalized.contains('unsafe')) {
      return SafetyCategory.blocked;
    }
    if (normalized.contains('caution') ||
        normalized.contains('warning') ||
        normalized.contains('check')) {
      return SafetyCategory.caution;
    }
    return SafetyCategory.safe;
  }
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
