import 'package:flutter/material.dart';

class McColors {
  const McColors._();

  static const appBg = Color(0xFFF4EFE4);
  static const screen = Color(0xFFF8FAF7);
  static const heading = Color(0xFF1F2916);
  static const ink = Color(0xFF172718);
  static const muted = Color(0xFF5C6B5F);
  static const green = Color(0xFF355B31);
  static const softGreen = Color(0xFF79965E);
  static const soil = Color(0xFFCD924A);
  static const interactive = Color(0xFFEEF4EA);
  static const interactiveHover = Color(0xFFDDE8D3);
  static const danger = Color(0xFF9F2D22);
  static const warning = Color(0xFFA05B14);
  static const border = Color(0x1F1F2916);
}

class McSpacing {
  const McSpacing._();

  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const maxMobileWidth = 448.0;
  static const maxTabletWidth = 720.0;
}

class McTheme {
  const McTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: McColors.green,
      brightness: Brightness.light,
      primary: McColors.green,
      secondary: McColors.soil,
      surface: Colors.white,
      error: McColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: McColors.appBg,
      fontFamily: 'System',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: McColors.heading,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        titleLarge: TextStyle(
          color: McColors.heading,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: McColors.heading,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: McColors.ink, fontSize: 16, height: 1.35),
        bodyMedium: TextStyle(color: McColors.ink, fontSize: 14, height: 1.35),
        labelMedium: TextStyle(
          color: McColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: .8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: McColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: McColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: McColors.green, width: 1.5),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: McColors.heading,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}

class McResponsiveFrame extends StatelessWidget {
  const McResponsiveFrame({required this.child, this.maxWidth, super.key});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxWidth ?? McSpacing.maxMobileWidth;
        final width = availableWidth > 700
            ? maxWidth ?? McSpacing.maxMobileWidth
            : availableWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: child,
          ),
        );
      },
    );
  }
}

class McCard extends StatelessWidget {
  const McCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final decoratedCard = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: McColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1431491E),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite) {
          return decoratedCard;
        }

        return SizedBox(width: double.infinity, child: decoratedCard);
      },
    );
  }
}

class McButton extends StatelessWidget {
  const McButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.secondary = false,
    this.warning = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool secondary;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final background = warning
        ? McColors.warning
        : secondary
        ? Colors.white
        : McColors.green;
    final foreground = secondary ? McColors.green : Colors.white;
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_forward_rounded),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: McColors.interactiveHover,
        disabledForegroundColor: McColors.muted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: secondary
              ? const BorderSide(color: McColors.border)
              : BorderSide.none,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isFinite) {
          return button;
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.maybeSizeOf(context)?.width ??
                McSpacing.maxMobileWidth,
          ),
          child: button,
        );
      },
    );
  }
}

class McBadge extends StatelessWidget {
  const McBadge({
    required this.label,
    this.tone = McBadgeTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final McBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      McBadgeTone.good => (McColors.green, const Color(0xFFEAF3E5)),
      McBadgeTone.warning => (McColors.warning, const Color(0xFFFFF3DF)),
      McBadgeTone.danger => (McColors.danger, const Color(0xFFFFEAE6)),
      McBadgeTone.neutral => (McColors.muted, McColors.interactive),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackWidth =
            MediaQuery.maybeSizeOf(context)?.width ?? McSpacing.maxMobileWidth;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : fallbackWidth;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Tooltip(
            message: label,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.$2,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.$1.withValues(alpha: .18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: colors.$1),
                    const SizedBox(width: 5),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        color: colors.$1,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum McBadgeTone { good, warning, danger, neutral }

class McSectionHeader extends StatelessWidget {
  const McSectionHeader({
    required this.eyebrow,
    required this.title,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 3),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth.isFinite && constraints.maxWidth < 360;
        if (trailing == null) {
          return heading;
        }
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: trailing),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: heading),
            const SizedBox(width: 12),
            Flexible(flex: 0, child: trailing),
          ],
        );
      },
    );
  }
}

class McEmptyState extends StatelessWidget {
  const McEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return McCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: McColors.softGreen, size: 42),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: McColors.muted),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
