import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class McColors {
  const McColors._();

  static const appBg = Color(0xFFFAFAF7);
  static const screen = Color(0xFFFFFFFF);
  static const subtle = Color(0xFFF5F2EA);
  static const heading = Color(0xFF2C2C2A);
  static const ink = Color(0xFF2C2C2A);
  static const muted = Color(0xFF5F5E5A);
  static const subtleInk = Color(0xFF9A9994);
  static const primary = Color(0xFF1A24A8);
  static const primaryHover = Color(0xFF141C8A);
  static const primarySoft = Color(0xFFE8EAF8);
  static const accent = Color(0xFFF5B945);
  static const accentSoft = Color(0xFFFDF1D9);
  static const earth = Color(0xFF7A5B14);
  static const tierGreen = Color(0xFF3B6D11);
  static const tierGreenSoft = Color(0xFFEAF3DE);
  static const warning = Color(0xFFB47514);
  static const warningSoft = Color(0xFFFDF1D9);
  static const danger = Color(0xFFA32D2D);
  static const dangerSoft = Color(0xFFFCEBEB);
  static const border = Color(0xFFE5E2D7);
  static const borderStrong = Color(0xFFC8C5B6);

  static const green = primary;
  static const softGreen = primarySoft;
  static const soil = earth;
  static const interactive = primarySoft;
  static const interactiveHover = subtle;
}

class McSpacing {
  const McSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const maxMobileWidth = 448.0;
  static const maxTabletWidth = 720.0;
}

class McRadius {
  const McRadius._();

  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

class McTheme {
  const McTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: McColors.primary,
      brightness: Brightness.light,
      primary: McColors.primary,
      secondary: McColors.accent,
      surface: McColors.screen,
      error: McColors.danger,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: McColors.appBg,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: McColors.heading,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          color: McColors.heading,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.18,
        ),
        titleMedium: TextStyle(
          color: McColors.heading,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.22,
        ),
        bodyLarge: TextStyle(color: McColors.ink, fontSize: 15, height: 1.4),
        bodyMedium: TextStyle(color: McColors.ink, fontSize: 14, height: 1.35),
        labelMedium: TextStyle(
          color: McColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: .88,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: McColors.screen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          borderSide: const BorderSide(color: McColors.border, width: .5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          borderSide: const BorderSide(color: McColors.border, width: .5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          borderSide: const BorderSide(color: McColors.primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: McColors.screen,
        selectedColor: McColors.primarySoft,
        disabledColor: McColors.subtle,
        checkmarkColor: McColors.primary,
        side: const BorderSide(color: McColors.border, width: .5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
        ),
        labelStyle: const TextStyle(
          color: McColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: McColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: McColors.ink,
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
        color: McColors.screen,
        borderRadius: BorderRadius.circular(McRadius.md),
        border: Border.all(color: McColors.border, width: .5),
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
        ? McColors.screen
        : McColors.primary;
    final foreground = secondary ? McColors.primary : Colors.white;
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
        disabledBackgroundColor: McColors.subtle,
        disabledForegroundColor: McColors.muted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(McRadius.sm),
          side: secondary
              ? const BorderSide(color: McColors.border, width: .5)
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
      McBadgeTone.good => (McColors.tierGreen, McColors.tierGreenSoft),
      McBadgeTone.warning => (McColors.warning, McColors.warningSoft),
      McBadgeTone.danger => (McColors.danger, McColors.dangerSoft),
      McBadgeTone.neutral => (McColors.muted, McColors.subtle),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.$2,
                borderRadius: BorderRadius.circular(McRadius.xs),
                border: Border.all(
                  color: colors.$1.withValues(alpha: .2),
                  width: .5,
                ),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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
          Icon(icon, color: McColors.primary, size: 42),
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

class McBrandMark extends StatelessWidget {
  const McBrandMark({this.size = 44, super.key});

  static const assetPath = 'assets/macgyver.svg';

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'MacGyver Classroom',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.contain,
          semanticsLabel: 'MacGyver Classroom',
        ),
      ),
    );
  }
}
