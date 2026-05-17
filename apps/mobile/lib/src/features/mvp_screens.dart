import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

import '../app/app_bootstrap.dart';
import '../core/backend/repositories.dart';
import '../core/design_system/design_system.dart';
import '../core/models.dart';
import 'shell/macgyver_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: 'teacher@example.com');
  final _password = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: McColors.appBg),
        child: SafeArea(
          child: McResponsiveFrame(
            child: McScroll(
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              children: [
                const SizedBox(height: 20),
                const Align(child: McBrandMark(size: 64)),
                Text(
                  'MacGyver Classroom',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Turn classroom objects into safe STEM lessons.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: McColors.muted),
                ),
                McCard(
                  child: ValueListenableBuilder<AuthState>(
                    valueListenable: deps.authController,
                    builder: (context, state, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const ValueKey('sign_in_email'),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('sign_in_password'),
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          if (state.error != null) ...[
                            const SizedBox(height: 12),
                            McBadge(
                              label: state.error!,
                              tone: McBadgeTone.danger,
                              icon: Icons.error_outline,
                            ),
                          ],
                          const SizedBox(height: 16),
                          McButton(
                            key: const ValueKey('sign_in_submit'),
                            label: state.isLoading
                                ? 'Signing in...'
                                : 'Sign in',
                            icon: Icons.login,
                            onPressed: state.isLoading
                                ? null
                                : () => deps.authController.signIn(
                                    _email.text,
                                    _password.text,
                                  ),
                          ),
                          const SizedBox(height: 10),
                          McButton(
                            key: const ValueKey('google_disabled'),
                            label: 'Google sign-in unavailable',
                            icon: Icons.g_mobiledata,
                            secondary: true,
                            onPressed: null,
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('Create pilot account'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController(text: 'new.teacher@example.com');
  final _password = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return MacGyverStandaloneShell(
      title: 'Create Account',
      activeRoute: '/account',
      showBottomDock: false,
      child: McScroll(
        children: [
          McCard(
            child: ValueListenableBuilder<AuthState>(
              valueListenable: deps.authController,
              builder: (context, state, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    McBadge(
                      label: state.error!,
                      tone: McBadgeTone.danger,
                      icon: Icons.error_outline,
                    ),
                  ],
                  const SizedBox(height: 16),
                  McButton(
                    key: const ValueKey('register_submit'),
                    label: state.isLoading
                        ? 'Creating account...'
                        : 'Create account',
                    icon: Icons.person_add_alt_1,
                    onPressed: state.isLoading
                        ? null
                        : () => deps.authController.register(
                            _email.text,
                            _password.text,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return MacGyverShell(
      title: 'Teacher Dashboard',
      activeRoute: '/home',
      child: McScroll(
        children: [
          if (deps.config.validationError != null)
            McCard(
              child: McBadge(
                label: deps.config.validationError!,
                tone: McBadgeTone.warning,
                icon: Icons.settings_outlined,
              ),
            ),
          const McSectionHeader(
            eyebrow: 'Today',
            title: 'Photo-to-lesson demo path',
          ),
          McCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    McBadge(
                      label: deps.config.useMockBackend
                          ? 'Mock backend'
                          : 'API backend',
                      tone: deps.config.useMockBackend
                          ? McBadgeTone.warning
                          : McBadgeTone.good,
                      icon: deps.config.useMockBackend
                          ? Icons.offline_bolt_outlined
                          : Icons.cloud_done_outlined,
                    ),
                    const McBadge(
                      label: 'Teacher MVP',
                      icon: Icons.school_outlined,
                    ),
                    const McBadge(
                      label: 'Safety checks',
                      tone: McBadgeTone.warning,
                      icon: Icons.health_and_safety_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Start with a classroom photo, confirm inventory, pick an experiment, then generate a 45-minute lesson.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                McButton(
                  key: const ValueKey('home_start_scan'),
                  label: 'Scan classroom items',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => context.go('/scan'),
                ),
              ],
            ),
          ),
          _MetricRow(
            values: const [
              ('4', 'detected items'),
              ('2', 'suggestions'),
              ('45m', 'lesson target'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.values});

  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columns = width < 420 ? 1 : values.length;
        final itemWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final value in values)
              SizedBox(
                width: itemWidth,
                child: Semantics(
                  label: '${value.$1} ${value.$2}',
                  child: McCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.$1,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          value.$2,
                          style: const TextStyle(
                            color: McColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResponsiveButtonRow extends StatelessWidget {
  const _ResponsiveButtonRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RetryableErrorState extends StatelessWidget {
  const _RetryableErrorState({
    required this.message,
    required this.buttonKey,
    required this.buttonLabel,
    required this.onRetry,
  });

  final String message;
  final Key buttonKey;
  final String buttonLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return McCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          McBadge(
            label: message,
            tone: McBadgeTone.danger,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: 12),
          McButton(
            key: buttonKey,
            label: buttonLabel,
            icon: Icons.refresh,
            secondary: true,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _school = TextEditingController();
  final _topic = TextEditingController();
  final _notes = TextEditingController();
  final _classLabel = TextEditingController(text: '8A1');
  var _subject = 'Physics';
  var _grade = 'Grade 8';
  String? _error;
  var _loaded = false;
  var _saving = false;

  @override
  void dispose() {
    _school.dispose();
    _topic.dispose();
    _notes.dispose();
    _classLabel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final profile = await AppScope.of(context).profileRepository.getProfile();
      _school.text = profile.schoolName;
      _topic.text = profile.defaultTopic;
      _notes.text = profile.teachingNotes;
      _classLabel.text = profile.classLabels.firstOrNull ?? '8A1';
      _subject = profile.subjects.firstOrNull ?? 'Physics';
      _grade = profile.gradeBands.firstOrNull ?? 'Grade 8';
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load profile defaults.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final deps = AppScope.of(context);
    return MacGyverShell(
      title: 'Teacher Profile',
      activeRoute: '/account',
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Context',
            title: 'Classroom defaults',
          ),
          McCard(
            child: Column(
              children: [
                TextField(
                  key: const ValueKey('profile_school'),
                  controller: _school,
                  decoration: const InputDecoration(labelText: 'School name'),
                ),
                const SizedBox(height: 12),
                _ChoiceRow(
                  label: 'Subject',
                  value: _subject,
                  options: const ['Physics', 'STEM', 'Technology'],
                  onChanged: (v) => setState(() => _subject = v),
                ),
                const SizedBox(height: 12),
                _ChoiceRow(
                  label: 'Grade',
                  value: _grade,
                  options: const ['Grade 6', 'Grade 8', 'Grade 10'],
                  onChanged: (v) => setState(() => _grade = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _classLabel,
                  decoration: const InputDecoration(labelText: 'Class label'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topic,
                  decoration: const InputDecoration(
                    labelText: 'Default lesson topic',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  decoration: const InputDecoration(
                    labelText: 'Teaching notes',
                  ),
                  minLines: 2,
                  maxLines: 3,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  McBadge(
                    label: _error!,
                    tone: McBadgeTone.danger,
                    icon: Icons.error_outline,
                  ),
                ],
                const SizedBox(height: 16),
                McButton(
                  key: const ValueKey('profile_save'),
                  label: _saving ? 'Saving profile...' : 'Save profile',
                  icon: Icons.check_circle_outline,
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() {
                            _error = null;
                            _saving = true;
                          });
                          try {
                            final profile = TeacherProfile(
                              schoolName: _school.text.trim().isEmpty
                                  ? 'Pilot Secondary School'
                                  : _school.text.trim(),
                              subjects: [_subject],
                              gradeBands: [_grade],
                              classLabels: [
                                _classLabel.text.trim().isEmpty
                                    ? 'Pilot class'
                                    : _classLabel.text.trim(),
                              ],
                              defaultTopic: _topic.text.trim().isEmpty
                                  ? 'Forces and motion'
                                  : _topic.text.trim(),
                              teachingNotes: _notes.text.trim(),
                            );
                            await deps.profileRepository.saveProfile(profile);
                            deps.analyticsRepository.track(
                              profile.isComplete
                                  ? 'profile_completed'
                                  : 'profile_updated',
                            );
                            await deps.authController.markProfileComplete();
                            if (context.mounted) context.go('/home');
                          } catch (_) {
                            if (mounted) {
                              setState(
                                () => _error =
                                    'Could not save profile. Check required fields and try again.',
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: value == option,
                  onSelected: (_) => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _camera;
  String? _error;
  var _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _camera != null) {
      _initializeController(_camera!);
    }
  }

  Future<void> _initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _error = 'No camera is available.');
        return;
      }
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _camera = camera;
      await _initializeController(camera);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Camera preview is unavailable.');
      }
    }
  }

  Future<void> _initializeController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller?.dispose();
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() => _error = null);
    } on CameraException catch (error) {
      if (mounted) {
        setState(() => _error = error.description ?? 'Camera access failed.');
      }
    }
  }

  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final controller = _controller;
      if (controller != null && controller.value.isInitialized) {
        final file = await controller.takePicture();
        final bytes = await file.readAsBytes();
        if (mounted) {
          context.pop(
            ScanImage(
              id: file.name,
              source: 'camera',
              path: file.path,
              mimeType: _mimeTypeForPath(file.path),
              bytes: bytes,
            ),
          );
        }
        return;
      }

      final fallback = await AppScope.of(
        context,
      ).imageCaptureService.captureCamera();
      if (mounted) context.pop(fallback);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('camera_close'),
                    color: Colors.white,
                    tooltip: 'Close camera',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                  const Expanded(
                    child: Text(
                      'Camera Preview',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(McRadius.md),
                    child: RepaintBoundary(
                      child: ColoredBox(
                        color: Colors.black,
                        child:
                            controller != null && controller.value.isInitialized
                            ? CameraPreview(controller)
                            : _CameraFallbackFrame(error: _error),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: FilledButton.icon(
                key: const ValueKey('camera_capture'),
                onPressed: _capturing ? null : _capture,
                icon: const Icon(Icons.camera_alt),
                label: Text(_capturing ? 'Capturing...' : 'Capture'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraFallbackFrame extends StatelessWidget {
  const _CameraFallbackFrame({required this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        color: const Color(0xFF111111),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                color: Colors.white,
                size: 52,
              ),
              const SizedBox(height: 12),
              Text(
                error ?? 'Camera is starting...',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InventoryCaptureScreen extends StatefulWidget {
  const InventoryCaptureScreen({super.key});

  @override
  State<InventoryCaptureScreen> createState() => _InventoryCaptureScreenState();
}

class _InventoryCaptureScreenState extends State<InventoryCaptureScreen>
    with WidgetsBindingObserver {
  InventoryScan? _scan;
  String? _error;
  String? _notice;
  var _pendingImages = <ScanImage>[];
  var _busy = false;
  var _recoveringLostData = false;
  Future<InventoryScan?>? _creatingScan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _primeScanState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recoverLostData();
    }
  }

  Future<void> _primeScanState() async {
    if (!mounted) return;
    await _recoverLostData();
  }

  Future<InventoryScan?> _ensureScan() {
    if (!mounted) return Future<InventoryScan?>.value();
    final scan = _scan;
    if (scan != null) {
      return Future<InventoryScan?>.value(scan);
    }
    return _creatingScan ??= _createScan().whenComplete(() {
      _creatingScan = null;
    });
  }

  Future<InventoryScan?> _createScan() async {
    try {
      final deps = AppScope.of(context);
      final profile = await deps.profileRepository.getProfile();
      final scan = await deps.inventoryRepository.createDraft(profile: profile);
      deps.analyticsRepository.track('scan_created', {'scan_id': scan.id});
      if (mounted) {
        setState(() => _scan = scan);
      }
      return scan;
    } catch (_) {
      if (mounted) {
        final deps = AppScope.of(context);
        final message = deps.config.useMockBackend
            ? 'Could not start an inventory scan.'
            : 'Could not reach the API at ${deps.config.apiBaseUrl}. Start the NestJS API and check MCG_API_BASE_URL.';
        setState(() => _error = message);
      }
      return null;
    }
  }

  Future<void> _recoverLostData() async {
    if (_recoveringLostData) return;
    _recoveringLostData = true;
    try {
      final images = await AppScope.of(
        context,
      ).imageCaptureService.retrieveLostData();
      if (!mounted || images.isEmpty) return;
      await _attach(Future.value(images), recovered: true);
    } catch (_) {
      // Lost-data recovery is best-effort and not supported on every platform.
      // Capture/gallery still work, so do not show a blocking scan notice.
    } finally {
      _recoveringLostData = false;
    }
  }

  Future<void> _attach(
    Future<List<ScanImage>> future, {
    bool recovered = false,
  }) async {
    final deps = AppScope.of(context);
    if (_error != null || _notice != null) {
      setState(() {
        _error = null;
        _notice = null;
      });
    }
    try {
      final images = await future;
      if (!mounted || images.isEmpty) return;
      final currentImages = _displayImagesFor(_scan);
      final availableSlots = maxScanAnalyzeImages - currentImages.length;
      if (availableSlots <= 0) {
        setState(() {
          _notice =
              'Only $maxScanAnalyzeImages photos can be analyzed at once.';
        });
        return;
      }
      final acceptedImages = images.take(availableSlots).toList();
      final nextImages = [...currentImages, ...acceptedImages];
      if (mounted) {
        setState(() {
          _pendingImages = nextImages;
          if (images.length > acceptedImages.length) {
            _notice =
                'Only $maxScanAnalyzeImages photos can be analyzed at once.';
          } else if (recovered) {
            _notice = 'Recovered interrupted image selection.';
          }
        });
      }
      deps.analyticsRepository.track('scan_image_selected', {
        'source': acceptedImages.first.source,
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not add the selected classroom photo.');
      }
    }
  }

  Future<void> _removeImage(ScanImage image) async {
    final nextImages = [
      for (final candidate in _displayImagesFor(_scan))
        if (candidate.id != image.id) candidate,
    ];
    setState(() {
      _pendingImages = nextImages;
      _notice = null;
    });
  }

  Future<List<ScanImage>> _captureCamera() async {
    final image = await context.push<ScanImage>('/scan/camera');
    return image == null ? const <ScanImage>[] : [image];
  }

  List<ScanImage> _displayImagesFor(InventoryScan? scan) {
    if (_pendingImages.isNotEmpty) return _pendingImages;
    final persistedImages = scan?.images ?? const <ScanImage>[];
    return persistedImages;
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final scan = _scan;
    final displayImages = _displayImagesFor(scan);
    return MacGyverShell(
      title: 'Inventory Scan',
      activeRoute: '/scan',
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Vision catalog',
            title: 'Capture classroom objects',
          ),
          McCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Topic: ${scan?.topic ?? 'Ready to analyze'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (displayImages.isEmpty)
                  const McEmptyState(
                    icon: Icons.photo_camera_outlined,
                    title: 'No classroom photo yet',
                    message:
                        'Use Camera or Gallery to add classroom object photos.',
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final image in displayImages)
                        _ScanImagePreview(
                          image: image,
                          onRemove: () => _removeImage(image),
                        ),
                    ],
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  McBadge(
                    label: _error!,
                    tone: McBadgeTone.danger,
                    icon: Icons.error_outline,
                  ),
                ],
                if (_notice != null) ...[
                  const SizedBox(height: 12),
                  McBadge(
                    label: _notice!,
                    tone: McBadgeTone.neutral,
                    icon: Icons.restore,
                  ),
                ],
                const SizedBox(height: 16),
                _ResponsiveButtonRow(
                  children: [
                    McButton(
                      key: const ValueKey('scan_camera'),
                      label: 'Camera',
                      icon: Icons.camera_alt_outlined,
                      onPressed: displayImages.length >= maxScanAnalyzeImages
                          ? null
                          : () => _attach(_captureCamera()),
                    ),
                    McButton(
                      key: const ValueKey('scan_gallery'),
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      secondary: true,
                      onPressed: displayImages.length >= maxScanAnalyzeImages
                          ? null
                          : () => _attach(
                              deps.imageCaptureService.pickGallery(
                                limit:
                                    maxScanAnalyzeImages - displayImages.length,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                McButton(
                  key: const ValueKey('scan_analyze'),
                  label: _busy ? 'Analyzing...' : 'Analyze inventory',
                  icon: Icons.auto_awesome,
                  onPressed: displayImages.isEmpty || _busy
                      ? null
                      : () async {
                          setState(() {
                            _busy = true;
                            _error = null;
                            _notice =
                                'Sending photos to AI for inventory analysis...';
                          });
                          try {
                            final analysisScan = await _ensureScan();
                            if (!mounted || analysisScan == null) return;
                            deps.analyticsRepository.track(
                              'scan_analysis_started',
                              {'scan_id': analysisScan.id},
                            );
                            final analyzed = await deps.inventoryRepository
                                .analyze(
                                  analysisScan.id,
                                  images: displayImages,
                                );
                            if (!mounted) return;
                            if (analyzed.status == ScanStatus.failed) {
                              setState(() {
                                _scan = analyzed;
                                _notice = null;
                                _error =
                                    analyzed.errorMessage ??
                                    'Could not analyze the inventory photo.';
                              });
                              return;
                            }
                            if (context.mounted) {
                              context.go('/inventory/${analyzed.id}/review');
                            }
                          } catch (error) {
                            if (mounted) {
                              setState(() {
                                _notice = null;
                                _error = _messageForError(
                                  error,
                                  'Could not analyze the inventory photo.',
                                );
                              });
                            }
                          } finally {
                            if (mounted) setState(() => _busy = false);
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanImagePreview extends StatelessWidget {
  const _ScanImagePreview({required this.image, required this.onRemove});

  final ScanImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: McColors.screen,
          border: Border.all(color: McColors.border, width: .5),
          borderRadius: BorderRadius.circular(McRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(McRadius.md),
                ),
                child: _ScanImageBitmap(image: image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      image.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  IconButton(
                    key: ValueKey('scan_image_remove_${image.id}'),
                    tooltip: 'Remove photo',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemove,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanImageBitmap extends StatelessWidget {
  const _ScanImageBitmap({required this.image});

  final ScanImage image;

  @override
  Widget build(BuildContext context) {
    final bytes = image.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Image.memory(
        bytes,
        key: ValueKey('scan_image_preview_${image.id}'),
        fit: BoxFit.cover,
        cacheWidth: 296,
        cacheHeight: 222,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const _ScanImagePlaceholder(),
      );
    }

    final dataBase64 = image.dataBase64;
    if (dataBase64 != null && dataBase64.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(dataBase64),
          key: ValueKey('scan_image_preview_${image.id}'),
          fit: BoxFit.cover,
          cacheWidth: 296,
          cacheHeight: 222,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => const _ScanImagePlaceholder(),
        );
      } catch (_) {
        return const _ScanImagePlaceholder();
      }
    }

    return const _ScanImagePlaceholder();
  }
}

class _ScanImagePlaceholder extends StatelessWidget {
  const _ScanImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: McColors.subtle,
      child: Center(
        child: Icon(Icons.image_outlined, color: McColors.muted, size: 32),
      ),
    );
  }
}

String _mimeTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

String _messageForError(Object error, String fallback) {
  if (error is InventoryRequestException && error.message.trim().isNotEmpty) {
    return error.message;
  }
  return fallback;
}

class InventoryReviewScreen extends StatefulWidget {
  const InventoryReviewScreen({required this.scanId, super.key});

  final String scanId;

  @override
  State<InventoryReviewScreen> createState() => _InventoryReviewScreenState();
}

class _InventoryReviewScreenState extends State<InventoryReviewScreen> {
  InventoryScan? _scan;
  String? _loadedScanId;
  String? _loadError;
  String? _actionError;
  var _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant InventoryReviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanId != widget.scanId) {
      _scan = null;
      _loadedScanId = null;
      _loadError = null;
      _actionError = null;
      _loadIfNeeded();
    }
  }

  void _loadIfNeeded() {
    if (_loadedScanId == widget.scanId) return;
    _loadedScanId = widget.scanId;
    _load(widget.scanId);
  }

  Future<void> _load(String scanId) async {
    try {
      final deps = AppScope.of(context);
      final scan = await deps.inventoryRepository.getScan(scanId);
      if (!mounted || widget.scanId != scanId) return;
      if (scan == null) {
        setState(() {
          _scan = null;
          _loadError = 'Scan not found.';
        });
        return;
      }
      setState(() {
        _scan = scan;
        _loadError = null;
      });
    } catch (_) {
      if (mounted && widget.scanId == scanId) {
        setState(() {
          _scan = null;
          _loadError = 'Could not load detected materials.';
        });
      }
    }
  }

  Future<void> _saveItems(List<DetectedItem> items) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _actionError = null;
    });
    try {
      final deps = AppScope.of(context);
      final scan = await deps.inventoryRepository.updateItems(
        widget.scanId,
        items,
      );
      deps.analyticsRepository.track('detected_item_corrected', {
        'scan_id': widget.scanId,
      });
      if (mounted) {
        setState(() => _scan = scan);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _actionError = 'Could not save inventory changes.');
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _retryLoad() {
    setState(() {
      _scan = null;
      _loadedScanId = null;
      _loadError = null;
      _actionError = null;
    });
    _loadIfNeeded();
  }

  Future<DetectedItem?> _showItemEditor({DetectedItem? item}) async {
    final labelController = TextEditingController(text: item?.label ?? '');
    final quantityController = TextEditingController(
      text: '${item?.quantity ?? 1}',
    );
    final unitController = TextEditingController(text: item?.unit ?? 'pieces');
    String? validationError;

    final result = await showDialog<DetectedItem>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void submit() {
              final label = labelController.text.trim();
              final quantity =
                  int.tryParse(quantityController.text.trim()) ?? 1;
              final unit = unitController.text.trim().isEmpty
                  ? 'pieces'
                  : unitController.text.trim();
              if (label.isEmpty) {
                setDialogState(() {
                  validationError = 'Enter an item name.';
                });
                return;
              }

              final normalizedQuantity = quantity.clamp(1, 999).toInt();
              final next = item == null
                  ? DetectedItem(
                      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
                      label: label,
                      quantity: normalizedQuantity,
                      unit: unit,
                      confidence: 1,
                      evidence: 'Added manually by teacher.',
                      evidenceDetails: const ['Added manually by teacher.'],
                      rawLabel: label,
                      canonicalName: null,
                    )
                  : item.copyWith(
                      label: label,
                      quantity: normalizedQuantity,
                      unit: unit,
                    );
              Navigator.of(dialogContext).pop(next);
            }

            return AlertDialog(
              title: Text(item == null ? 'Add missing item' : 'Edit item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const ValueKey('inventory_item_label'),
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Item name'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('inventory_item_quantity'),
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('inventory_item_unit'),
                    controller: unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submit(),
                  ),
                  if (validationError != null) ...[
                    const SizedBox(height: 12),
                    McBadge(
                      label: validationError!,
                      tone: McBadgeTone.warning,
                      icon: Icons.info_outline,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  key: const ValueKey('inventory_item_save'),
                  onPressed: submit,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scan = _scan;
    return MacGyverShell(
      title: 'Confirm Inventory',
      activeRoute: '/scan',
      child: McScroll(
        children: [
          const McSectionHeader(eyebrow: 'Review', title: 'Detected materials'),
          if (_loadError != null && scan == null)
            _RetryableErrorState(
              message: _loadError!,
              buttonKey: const ValueKey('inventory_retry_load'),
              buttonLabel: 'Retry inventory',
              onRetry: _retryLoad,
            )
          else if (scan == null)
            const _LoadingState(label: 'Loading detected materials')
          else ...[
            if (_actionError != null) ...[
              McBadge(
                label: _actionError!,
                tone: McBadgeTone.danger,
                icon: Icons.error_outline,
              ),
              const SizedBox(height: 10),
            ],
            if (_saving) ...[
              const McBadge(
                label: 'Saving inventory changes...',
                tone: McBadgeTone.neutral,
                icon: Icons.sync,
              ),
              const SizedBox(height: 10),
            ],
            if (scan.detectedItems.isEmpty)
              const McEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No detected materials',
                message:
                    'Add a missing item or return to scan before matching experiments.',
              )
            else
              for (final item in scan.detectedItems)
                _DetectedItemCard(
                  item: item,
                  onChanged: (next) {
                    _saveItems(
                      scan.detectedItems
                          .map(
                            (current) => current.id == next.id ? next : current,
                          )
                          .toList(),
                    );
                  },
                  onEdit: () async {
                    final next = await _showItemEditor(item: item);
                    if (next == null || !mounted) return;
                    await _saveItems(
                      scan.detectedItems
                          .map(
                            (current) => current.id == next.id ? next : current,
                          )
                          .toList(),
                    );
                  },
                ),
            McButton(
              key: const ValueKey('inventory_add_item'),
              label: 'Add missing item',
              icon: Icons.add,
              secondary: true,
              onPressed: _saving
                  ? null
                  : () async {
                      final item = await _showItemEditor();
                      if (item == null || !mounted) return;
                      await _saveItems([...scan.detectedItems, item]);
                    },
            ),
            if (scan.confirmedItems.isEmpty) ...[
              const SizedBox(height: 10),
              const McBadge(
                label: 'Keep at least one item to continue',
                tone: McBadgeTone.warning,
                icon: Icons.info_outline,
              ),
            ],
            McButton(
              key: const ValueKey('inventory_continue_confirm'),
              label: 'Review final inventory',
              icon: Icons.inventory_2_outlined,
              onPressed: scan.confirmedItems.isEmpty || _saving
                  ? null
                  : () => context.go('/inventory/${scan.id}/confirm'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetectedItemCard extends StatelessWidget {
  const _DetectedItemCard({
    required this.item,
    required this.onChanged,
    required this.onEdit,
  });

  final DetectedItem item;
  final ValueChanged<DetectedItem> onChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return McCard(
      child: Opacity(
        opacity: item.removed ? .45 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                McBadge(
                  label: '${(item.confidence * 100).round()}%',
                  tone: item.confidence < .8
                      ? McBadgeTone.warning
                      : McBadgeTone.good,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.evidence, style: const TextStyle(color: McColors.muted)),
            if (item.safetyFlags.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final flag in item.safetyFlags)
                McBadge(
                  label: flag,
                  tone: McBadgeTone.warning,
                  icon: Icons.health_and_safety_outlined,
                ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Semantics(
                  button: true,
                  enabled: item.quantity > 1,
                  label: 'Decrease ${item.label} quantity',
                  child: ExcludeSemantics(
                    child: IconButton(
                      tooltip: 'Decrease ${item.label} quantity',
                      onPressed: item.quantity <= 1
                          ? null
                          : () => onChanged(
                              item.copyWith(quantity: item.quantity - 1),
                            ),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 72),
                  child: Text(
                    '${item.quantity} ${item.unit}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Increase ${item.label} quantity',
                  child: ExcludeSemantics(
                    child: IconButton(
                      tooltip: 'Increase ${item.label} quantity',
                      onPressed: () =>
                          onChanged(item.copyWith(quantity: item.quantity + 1)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ),
                ),
                TextButton.icon(
                  key: ValueKey('inventory_edit_${item.id}'),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () =>
                      onChanged(item.copyWith(removed: !item.removed)),
                  icon: Icon(item.removed ? Icons.undo : Icons.delete_outline),
                  label: Text(item.removed ? 'Restore' : 'Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryConfirmScreen extends StatefulWidget {
  const InventoryConfirmScreen({required this.scanId, super.key});

  final String scanId;

  @override
  State<InventoryConfirmScreen> createState() => _InventoryConfirmScreenState();
}

class _InventoryConfirmScreenState extends State<InventoryConfirmScreen> {
  InventoryScan? _scan;
  String? _loadedScanId;
  String? _loadError;
  String? _actionError;
  var _confirming = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIfNeeded();
  }

  @override
  void didUpdateWidget(covariant InventoryConfirmScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanId != widget.scanId) {
      _scan = null;
      _loadedScanId = null;
      _loadError = null;
      _actionError = null;
      _loadIfNeeded();
    }
  }

  void _loadIfNeeded() {
    if (_loadedScanId == widget.scanId) return;
    _loadedScanId = widget.scanId;
    _load(widget.scanId);
  }

  Future<void> _load(String scanId) async {
    try {
      final scan = await AppScope.of(
        context,
      ).inventoryRepository.getScan(scanId);
      if (!mounted || widget.scanId != scanId) return;
      if (scan == null) {
        setState(() {
          _scan = null;
          _loadError = 'Scan not found.';
        });
        return;
      }
      setState(() {
        _scan = scan;
        _loadError = null;
      });
    } catch (_) {
      if (mounted && widget.scanId == scanId) {
        setState(() {
          _scan = null;
          _loadError = 'Could not load confirmed inventory.';
        });
      }
    }
  }

  void _retryLoad() {
    setState(() {
      _scan = null;
      _loadedScanId = null;
      _loadError = null;
      _actionError = null;
    });
    _loadIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final scan = _scan;
    return MacGyverShell(
      title: 'Inventory Snapshot',
      activeRoute: '/scan',
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Ready',
            title: 'Use this inventory for matching',
          ),
          if (_loadError != null && scan == null)
            _RetryableErrorState(
              message: _loadError!,
              buttonKey: const ValueKey('inventory_confirm_retry_load'),
              buttonLabel: 'Retry inventory',
              onRetry: _retryLoad,
            )
          else if (scan == null)
            const _LoadingState(label: 'Loading confirmed inventory')
          else ...[
            if (_actionError != null) ...[
              McBadge(
                label: _actionError!,
                tone: McBadgeTone.danger,
                icon: Icons.error_outline,
              ),
              const SizedBox(height: 10),
            ],
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${scan.subject} | ${scan.gradeBand}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  if (scan.confirmedItems.isEmpty)
                    const McEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory is empty',
                      message:
                          'Return to review and keep at least one material before matching experiments.',
                    )
                  else
                    for (final item in scan.confirmedItems)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle_outline,
                          color: McColors.green,
                        ),
                        title: Text(item.label),
                        subtitle: Text('${item.quantity} ${item.unit}'),
                      ),
                ],
              ),
            ),
            McButton(
              key: const ValueKey('inventory_confirm'),
              label: _confirming
                  ? 'Confirming...'
                  : 'Confirm and match experiments',
              icon: Icons.auto_awesome_outlined,
              onPressed: scan.confirmedItems.isEmpty || _confirming
                  ? null
                  : () async {
                      setState(() {
                        _confirming = true;
                        _actionError = null;
                      });
                      try {
                        final deps = AppScope.of(context);
                        final confirmed = await deps.inventoryRepository
                            .confirm(scan.id);
                        deps.analyticsRepository.track('inventory_confirmed', {
                          'scan_id': confirmed.id,
                        });
                        if (context.mounted) {
                          context.go('/inventory/${confirmed.id}/experiments');
                        }
                      } catch (_) {
                        if (mounted) {
                          setState(
                            () => _actionError = 'Could not confirm inventory.',
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _confirming = false);
                        }
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }
}

class ExperimentSuggestionsScreen extends StatefulWidget {
  const ExperimentSuggestionsScreen({required this.scanId, super.key});

  final String scanId;

  @override
  State<ExperimentSuggestionsScreen> createState() =>
      _ExperimentSuggestionsScreenState();
}

class _ExperimentSuggestionsScreenState
    extends State<ExperimentSuggestionsScreen> {
  List<ExperimentSuggestion>? _suggestions;
  String? _error;
  var _loading = false;
  var _safeOnly = false;

  Future<void> _load() async {
    if (_suggestions != null || _loading || _error != null) return;
    _loading = true;
    try {
      final suggestions = await AppScope.of(
        context,
      ).experimentRepository.suggestionsForScan(widget.scanId);
      if (mounted) setState(() => _suggestions = suggestions);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not load experiment suggestions.');
      }
    } finally {
      _loading = false;
    }
  }

  void _retryLoad() {
    setState(() {
      _error = null;
      _suggestions = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final suggestions = (_suggestions ?? [])
        .where(
          (item) => !_safeOnly || item.safetyCategory == SafetyCategory.safe,
        )
        .toList();
    return MacGyverShell(
      title: 'Experiment Matches',
      activeRoute: '/lessons',
      child: McScroll(
        children: [
          McSectionHeader(
            eyebrow: 'Matching',
            title: 'Suggested experiments',
            trailing: FilterChip(
              key: const ValueKey('filter_safe_only'),
              selected: _safeOnly,
              onSelected: (value) => setState(() => _safeOnly = value),
              label: const Text('Safe only'),
            ),
          ),
          if (_error != null)
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  McBadge(
                    label: _error!,
                    tone: McBadgeTone.danger,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: 12),
                  McButton(
                    label: 'Retry suggestions',
                    icon: Icons.refresh,
                    secondary: true,
                    onPressed: _retryLoad,
                  ),
                ],
              ),
            )
          else if (_suggestions == null)
            const _LoadingState(label: 'Loading experiment suggestions')
          else if (suggestions.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const McEmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'No suggestions match',
                  message: 'Clear filters or add more confirmed materials.',
                ),
                if (_safeOnly) ...[
                  const SizedBox(height: 12),
                  McButton(
                    label: 'Clear safe-only filter',
                    icon: Icons.filter_alt_off_outlined,
                    secondary: true,
                    onPressed: () => setState(() => _safeOnly = false),
                  ),
                ],
              ],
            )
          else
            for (final suggestion in suggestions)
              McCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        McBadge(
                          label:
                              suggestion.safetyCategory == SafetyCategory.safe
                              ? 'Safe'
                              : 'Check',
                          tone: suggestion.safetyCategory == SafetyCategory.safe
                              ? McBadgeTone.good
                              : McBadgeTone.warning,
                          icon: Icons.health_and_safety_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${suggestion.gradeBand} | ${suggestion.subject} | ${suggestion.durationMinutes} min',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion.reasoning,
                      style: const TextStyle(color: McColors.muted),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final material in suggestion.availableMaterials)
                          McBadge(label: material, tone: McBadgeTone.good),
                        for (final material in suggestion.missingMaterials)
                          McBadge(
                            label: 'Missing: $material',
                            tone: McBadgeTone.warning,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: McButton(
                            key: ValueKey('suggestion_${suggestion.id}'),
                            label: 'Review details',
                            icon: Icons.arrow_forward,
                            secondary: true,
                            onPressed: () => context.go(
                              '/inventory/${widget.scanId}/experiments/${suggestion.id}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: McButton(
                            key: ValueKey('generate_lesson_${suggestion.id}'),
                            label: 'Generate with AI',
                            icon: Icons.auto_awesome,
                            onPressed: () => context.go(
                              '/lesson-generation/${widget.scanId}/${suggestion.id}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class ExperimentDetailScreen extends StatefulWidget {
  const ExperimentDetailScreen({
    required this.scanId,
    required this.experimentId,
    super.key,
  });

  final String scanId;
  final String experimentId;

  @override
  State<ExperimentDetailScreen> createState() => _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState extends State<ExperimentDetailScreen> {
  ExperimentSuggestion? _detail;

  Future<void> _load() async {
    if (_detail != null) return;
    final detail = await AppScope.of(
      context,
    ).experimentRepository.detail(widget.experimentId);
    if (mounted) setState(() => _detail = detail);
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final detail = _detail;
    return MacGyverShell(
      title: 'Experiment Detail',
      activeRoute: '/lessons',
      showBottomDock: false,
      child: McScroll(
        children: [
          if (detail == null)
            const _LoadingState(label: 'Loading experiment details')
          else ...[
            McSectionHeader(eyebrow: detail.topic, title: detail.title),
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const McBadge(
                    label: 'Teacher safety check required',
                    tone: McBadgeTone.warning,
                    icon: Icons.health_and_safety_outlined,
                  ),
                  const SizedBox(height: 12),
                  Text(detail.reasoning),
                  const SizedBox(height: 12),
                  Text(
                    'Safety notes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Use no sharp cutting tools. Keep magnets away from electronics. Teacher confirms material condition before export.',
                  ),
                  const SizedBox(height: 16),
                  McButton(
                    key: const ValueKey('open_generation_context'),
                    label: 'Generate lesson context',
                    icon: Icons.edit_note_outlined,
                    onPressed: () => context.go(
                      '/inventory/${widget.scanId}/experiments/${detail.id}/context',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LessonGenerationContextScreen extends StatefulWidget {
  const LessonGenerationContextScreen({
    required this.scanId,
    required this.experimentId,
    super.key,
  });

  final String scanId;
  final String experimentId;

  @override
  State<LessonGenerationContextScreen> createState() =>
      _LessonGenerationContextScreenState();
}

class _LessonGenerationContextScreenState
    extends State<LessonGenerationContextScreen> {
  final _topic = TextEditingController(text: 'Forces and motion');
  var _duration = 45;

  @override
  void dispose() {
    _topic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MacGyverShell(
      title: 'Generation Context',
      activeRoute: '/lessons',
      showBottomDock: false,
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Lesson plan',
            title: 'Review before generation',
          ),
          McCard(
            child: Column(
              children: [
                TextField(
                  key: const ValueKey('generation_topic'),
                  controller: _topic,
                  decoration: const InputDecoration(labelText: 'Topic'),
                ),
                const SizedBox(height: 12),
                _ChoiceRow(
                  label: 'Duration',
                  value: '$_duration min',
                  options: const ['35 min', '45 min', '60 min'],
                  onChanged: (value) => setState(
                    () => _duration = int.parse(value.split(' ').first),
                  ),
                ),
                const SizedBox(height: 16),
                McButton(
                  key: const ValueKey('start_generation'),
                  label: 'Start generation',
                  icon: Icons.auto_awesome,
                  onPressed: () => context.go(
                    '/lesson-generation/${widget.scanId}/${widget.experimentId}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonGenerationProgressScreen extends StatefulWidget {
  const LessonGenerationProgressScreen({
    required this.scanId,
    required this.experimentId,
    super.key,
  });

  final String scanId;
  final String experimentId;

  @override
  State<LessonGenerationProgressScreen> createState() =>
      _LessonGenerationProgressScreenState();
}

class _LessonGenerationProgressScreenState
    extends State<LessonGenerationProgressScreen> {
  LessonPlan? _lesson;
  String? _error;
  var _generating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _generate();
    });
  }

  Future<void> _generate() async {
    if (_lesson != null || _generating) return;
    setState(() {
      _error = null;
      _generating = true;
    });
    try {
      final deps = AppScope.of(context);
      final lesson = await deps.experimentRepository.generateLesson(
        widget.scanId,
        widget.experimentId,
      );
      deps.analyticsRepository.track('lesson_generated', {
        'lesson_id': lesson.id,
      });
      if (mounted) setState(() => _lesson = lesson);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Lesson generation failed safety or schema checks. Retry after reviewing context.',
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacGyverShell(
      title: 'Generating Lesson',
      activeRoute: '/lessons',
      showBottomDock: false,
      child: McScroll(
        children: [
          McCard(
            child: Column(
              children: [
                Icon(
                  _lesson == null
                      ? Icons.auto_awesome
                      : Icons.check_circle_outline,
                  color: McColors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  _lesson == null
                      ? 'Building a safe lesson plan...'
                      : 'Lesson generated',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _lesson == null
                      ? 'Checking schema, safety notes, material availability, and classroom timing.'
                      : _lesson!.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: McColors.muted),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  McBadge(
                    label: _error!,
                    tone: McBadgeTone.danger,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: 12),
                  McButton(
                    label: 'Retry generation',
                    icon: Icons.refresh,
                    secondary: true,
                    onPressed: _generate,
                  ),
                ] else if (_lesson == null)
                  Semantics(
                    label: 'Lesson generation in progress',
                    liveRegion: true,
                    child: const LinearProgressIndicator(),
                  )
                else
                  McButton(
                    key: const ValueKey('open_generated_lesson'),
                    label: 'Open lesson editor',
                    icon: Icons.edit_note,
                    onPressed: () => context.go('/lessons/${_lesson!.id}/edit'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonsHomeScreen extends StatelessWidget {
  const LessonsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MacGyverShell(
      title: 'Lesson Builder',
      activeRoute: '/lessons',
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Next',
            title: 'Generate from confirmed inventory',
          ),
          McCard(
            child: Column(
              children: [
                const Text(
                  'Confirm an inventory scan first, then suggestions and lesson generation appear here.',
                ),
                const SizedBox(height: 14),
                McButton(
                  label: 'Start with scan',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => context.go('/scan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonLibraryScreen extends StatefulWidget {
  const LessonLibraryScreen({super.key});

  @override
  State<LessonLibraryScreen> createState() => _LessonLibraryScreenState();
}

class _LessonLibraryScreenState extends State<LessonLibraryScreen> {
  final _query = TextEditingController();
  List<LessonPlan>? _lessons;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final lessons = await AppScope.of(
      context,
    ).lessonRepository.list(query: _query.text);
    if (mounted) setState(() => _lessons = lessons);
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final lessons = _lessons;
    return MacGyverShell(
      title: 'Lesson Library',
      activeRoute: '/library',
      child: McScroll(
        children: [
          const McSectionHeader(
            eyebrow: 'Saved',
            title: 'Reusable lesson plans',
          ),
          TextField(
            key: const ValueKey('library_search'),
            controller: _query,
            onChanged: (_) => _load(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search lessons',
            ),
          ),
          if (lessons == null)
            const _LoadingState(label: 'Loading lesson library')
          else if (lessons.isEmpty)
            const McEmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No saved lessons yet',
              message:
                  'Generate a lesson from confirmed inventory to fill the library.',
            )
          else
            for (final lesson in lessons)
              McCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lesson.title),
                  subtitle: Text(
                    '${lesson.gradeBand} | ${lesson.subject} | v${lesson.version}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/lessons/${lesson.id}/edit'),
                ),
              ),
        ],
      ),
    );
  }
}

class LessonEditorScreen extends StatefulWidget {
  const LessonEditorScreen({required this.lessonId, super.key});

  final String lessonId;

  @override
  State<LessonEditorScreen> createState() => _LessonEditorScreenState();
}

class _LessonEditorScreenState extends State<LessonEditorScreen> {
  LessonPlan? _lesson;
  String? _loadError;
  var _loaded = false;
  var _loading = false;
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_lesson != null || _loaded || _loading) return;
    _loading = true;
    try {
      final lesson = await AppScope.of(
        context,
      ).lessonRepository.get(widget.lessonId);
      if (mounted && lesson != null) {
        _title.text = lesson.title;
      }
      if (mounted) {
        setState(() {
          _lesson = lesson;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Could not load this lesson.';
          _loaded = true;
        });
      }
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final lesson = _lesson;
    return MacGyverShell(
      title: 'Lesson Editor',
      activeRoute: '/library',
      showBottomDock: false,
      child: McScroll(
        children: [
          if (_loadError != null)
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  McBadge(
                    label: _loadError!,
                    tone: McBadgeTone.danger,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: 12),
                  McButton(
                    label: 'Back to library',
                    icon: Icons.menu_book_outlined,
                    secondary: true,
                    onPressed: () => context.go('/library'),
                  ),
                ],
              ),
            )
          else if (lesson == null && !_loaded)
            const _LoadingState(label: 'Loading lesson editor')
          else if (lesson == null)
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const McEmptyState(
                    icon: Icons.edit_note_outlined,
                    title: 'Lesson not found',
                    message:
                        'Return to the library and select a saved generated lesson.',
                  ),
                  const SizedBox(height: 12),
                  McButton(
                    label: 'Back to library',
                    icon: Icons.menu_book_outlined,
                    secondary: true,
                    onPressed: () => context.go('/library'),
                  ),
                ],
              ),
            )
          else ...[
            McSectionHeader(
              eyebrow: lesson.topic,
              title: 'Editable generated plan',
            ),
            McCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('lesson_title'),
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'Lesson title',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LessonSection(title: 'Objectives', items: lesson.objectives),
                  _LessonSection(title: 'Materials', items: lesson.materials),
                  _LessonSection(
                    title: 'STEM experiment tutorial',
                    items: lesson.flow,
                  ),
                  _LessonSection(title: 'Questions', items: lesson.questions),
                  _LessonSection(
                    title: 'Safety notes',
                    items: lesson.safetyNotes,
                    warning: true,
                  ),
                  const SizedBox(height: 14),
                  McButton(
                    key: const ValueKey('lesson_save'),
                    label: 'Save version',
                    icon: Icons.save_outlined,
                    onPressed: () async {
                      final deps = AppScope.of(context);
                      final saved = await deps.lessonRepository.save(
                        lesson.copyWith(title: _title.text),
                      );
                      deps.analyticsRepository.track('lesson_version_saved', {
                        'lesson_id': saved.id,
                      });
                      if (mounted) {
                        setState(() => _lesson = saved);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ResponsiveButtonRow(
                    children: [
                      McButton(
                        key: const ValueKey('lesson_export'),
                        label: 'Export',
                        icon: Icons.ios_share,
                        secondary: true,
                        onPressed: () => _showExportSheet(context, lesson),
                      ),
                      McButton(
                        key: const ValueKey('lesson_feedback'),
                        label: 'Feedback',
                        icon: Icons.rate_review_outlined,
                        secondary: true,
                        onPressed: () => _showFeedbackSheet(context, lesson),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context, LessonPlan lesson) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ExportSheet(lesson: lesson),
    );
  }

  void _showFeedbackSheet(BuildContext context, LessonPlan lesson) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _FeedbackSheet(lesson: lesson),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({
    required this.title,
    required this.items,
    this.warning = false,
  });

  final String title;
  final List<String> items;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    warning
                        ? Icons.health_and_safety_outlined
                        : Icons.check_circle_outline,
                    size: 18,
                    color: warning ? McColors.warning : McColors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({required this.lesson});

  final LessonPlan lesson;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  var _confirmedSafety = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Export lesson',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              CheckboxListTile(
                key: const ValueKey('safety_confirm'),
                contentPadding: EdgeInsets.zero,
                value: _confirmedSafety,
                onChanged: (value) =>
                    setState(() => _confirmedSafety = value ?? false),
                title: const Text('I reviewed safety notes before export'),
              ),
              if (_message != null)
                McBadge(
                  label: _message!,
                  tone: McBadgeTone.good,
                  icon: Icons.check_circle_outline,
                ),
              const SizedBox(height: 10),
              McButton(
                key: const ValueKey('copy_markdown'),
                label: 'Copy Markdown',
                icon: Icons.copy,
                onPressed: !_confirmedSafety
                    ? null
                    : () async {
                        final message = await deps.exportRepository
                            .copyMarkdown(widget.lesson);
                        deps.analyticsRepository.track(
                          'lesson_markdown_copied',
                          {'lesson_id': widget.lesson.id},
                        );
                        setState(() => _message = message);
                      },
              ),
              const SizedBox(height: 8),
              McButton(
                key: const ValueKey('mock_pdf_export'),
                label: 'Mock PDF export',
                icon: Icons.picture_as_pdf_outlined,
                secondary: true,
                onPressed: !_confirmedSafety
                    ? null
                    : () async {
                        final uri = await deps.exportRepository.exportPdf(
                          widget.lesson,
                        );
                        deps.analyticsRepository.track('lesson_exported', {
                          'lesson_id': widget.lesson.id,
                        });
                        setState(() => _message = uri);
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({required this.lesson});

  final LessonPlan lesson;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  var _rating = 4;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Lesson feedback',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Slider(
                value: _rating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_rating',
                onChanged: (value) => setState(() => _rating = value.round()),
              ),
              TextField(
                controller: _comment,
                decoration: const InputDecoration(labelText: 'Comment'),
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              McButton(
                key: const ValueKey('feedback_submit'),
                label: 'Submit feedback',
                icon: Icons.send_outlined,
                onPressed: () async {
                  await deps.feedbackRepository.submit(
                    FeedbackEntry(
                      lessonId: widget.lesson.id,
                      rating: _rating,
                      issueType: 'quality',
                      prepTimeImpact: 'saved_time',
                      comment: _comment.text,
                    ),
                  );
                  deps.analyticsRepository.track('lesson_rating_submitted', {
                    'lesson_id': widget.lesson.id,
                  });
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  String? _passwordError;
  String? _passwordSuccess;
  var _changingPassword = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPassword.text;
    final newPassword = _newPassword.text;
    final confirmPassword = _confirmPassword.text;

    setState(() {
      _passwordError = null;
      _passwordSuccess = null;
    });

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() => _passwordError = 'All password fields are required.');
      return;
    }
    if (newPassword.length < 8) {
      setState(
        () => _passwordError = 'Password must be at least 8 characters.',
      );
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _passwordError = 'New passwords do not match.');
      return;
    }

    setState(() => _changingPassword = true);
    try {
      final deps = AppScope.of(context);
      await deps.authController.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      deps.analyticsRepository.track('password_changed');
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      if (mounted) setState(() => _passwordSuccess = 'Password updated.');
    } on AuthException catch (error) {
      if (mounted) setState(() => _passwordError = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _passwordError =
              'Could not update password. Check details and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return MacGyverShell(
      title: 'Account',
      activeRoute: '/account',
      child: McScroll(
        children: [
          const McSectionHeader(eyebrow: 'Account', title: 'User profile'),
          McCard(
            child: ValueListenableBuilder<AuthState>(
              valueListenable: deps.authController,
              builder: (context, state, _) {
                final session = state.session;
                return Column(
                  children: [
                    _AccountDetailRow(
                      label: 'Full name',
                      value: session?.fullName ?? 'Signed out',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),
                    _AccountDetailRow(
                      label: 'Email',
                      value: session?.email ?? 'Unavailable',
                      icon: Icons.mail_outline,
                    ),
                    const SizedBox(height: 12),
                    _AccountDetailRow(
                      label: 'Role',
                      value: session?.role == 'teacher'
                          ? 'Teacher'
                          : session?.role ?? 'Unavailable',
                      icon: Icons.school_outlined,
                    ),
                  ],
                );
              },
            ),
          ),
          const McSectionHeader(eyebrow: 'Security', title: 'Change password'),
          McCard(
            child: Column(
              children: [
                TextField(
                  key: const ValueKey('account_current_password'),
                  controller: _currentPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('account_new_password'),
                  controller: _newPassword,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('account_confirm_password'),
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
                  ),
                ),
                if (_passwordError != null || _passwordSuccess != null) ...[
                  const SizedBox(height: 12),
                  McBadge(
                    label: _passwordSuccess ?? _passwordError!,
                    tone: _passwordSuccess == null
                        ? McBadgeTone.danger
                        : McBadgeTone.good,
                    icon: _passwordSuccess == null
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                  ),
                ],
                const SizedBox(height: 16),
                McButton(
                  key: const ValueKey('account_change_password'),
                  label: _changingPassword
                      ? 'Updating password...'
                      : 'Update password',
                  icon: Icons.lock_reset,
                  onPressed: _changingPassword ? null : _changePassword,
                ),
              ],
            ),
          ),
          McCard(
            child: McButton(
              key: const ValueKey('account_sign_out'),
              label: 'Sign out',
              icon: Icons.logout,
              warning: true,
              onPressed: () => deps.authController.signOut(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountDetailRow extends StatelessWidget {
  const _AccountDetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: McColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.labelMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
