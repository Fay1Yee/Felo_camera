import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

enum NothingBadgeVariant {
  primary,
  secondary,
  destructive,
  outline,
  success,
  warning,
}

class NothingBadge extends StatelessWidget {
  final String text;
  final NothingBadgeVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const NothingBadge({
    super.key,
    required this.text,
    this.variant = NothingBadgeVariant.primary,
    this.icon,
    this.onTap,
    this.padding,
  });

  Color get _backgroundColor {
    switch (variant) {
      case NothingBadgeVariant.primary:
        return NothingTheme.brandPrimary;
      case NothingBadgeVariant.secondary:
        return NothingTheme.surfaceSecondary;
      case NothingBadgeVariant.destructive:
        return NothingTheme.error;
      case NothingBadgeVariant.outline:
        return Colors.transparent;
      case NothingBadgeVariant.success:
        return NothingTheme.success;
      case NothingBadgeVariant.warning:
        return NothingTheme.warning;
    }
  }

  Color get _textColor {
    switch (variant) {
      case NothingBadgeVariant.primary:
        return Colors.white;
      case NothingBadgeVariant.secondary:
        return NothingTheme.textPrimary;
      case NothingBadgeVariant.destructive:
        return Colors.white;
      case NothingBadgeVariant.outline:
        return NothingTheme.textPrimary;
      case NothingBadgeVariant.success:
        return Colors.white;
      case NothingBadgeVariant.warning:
        return Colors.white;
    }
  }

  Color? get _borderColor {
    switch (variant) {
      case NothingBadgeVariant.outline:
        return NothingTheme.gray300;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _backgroundColor,
        border: _borderColor != null ? Border.all(color: _borderColor!) : null,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: icon,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeXs,
              fontWeight: NothingTheme.fontWeightMedium,
              color: _textColor,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    }

    return child;
  }
}

// Convenience constructors for common badge types
class NothingBadges {
  static Widget primary(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.primary,
      icon: icon,
      onTap: onTap,
    );
  }

  static Widget secondary(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.secondary,
      icon: icon,
      onTap: onTap,
    );
  }

  static Widget destructive(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.destructive,
      icon: icon,
      onTap: onTap,
    );
  }

  static Widget outline(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.outline,
      icon: icon,
      onTap: onTap,
    );
  }

  static Widget success(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.success,
      icon: icon,
      onTap: onTap,
    );
  }

  static Widget warning(String text, {Widget? icon, VoidCallback? onTap}) {
    return NothingBadge(
      text: text,
      variant: NothingBadgeVariant.warning,
      icon: icon,
      onTap: onTap,
    );
  }
}