import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

enum NothingButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

enum NothingButtonSize {
  small,
  medium,
  large,
}

class NothingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NothingButtonType type;
  final NothingButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;

  const NothingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = NothingButtonType.primary,
    this.size = NothingButtonSize.medium,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
  });

  @override
  State<NothingButton> createState() => _NothingButtonState();
}

class _NothingButtonState extends State<NothingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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
      end: 0.95,
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

  EdgeInsets get _padding {
    switch (widget.size) {
      case NothingButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case NothingButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case NothingButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case NothingButtonSize.small:
        return NothingTheme.fontSizeCaption;
      case NothingButtonSize.medium:
        return NothingTheme.fontSizeBody;
      case NothingButtonSize.large:
        return NothingTheme.fontSizeSubheading;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case NothingButtonSize.small:
        return 16;
      case NothingButtonSize.medium:
        return 18;
      case NothingButtonSize.large:
        return 20;
    }
  }

  Color get _backgroundColor {
    if (widget.onPressed == null) {
      return NothingTheme.grayAlpha30;
    }
    
    switch (widget.type) {
      case NothingButtonType.primary:
        return NothingTheme.nothingYellow;
      case NothingButtonType.secondary:
        return NothingTheme.whiteAlpha90;
      case NothingButtonType.outline:
      case NothingButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    if (widget.onPressed == null) {
      return NothingTheme.grayAlpha50;
    }
    
    switch (widget.type) {
      case NothingButtonType.primary:
        return NothingTheme.nothingBlack;
      case NothingButtonType.secondary:
        return NothingTheme.nothingBlack;
      case NothingButtonType.outline:
      case NothingButtonType.ghost:
        return NothingTheme.nothingWhite;
    }
  }

  Border? get _border {
    switch (widget.type) {
      case NothingButtonType.outline:
        return Border.all(
          color: widget.onPressed == null 
              ? NothingTheme.grayAlpha30 
              : NothingTheme.nothingYellow,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? get _boxShadow {
    if (widget.onPressed == null || widget.type == NothingButtonType.ghost) {
      return null;
    }
    
    switch (widget.type) {
      case NothingButtonType.primary:
        return [
          BoxShadow(
            color: NothingTheme.yellowAlpha30,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: NothingTheme.yellowAlpha20,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: NothingTheme.blackAlpha20,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.loading) {
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.loading ? null : widget.onPressed,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              padding: _padding,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: _border,
                boxShadow: _boxShadow,
              ),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading) ...[
                    SizedBox(
                      width: _iconSize,
                      height: _iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                      ),
                    ),
                    const SizedBox(width: NothingTheme.spacingSmall),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: _iconSize,
                      color: _textColor,
                    ),
                    const SizedBox(width: NothingTheme.spacingSmall),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: NothingTheme.fontWeightMedium,
                      color: _textColor,
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

class NothingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const NothingIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  State<NothingIconButton> createState() => _NothingIconButtonState();
}

class _NothingIconButtonState extends State<NothingIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
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
      end: 0.9,
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

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
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
    final backgroundColor = widget.backgroundColor ?? 
        NothingTheme.nothingWhite.withValues(alpha: 0.1);
    final iconColor = widget.iconColor ?? NothingTheme.nothingBlack;

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.nothingBlack.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: iconColor,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}