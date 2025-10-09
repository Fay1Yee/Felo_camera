import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

enum NothingCardType {
  basic,
  elevated,
  outlined,
}

class NothingCard extends StatefulWidget {
  final Widget child;
  final NothingCardType type;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const NothingCard({
    super.key,
    required this.child,
    this.type = NothingCardType.basic,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  State<NothingCard> createState() => _NothingCardState();
}

class _NothingCardState extends State<NothingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: _getElevation(),
      end: _getElevation() + 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _getElevation() {
    if (widget.elevation != null) return widget.elevation!;
    switch (widget.type) {
      case NothingCardType.basic:
        return 0;
      case NothingCardType.elevated:
        return 4;
      case NothingCardType.outlined:
        return 0;
    }
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return NothingTheme.whiteAlpha90;
  }

  Border? _getBorder() {
    switch (widget.type) {
      case NothingCardType.outlined:
        return Border.all(
          color: NothingTheme.grayAlpha30,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  List<BoxShadow> _getBoxShadow() {
    final elevation = _elevationAnimation.value;
    if (elevation == 0) return [];
    
    return [
      BoxShadow(
        color: NothingTheme.blackAlpha10,
        blurRadius: elevation * 3,
        offset: Offset(0, elevation),
      ),
      BoxShadow(
        color: NothingTheme.blackAlpha05,
        blurRadius: elevation * 6,
        offset: Offset(0, elevation * 2),
      ),
    ];
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(NothingTheme.spacingMedium),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(NothingTheme.radiusMedium),
                border: _getBorder(),
                boxShadow: _getBoxShadow(),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class NothingInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const NothingInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NothingCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: NothingTheme.spacingMedium),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: NothingTheme.spacingSmall),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: NothingTheme.fontSizeCaption,
                      color: NothingTheme.nothingGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: NothingTheme.spacingMedium),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class NothingActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const NothingActionCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return NothingCard(
      type: NothingCardType.elevated,
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (iconColor ?? NothingTheme.nothingYellow).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? NothingTheme.nothingYellow,
              size: 24,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingMedium),
          Text(
            title,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeSubheading,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.nothingBlack,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            Text(
              description!,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                color: NothingTheme.nothingGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class NothingStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final Widget? chart;

  const NothingStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? NothingTheme.nothingYellow;
    
    return NothingCard(
      type: NothingCardType.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: NothingTheme.spacingSmall),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeCaption,
                    color: NothingTheme.nothingGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeHeadline,
              fontWeight: NothingTheme.fontWeightBold,
              color: NothingTheme.nothingBlack,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: NothingTheme.spacingSmall),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeCaption,
                color: accent,
              ),
            ),
          ],
          if (chart != null) ...[
            const SizedBox(height: NothingTheme.spacingMedium),
            SizedBox(
              height: 60,
              child: chart!,
            ),
          ],
        ],
      ),
    );
  }
}