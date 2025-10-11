import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class PhoneStatusBar extends StatelessWidget {
  final bool isDark;
  final Color? backgroundColor;

  const PhoneStatusBar({
    Key? key,
    this.isDark = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : NothingTheme.textPrimary;
    
    return Container(
      height: 44,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? Colors.black : Colors.white),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side - Time
            Text(
              _getCurrentTime(),
              style: TextStyle(
                color: textColor,
                fontSize: NothingTheme.fontSizeSm,
                fontWeight: NothingTheme.fontWeightMedium,
              ),
            ),
            
            // Right side - Status icons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Signal strength
                Icon(
                  Icons.signal_cellular_4_bar,
                  color: textColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                
                // WiFi
                Icon(
                  Icons.wifi,
                  color: textColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                
                // Battery
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.battery_std,
                      color: textColor,
                      size: 20,
                    ),
                    Positioned(
                      right: 2,
                      child: Text(
                        '85',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}