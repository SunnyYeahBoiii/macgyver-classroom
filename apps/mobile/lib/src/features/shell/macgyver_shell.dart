import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';

class MacGyverAppShell extends StatelessWidget {
  const MacGyverAppShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = _ShellRouteConfig.fromLocation(location);
    return _ShellScaffold(
      title: route.title,
      selectedIndex: _ShellDestinations.indexForRoute(route.activeRoute),
      showBottomNavigation: true,
      onDestinationSelected: (index) {
        context.go(_ShellDestinations.items[index].route);
      },
      child: child,
    );
  }
}

class MacGyverShell extends StatelessWidget {
  const MacGyverShell({
    required this.title,
    required this.activeRoute,
    required this.child,
    this.showBottomDock = true,
    super.key,
  });

  final String title;
  final String activeRoute;
  final Widget child;
  final bool showBottomDock;

  @override
  Widget build(BuildContext context) => child;
}

class MacGyverStandaloneShell extends StatelessWidget {
  const MacGyverStandaloneShell({
    required this.title,
    required this.activeRoute,
    required this.child,
    this.showBottomDock = true,
    super.key,
  });

  final String title;
  final String activeRoute;
  final Widget child;
  final bool showBottomDock;

  @override
  Widget build(BuildContext context) {
    return _ShellScaffold(
      title: title,
      selectedIndex: _ShellDestinations.indexForRoute(activeRoute),
      showBottomNavigation: showBottomDock,
      onDestinationSelected: (index) {
        context.go(_ShellDestinations.items[index].route);
      },
      child: child,
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.title,
    required this.selectedIndex,
    required this.showBottomNavigation,
    required this.onDestinationSelected,
    required this.child,
  });

  final String title;
  final int selectedIndex;
  final bool showBottomNavigation;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [Color(0xFFEAF3E5), McColors.appBg],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: McResponsiveFrame(child: _TopBar(title: title)),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: showBottomNavigation
          ? _BottomNavigation(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          : null,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: McColors.border),
            ),
            child: const Icon(Icons.science_outlined, color: McColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MacGyver Classroom',
                  style: TextStyle(
                    color: McColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Account',
            onPressed: () => context.go(_ShellRoute.account),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: McColors.appBg),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 700
                ? McSpacing.maxMobileWidth
                : constraints.maxWidth;
            return Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      for (final item in _ShellDestinations.items)
                        NavigationDestination(
                          key: ValueKey('tab_${item.key}'),
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShellRouteConfig {
  const _ShellRouteConfig({required this.title, required this.activeRoute});

  final String title;
  final String activeRoute;

  static _ShellRouteConfig fromLocation(String location) {
    final path = Uri.parse(location).path;

    if (path == _ShellRoute.profile) {
      return const _ShellRouteConfig(
        title: 'Teacher Profile',
        activeRoute: _ShellRoute.account,
      );
    }
    if (path == _ShellRoute.account) {
      return const _ShellRouteConfig(
        title: 'Account',
        activeRoute: _ShellRoute.account,
      );
    }
    if (path == _ShellRoute.scan) {
      return const _ShellRouteConfig(
        title: 'Inventory Scan',
        activeRoute: _ShellRoute.scan,
      );
    }
    if (path == _ShellRoute.library) {
      return const _ShellRouteConfig(
        title: 'Lesson Library',
        activeRoute: _ShellRoute.library,
      );
    }
    if (path == _ShellRoute.lessons) {
      return const _ShellRouteConfig(
        title: 'Lesson Builder',
        activeRoute: _ShellRoute.lessons,
      );
    }
    if (path.contains('/experiments/') && path.endsWith('/context')) {
      return const _ShellRouteConfig(
        title: 'Generation Context',
        activeRoute: _ShellRoute.lessons,
      );
    }
    if (path.startsWith('/lesson-generation/')) {
      return const _ShellRouteConfig(
        title: 'Generating Lesson',
        activeRoute: _ShellRoute.lessons,
      );
    }
    if (path.contains('/experiments/')) {
      return const _ShellRouteConfig(
        title: 'Experiment Detail',
        activeRoute: _ShellRoute.lessons,
      );
    }
    if (path.endsWith('/experiments')) {
      return const _ShellRouteConfig(
        title: 'Experiment Matches',
        activeRoute: _ShellRoute.lessons,
      );
    }
    if (path.endsWith('/review')) {
      return const _ShellRouteConfig(
        title: 'Confirm Inventory',
        activeRoute: _ShellRoute.scan,
      );
    }
    if (path.endsWith('/confirm')) {
      return const _ShellRouteConfig(
        title: 'Inventory Snapshot',
        activeRoute: _ShellRoute.scan,
      );
    }
    if (path.startsWith('/lessons/') && path.endsWith('/edit')) {
      return const _ShellRouteConfig(
        title: 'Lesson Editor',
        activeRoute: _ShellRoute.library,
      );
    }

    return const _ShellRouteConfig(
      title: 'Teacher Dashboard',
      activeRoute: _ShellRoute.home,
    );
  }
}

class _ShellDestinations {
  const _ShellDestinations._();

  static const items = [
    _ShellDestination(
      key: 'home',
      label: 'Home',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      route: _ShellRoute.home,
    ),
    _ShellDestination(
      key: 'scan',
      label: 'Scan',
      icon: Icons.camera_alt_outlined,
      selectedIcon: Icons.camera_alt,
      route: _ShellRoute.scan,
    ),
    _ShellDestination(
      key: 'lessons',
      label: 'Lessons',
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      route: _ShellRoute.lessons,
    ),
    _ShellDestination(
      key: 'library',
      label: 'Library',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      route: _ShellRoute.library,
    ),
    _ShellDestination(
      key: 'account',
      label: 'Account',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      route: _ShellRoute.account,
    ),
  ];

  static int indexForRoute(String route) {
    final index = items.indexWhere(
      (item) => route == item.route || route.startsWith('${item.route}/'),
    );
    return index == -1 ? 0 : index;
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });

  final String key;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
}

abstract final class _ShellRoute {
  static const home = '/home';
  static const profile = '/profile';
  static const scan = '/scan';
  static const lessons = '/lessons';
  static const library = '/library';
  static const account = '/account';
}

class McScroll extends StatelessWidget {
  const McScroll({required this.children, this.padding, super.key});

  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: key,
      padding: padding ?? const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final child in children) ...[child, const SizedBox(height: 16)],
      ],
    );
  }
}
