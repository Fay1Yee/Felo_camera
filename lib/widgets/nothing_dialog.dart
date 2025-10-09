import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import 'nothing_button.dart';

class NothingDialog extends StatefulWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final EdgeInsets? contentPadding;

  const NothingDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.barrierDismissible = true,
    this.contentPadding,
  });

  @override
  State<NothingDialog> createState() => _NothingDialogState();

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    EdgeInsets? contentPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => NothingDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
        contentPadding: contentPadding,
      ),
    );
  }
}

class _NothingDialogState extends State<NothingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: NothingTheme.nothingWhite,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: NothingTheme.nothingBlack.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                        decoration: BoxDecoration(
                          color: NothingTheme.nothingYellow,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(NothingTheme.radiusLarge),
                            topRight: Radius.circular(NothingTheme.radiusLarge),
                          ),
                        ),
                        child: Text(
                          widget.title!,
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeSubheading,
                            fontWeight: NothingTheme.fontWeightBold,
                            color: NothingTheme.nothingBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    if (widget.content != null) ...[
                      Padding(
                        padding: widget.contentPadding ?? 
                            const EdgeInsets.all(NothingTheme.spacingLarge),
                        child: widget.content!,
                      ),
                    ],
                    if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          NothingTheme.spacingLarge,
                          0,
                          NothingTheme.spacingLarge,
                          NothingTheme.spacingLarge,
                        ),
                        child: Row(
                          children: [
                            for (int i = 0; i < widget.actions!.length; i++) ...[
                              if (i > 0) const SizedBox(width: NothingTheme.spacingMedium),
                              Expanded(child: widget.actions![i]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NothingConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool destructive;

  const NothingConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.destructive = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool destructive = false,
  }) {
    return NothingDialog.show<bool>(
      context: context,
      title: title,
      content: Text(
        message,
        style: TextStyle(
          fontSize: NothingTheme.fontSizeBody,
          color: NothingTheme.nothingBlack,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        NothingButton(
          text: cancelText ?? '取消',
          type: NothingButtonType.outline,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        NothingButton(
          text: confirmText ?? '确认',
          type: destructive ? NothingButtonType.primary : NothingButtonType.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NothingDialog(
      title: title,
      content: Text(
        message,
        style: TextStyle(
          fontSize: NothingTheme.fontSizeBody,
          color: NothingTheme.nothingBlack,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        NothingButton(
          text: cancelText ?? '取消',
          type: NothingButtonType.outline,
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
        ),
        NothingButton(
          text: confirmText ?? '确认',
          type: NothingButtonType.primary,
          onPressed: onConfirm ?? () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class NothingBottomSheet extends StatefulWidget {
  final String? title;
  final Widget child;
  final bool isDismissible;
  final double? height;

  const NothingBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.isDismissible = true,
    this.height,
  });

  @override
  State<NothingBottomSheet> createState() => _NothingBottomSheetState();

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool isDismissible = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      builder: (context) => NothingBottomSheet(
        title: title,
        isDismissible: isDismissible,
        height: height,
        child: child,
      ),
    );
  }
}

class _NothingBottomSheetState extends State<NothingBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = widget.height ?? screenHeight * 0.8;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        decoration: const BoxDecoration(
          color: NothingTheme.nothingWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(NothingTheme.radiusLarge),
            topRight: Radius.circular(NothingTheme.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: NothingTheme.spacingMedium),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NothingTheme.nothingLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (widget.title != null) ...[
              Padding(
                padding: const EdgeInsets.all(NothingTheme.spacingLarge),
                child: Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeSubheading,
                    fontWeight: NothingTheme.fontWeightBold,
                    color: NothingTheme.nothingBlack,
                  ),
                ),
              ),
              Divider(
                color: NothingTheme.nothingLightGray,
                height: 1,
              ),
            ],
            Flexible(
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class NothingLoadingDialog extends StatelessWidget {
  final String? message;

  const NothingLoadingDialog({
    super.key,
    this.message,
  });

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NothingLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(NothingTheme.spacingLarge),
        decoration: BoxDecoration(
          color: NothingTheme.nothingWhite,
          borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.nothingYellow),
            ),
            if (message != null) ...[
              const SizedBox(height: NothingTheme.spacingMedium),
              Text(
                message!,
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeBody,
                  color: NothingTheme.nothingBlack,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}