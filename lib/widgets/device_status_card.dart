import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class DeviceStatusCard extends StatelessWidget {
  final bool isConnected;
  final int batteryLevel;
  final String deviceName;
  final String lastSync;

  const DeviceStatusCard({
    super.key,
    required this.isConnected,
    required this.batteryLevel,
    required this.deviceName,
    required this.lastSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: NothingTheme.gray300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isConnected ? NothingTheme.brandPrimary : NothingTheme.gray400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                isConnected ? '已连接' : '未连接',
                style: TextStyle(
                  fontSize: 14,
                  color: isConnected ? NothingTheme.brandPrimary : NothingTheme.gray400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.battery_std,
                color: _getBatteryColor(),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$batteryLevel%',
                style: TextStyle(
                  fontSize: 14,
                  color: _getBatteryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '上次同步: $lastSync',
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: NothingTheme.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: batteryLevel / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getBatteryColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor() {
    if (batteryLevel > 50) {
      return NothingTheme.brandPrimary;
    } else if (batteryLevel > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}