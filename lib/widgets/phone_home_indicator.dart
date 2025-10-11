import 'package:flutter/material.dart';

class PhoneHomeIndicator extends StatelessWidget {
  final Color? color;
  final double? width;
  final double? height;

  const PhoneHomeIndicator({
    Key? key,
    this.color,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 34,
      color: Colors.black,
      child: Center(
        child: Container(
          width: width ?? 134,
          height: 5,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }
}