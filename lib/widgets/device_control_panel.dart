import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class DeviceControlPanel extends StatefulWidget {
  const DeviceControlPanel({super.key});

  @override
  State<DeviceControlPanel> createState() => _DeviceControlPanelState();
}

class _DeviceControlPanelState extends State<DeviceControlPanel> {
  bool _isLightOn = false;
  bool _isFanOn = false;
  bool _isHeaterOn = false;
  double _temperature = 22.0;
  double _humidity = 45.0;

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
              Icon(
                Icons.settings_remote,
                color: NothingTheme.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '设备控制',
                style: TextStyle(
                  fontSize: NothingTheme.fontSizeLg,
                  fontWeight: NothingTheme.fontWeightSemiBold,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 环境监测
          _buildEnvironmentSection(),
          
          const SizedBox(height: 20),
          
          // 设备开关
          _buildDeviceControls(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '环境监测',
            style: TextStyle(
              fontSize: NothingTheme.fontSizeBase,
              fontWeight: NothingTheme.fontWeightMedium,
              color: NothingTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.thermostat,
                  label: '温度',
                  value: '${_temperature.toInt()}°C',
                  color: NothingTheme.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnvironmentItem(
                  icon: Icons.water_drop,
                  label: '湿度',
                  value: '${_humidity.toInt()}%',
                  color: NothingTheme.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeSm,
                color: NothingTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: NothingTheme.fontSizeBase,
                fontWeight: NothingTheme.fontWeightSemiBold,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设备开关',
          style: TextStyle(
            fontSize: NothingTheme.fontSizeBase,
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 设备控制项
        _buildControlItem(
          icon: Icons.lightbulb,
          title: '照明灯',
          subtitle: '自动调节亮度',
          isOn: _isLightOn,
          onChanged: (value) => setState(() => _isLightOn = value),
        ),
        
        const SizedBox(height: 12),
        
        _buildControlItem(
          icon: Icons.air,
          title: '通风扇',
          subtitle: '保持空气流通',
          isOn: _isFanOn,
          onChanged: (value) => setState(() => _isFanOn = value),
        ),
        
        const SizedBox(height: 12),
        
        _buildControlItem(
          icon: Icons.local_fire_department,
          title: '加热器',
          subtitle: '温度调节',
          isOn: _isHeaterOn,
          onChanged: (value) => setState(() => _isHeaterOn = value),
        ),
      ],
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOn,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOn 
            ? NothingTheme.brandPrimary.withOpacity(0.05)
            : NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOn 
              ? NothingTheme.brandPrimary.withOpacity(0.2)
              : NothingTheme.gray300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isOn 
                  ? NothingTheme.brandPrimary
                  : NothingTheme.gray400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeBase,
                    fontWeight: NothingTheme.fontWeightMedium,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: NothingTheme.fontSizeSm,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeColor: NothingTheme.brandPrimary,
            inactiveThumbColor: NothingTheme.gray400,
            inactiveTrackColor: NothingTheme.gray200,
          ),
        ],
      ),
    );
  }
}