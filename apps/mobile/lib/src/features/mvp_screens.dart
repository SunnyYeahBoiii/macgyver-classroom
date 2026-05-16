import 'package:flutter/material.dart';
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
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.4,
            colors: [Color(0xFFEAF3E5), McColors.appBg],
          ),
        ),
        child: SafeArea(
          child: McResponsiveFrame(
            child: McScroll(
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.science_outlined,
                  color: McColors.green,
                  size: 58,
                ),
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
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    McBadge(
                      label: 'Mock backend',
                      tone: McBadgeTone.good,
                      icon: Icons.offline_bolt_outlined,
                    ),
                    McBadge(label: 'Teacher MVP', icon: Icons.school_outlined),
                    McBadge(
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

class InventoryCaptureScreen extends StatefulWidget {
  const InventoryCaptureScreen({super.key});

  @override
  State<InventoryCaptureScreen> createState() => _InventoryCaptureScreenState();
}

class _InventoryCaptureScreenState extends State<InventoryCaptureScreen> {
  InventoryScan? _scan;
  String? _error;
  var _busy = false;

  Future<void> _ensureScan() async {
    if (_scan != null || _error != null) return;
    try {
      final deps = AppScope.of(context);
      final profile = await deps.profileRepository.getProfile();
      final scan = await deps.inventoryRepository.createDraft(profile: profile);
      deps.analyticsRepository.track('scan_created', {'scan_id': scan.id});
      if (mounted) {
        setState(() => _scan = scan);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not start an inventory scan.');
      }
    }
  }

  Future<void> _attach(Future<List<ScanImage>> future) async {
    final deps = AppScope.of(context);
    if (_error != null) setState(() => _error = null);
    await _ensureScan();
    if (!mounted) return;
    try {
      final images = await future;
      if (!mounted || images.isEmpty || _scan == null) return;
      final next = await deps.inventoryRepository.attachImages(_scan!.id, [
        ..._scan!.images,
        ...images,
      ]);
      deps.analyticsRepository.track('scan_image_uploaded', {
        'source': images.first.source,
      });
      if (mounted) setState(() => _scan = next);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not add the selected classroom photo.');
      }
    }
  }

  Future<List<ScanImage>> _captureCamera(ImageCaptureService service) async {
    final image = await service.captureCamera();
    return image == null ? const <ScanImage>[] : [image];
  }

  @override
  Widget build(BuildContext context) {
    _ensureScan();
    final deps = AppScope.of(context);
    final scan = _scan;
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
                  'Topic: ${scan?.topic ?? 'Loading...'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (scan == null || scan.images.isEmpty)
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
                      for (final image in scan.images)
                        Chip(
                          avatar: const Icon(Icons.image_outlined),
                          label: Text(image.id),
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
                const SizedBox(height: 16),
                _ResponsiveButtonRow(
                  children: [
                    McButton(
                      key: const ValueKey('scan_camera'),
                      label: 'Camera',
                      icon: Icons.camera_alt_outlined,
                      onPressed: () =>
                          _attach(_captureCamera(deps.imageCaptureService)),
                    ),
                    McButton(
                      key: const ValueKey('scan_gallery'),
                      label: 'Gallery',
                      icon: Icons.photo_library_outlined,
                      secondary: true,
                      onPressed: () =>
                          _attach(deps.imageCaptureService.pickGallery()),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                McButton(
                  key: const ValueKey('scan_analyze'),
                  label: _busy ? 'Analyzing...' : 'Analyze inventory',
                  icon: Icons.auto_awesome,
                  onPressed: scan == null || scan.images.isEmpty || _busy
                      ? null
                      : () async {
                          setState(() {
                            _busy = true;
                            _error = null;
                          });
                          try {
                            deps.analyticsRepository.track(
                              'scan_analysis_started',
                              {'scan_id': scan.id},
                            );
                            final analyzed = await deps.inventoryRepository
                                .analyze(scan.id);
                            if (context.mounted) {
                              context.go('/inventory/${analyzed.id}/review');
                            }
                          } catch (_) {
                            if (mounted) {
                              setState(
                                () => _error =
                                    'Could not analyze the inventory photo.',
                              );
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

class InventoryReviewScreen extends StatefulWidget {
  const InventoryReviewScreen({required this.scanId, super.key});

  final String scanId;

  @override
  State<InventoryReviewScreen> createState() => _InventoryReviewScreenState();
}

class _InventoryReviewScreenState extends State<InventoryReviewScreen> {
  InventoryScan? _scan;

  Future<void> _load() async {
    final deps = AppScope.of(context);
    final scan = await deps.inventoryRepository.getScan(widget.scanId);
    if (mounted && scan != _scan) {
      setState(() => _scan = scan);
    }
  }

  Future<void> _saveItems(List<DetectedItem> items) async {
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
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final scan = _scan;
    return MacGyverShell(
      title: 'Confirm Inventory',
      activeRoute: '/scan',
      child: McScroll(
        children: [
          const McSectionHeader(eyebrow: 'Review', title: 'Detected materials'),
          if (scan == null)
            const _LoadingState(label: 'Loading detected materials')
          else ...[
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
                ),
            McButton(
              key: const ValueKey('inventory_add_item'),
              label: 'Add missing item',
              icon: Icons.add,
              secondary: true,
              onPressed: () {
                final item = DetectedItem(
                  id: 'manual-${DateTime.now().millisecondsSinceEpoch}',
                  label: 'Paper clips',
                  quantity: 20,
                  unit: 'pieces',
                  confidence: 1,
                  evidence: 'Added manually by teacher.',
                );
                _saveItems([...scan.detectedItems, item]);
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
              onPressed: scan.confirmedItems.isEmpty
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
  const _DetectedItemCard({required this.item, required this.onChanged});

  final DetectedItem item;
  final ValueChanged<DetectedItem> onChanged;

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

  Future<void> _load() async {
    final scan = await AppScope.of(
      context,
    ).inventoryRepository.getScan(widget.scanId);
    if (mounted && scan != _scan) setState(() => _scan = scan);
  }

  @override
  Widget build(BuildContext context) {
    _load();
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
          if (scan == null)
            const _LoadingState(label: 'Loading confirmed inventory')
          else ...[
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
              label: 'Confirm and match experiments',
              icon: Icons.auto_awesome_outlined,
              onPressed: scan.confirmedItems.isEmpty
                  ? null
                  : () async {
                      final deps = AppScope.of(context);
                      final confirmed = await deps.inventoryRepository.confirm(
                        scan.id,
                      );
                      deps.analyticsRepository.track('inventory_confirmed', {
                        'scan_id': confirmed.id,
                      });
                      if (context.mounted) {
                        context.go('/inventory/${confirmed.id}/experiments');
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
                    McButton(
                      key: ValueKey('suggestion_${suggestion.id}'),
                      label: 'Review details',
                      icon: Icons.arrow_forward,
                      onPressed: () => context.go(
                        '/inventory/${widget.scanId}/experiments/${suggestion.id}',
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
                  const Text(
                    'Safety notes',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
                  _LessonSection(title: 'Flow', items: lesson.flow),
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

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return MacGyverShell(
      title: 'Account',
      activeRoute: '/account',
      child: McScroll(
        children: [
          McCard(
            child: ValueListenableBuilder<AuthState>(
              valueListenable: deps.authController,
              builder: (context, state, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    state.session?.email ?? 'Signed out',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teacher role is active. School admin and content admin roles are model-ready for later slices.',
                  ),
                  const SizedBox(height: 16),
                  McButton(
                    key: const ValueKey('account_sign_out'),
                    label: 'Sign out',
                    icon: Icons.logout,
                    warning: true,
                    onPressed: () => deps.authController.signOut(),
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
