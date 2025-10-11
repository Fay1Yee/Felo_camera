import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../widgets/device_status_card.dart';
import '../widgets/scenario_mode_selector.dart';
import '../widgets/device_control_panel.dart';
import '../models/pet_profile.dart';

class TravelBoxScreen extends StatefulWidget {
  const TravelBoxScreen({super.key});

  @override
  State<TravelBoxScreen> createState() => _TravelBoxScreenState();
}

class _TravelBoxScreenState extends State<TravelBoxScreen> {
  ScenarioMode _currentMode = ScenarioMode.travel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题
              Text(
                '出行箱',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: NothingTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 设备状态卡片
              DeviceStatusCard(
                isConnected: true,
                batteryLevel: 85,
                deviceName: 'Felo 智能出行箱',
                lastSync: '2分钟前',
              ),
              
              const SizedBox(height: 24),
              
              // 场景模式选择器
              ScenarioModeSelector(
                selectedMode: _currentMode,
                onModeChanged: (mode) {
                  setState(() {
                    _currentMode = mode;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // 设备控制面板
              const DeviceControlPanel(),
              
              const SizedBox(height: 24),
              
              // 设备管理
              _buildDeviceManagement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '设备管理',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: NothingTheme.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: NothingTheme.gray300,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildManagementItem('WiFi设置', Icons.wifi, '已连接到 Felo-5G'),
              _buildDivider(),
              _buildManagementItem('蓝牙配对', Icons.bluetooth, '2台设备已配对'),
              _buildDivider(),
              _buildManagementItem('固件更新', Icons.system_update, '版本 v2.1.3'),
              _buildDivider(),
              _buildManagementItem('设备诊断', Icons.bug_report, '运行正常'),
              _buildDivider(),
              _buildManagementItem('重置设备', Icons.restore, '恢复出厂设置', isDestructive: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagementItem(String title, IconData icon, String subtitle, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {
        // TODO: 实现管理功能
        _showManagementDialog(title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withOpacity(0.1) : NothingTheme.surfaceTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : NothingTheme.textSecondary,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : NothingTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: NothingTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: NothingTheme.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: NothingTheme.gray200,
    );
  }

  void _showManagementDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('$title 功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}