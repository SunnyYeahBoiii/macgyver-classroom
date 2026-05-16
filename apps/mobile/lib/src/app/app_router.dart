import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/backend/repositories.dart';
import '../features/mvp_screens.dart';
import '../features/shell/macgyver_shell.dart';

GoRouter createRouter(AuthController authController) {
  return GoRouter(
    initialLocation: _RoutePath.splash,
    refreshListenable: authController,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => _RoutePath.home),
      GoRoute(path: _RoutePath.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: _RoutePath.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: _RoutePath.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MacGyverAppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: _RoutePath.home,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const HomeScreen()),
          ),
          GoRoute(
            path: _RoutePath.profile,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const ProfileScreen()),
          ),
          GoRoute(
            path: _RoutePath.scan,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const InventoryCaptureScreen()),
          ),
          GoRoute(
            path: _RoutePath.library,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const LessonLibraryScreen()),
          ),
          GoRoute(
            path: _RoutePath.lessons,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const LessonsHomeScreen()),
          ),
          GoRoute(
            path: _RoutePath.account,
            pageBuilder: (_, state) =>
                _withoutTransition(state, const AccountScreen()),
          ),
          GoRoute(
            path: '/inventory/:scanId/review',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              InventoryReviewScreen(scanId: state.pathParameters['scanId']!),
            ),
          ),
          GoRoute(
            path: '/inventory/:scanId/confirm',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              InventoryConfirmScreen(scanId: state.pathParameters['scanId']!),
            ),
          ),
          GoRoute(
            path: '/inventory/:scanId/experiments',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              ExperimentSuggestionsScreen(
                scanId: state.pathParameters['scanId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/inventory/:scanId/experiments/:experimentId',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              ExperimentDetailScreen(
                scanId: state.pathParameters['scanId']!,
                experimentId: state.pathParameters['experimentId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/inventory/:scanId/experiments/:experimentId/context',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              LessonGenerationContextScreen(
                scanId: state.pathParameters['scanId']!,
                experimentId: state.pathParameters['experimentId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lesson-generation/:scanId/:experimentId',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              LessonGenerationProgressScreen(
                scanId: state.pathParameters['scanId']!,
                experimentId: state.pathParameters['experimentId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/lessons/:lessonId/edit',
            pageBuilder: (_, state) => _withoutTransition(
              state,
              LessonEditorScreen(lessonId: state.pathParameters['lessonId']!),
            ),
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final auth = authController.value;
      final path = state.uri.path;
      final isSplash = path == _RoutePath.splash;
      final isAuthRoute =
          path == _RoutePath.signIn || path == _RoutePath.register;

      if (auth.isLoading) {
        return isSplash || isAuthRoute ? null : _RoutePath.splash;
      }

      if (!auth.isSignedIn) {
        return isAuthRoute ? null : _RoutePath.signIn;
      }

      if (isSplash || isAuthRoute) {
        return auth.profileComplete ? _RoutePath.home : _RoutePath.profile;
      }

      if (!auth.profileComplete && path != _RoutePath.profile) {
        return _RoutePath.profile;
      }

      return null;
    },
    errorBuilder: (_, state) =>
        ErrorScreen(message: state.error?.toString() ?? 'Route not found.'),
  );
}

Page<void> _withoutTransition(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    child: child,
  );
}

abstract final class _RoutePath {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const scan = '/scan';
  static const library = '/library';
  static const lessons = '/lessons';
  static const account = '/account';
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
