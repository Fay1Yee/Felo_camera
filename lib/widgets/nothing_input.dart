import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class NothingTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? errorText;
  final int maxLines;
  final TextEditingController? controller;

  const NothingTextField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.errorText,
    this.maxLines = 1,
    this.controller,
  });

  @override
  State<NothingTextField> createState() => _NothingTextFieldState();
}

class _NothingTextFieldState extends State<NothingTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.value);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _borderColorAnimation = ColorTween(
      begin: NothingTheme.nothingLightGray,
      end: NothingTheme.nothingYellow,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
        ],
        AnimatedBuilder(
          animation: _borderColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
                border: Border.all(
                  color: widget.errorText != null
                      ? NothingTheme.warningOrange // 改为橙色，更温和的提示
                      : _borderColorAnimation.value ?? NothingTheme.nothingLightGray,
                  width: _isFocused ? 2 : 1,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: NothingTheme.nothingYellow.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Focus(
                onFocusChange: _onFocusChange,
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBody,
                    color: NothingTheme.nothingBlack,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: NothingTheme.nothingGray,
                      fontSize: NothingTheme.fontSizeBody,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? NothingTheme.nothingYellow
                                : NothingTheme.nothingGray,
                          )
                        : null,
                    suffixIcon: widget.suffixIcon != null
                        ? GestureDetector(
                            onTap: widget.onSuffixIconTap,
                            child: Icon(
                              widget.suffixIcon,
                              color: _isFocused
                                  ? NothingTheme.nothingYellow
                                  : NothingTheme.nothingGray,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: NothingTheme.spacingMedium,
                      vertical: NothingTheme.spacingMedium,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              color: NothingTheme.warningOrange, // 改为橙色，更温和的提示
            ),
          ),
        ],
      ],
    );
  }
}

class NothingSearchField extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const NothingSearchField({
    super.key,
    this.hint,
    this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  State<NothingSearchField> createState() => _NothingSearchFieldState();
}

class _NothingSearchFieldState extends State<NothingSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.nothingLightGray,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
      ),
      child: TextField(
        controller: _controller,
        style: TextStyle(
          fontSize: NothingTheme.fontSizeBody,
          color: NothingTheme.nothingBlack,
        ),
        decoration: InputDecoration(
          hintText: widget.hint ?? '搜索...',
          hintStyle: TextStyle(
            color: NothingTheme.nothingGray,
            fontSize: NothingTheme.fontSizeBody,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: NothingTheme.nothingGray,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: _onClear,
                  child: Icon(
                    Icons.clear,
                    color: NothingTheme.nothingGray,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NothingTheme.spacingMedium,
            vertical: NothingTheme.spacingMedium,
          ),
        ),
      ),
    );
  }
}

class NothingDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<NothingDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;

  const NothingDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
  });

  @override
  State<NothingDropdown<T>> createState() => _NothingDropdownState<T>();
}

class _NothingDropdownState<T> extends State<NothingDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectItem(T? value) {
    widget.onChanged?.call(value);
    _toggleDropdown();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => NothingDropdownItem(value: null, child: Text(widget.hint ?? '请选择')),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.nothingBlack,
            ),
          ),
          const SizedBox(height: NothingTheme.spacingSmall),
        ],
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NothingTheme.spacingMedium,
              vertical: NothingTheme.spacingMedium,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(
                color: widget.errorText != null
                    ? NothingTheme.warningOrange // 改为橙色，更温和的提示
                    : _isExpanded
                        ? NothingTheme.nothingYellow
                        : NothingTheme.nothingLightGray,
                width: _isExpanded ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(child: selectedItem.child),
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 3.14159,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: NothingTheme.nothingGray,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          Container(
            decoration: BoxDecoration(
              color: NothingTheme.nothingWhite,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMedium),
              border: Border.all(color: NothingTheme.nothingLightGray),
              boxShadow: [
                BoxShadow(
                  color: NothingTheme.nothingBlack.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: widget.items.map((item) {
                final isSelected = item.value == widget.value;
                return GestureDetector(
                  onTap: () => _selectItem(item.value),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: NothingTheme.spacingMedium,
                      vertical: NothingTheme.spacingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? NothingTheme.nothingYellow.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: item.child,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: NothingTheme.spacingSmall),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: NothingTheme.fontSizeCaption,
              color: NothingTheme.warningOrange, // 改为橙色，更温和的提示
            ),
          ),
        ],
      ],
    );
  }
}

class NothingDropdownItem<T> {
  final T? value;
  final Widget child;

  const NothingDropdownItem({
    required this.value,
    required this.child,
  });
}