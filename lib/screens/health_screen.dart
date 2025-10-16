import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/health_report.dart';
import '../widgets/nothing_card.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/vaccination_card.dart';
import '../widgets/health_record_card.dart';
import '../widgets/medical_history_card.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final List<Map<String, dynamic>> _healthRecords = [
    {
      'date': '2024-01-15',
      'type': '体检',
      'status': '正常',
      'description': '常规体检，各项指标正常',
      'doctor': '李医生',
      'hospital': '宠物医院',
      'icon': Icons.health_and_safety,
      'color': NothingTheme.success,
    },
    {
      'date': '2024-01-10',
      'type': '疫苗',
      'status': '已完成',
      'description': '狂犬病疫苗接种',
      'doctor': '张医生',
      'hospital': '动物诊所',
      'icon': Icons.vaccines,
      'color': NothingTheme.accentPrimary,
    },
    {
      'date': '2024-01-08',
      'type': '驱虫',
      'status': '已完成',
      'description': '体内外驱虫',
      'doctor': '王医生',
      'hospital': '宠物诊所',
      'icon': Icons.bug_report,
      'color': NothingTheme.brandPrimary,
    },
  ];

  final List<Map<String, dynamic>> _upcomingTasks = [
    {
      'title': '下次疫苗接种',
      'date': '2024-02-15',
      'type': '疫苗',
      'urgent': false,
    },
    {
      'title': '定期体检',
      'date': '2024-03-01',
      'type': '体检',
      'urgent': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background, // 米白主背景
      appBar: const UnifiedAppBar(
        title: '健康管理',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 健康概览卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // 浅绿背景
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4CAF50), width: 1), // 中绿色边框
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), // 中绿色
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '健康状态良好',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2F5233), // 墨绿色
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.pets,
                        color: const Color(0xFF2F5233), // 墨绿色
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthMetric('体重', '4.2kg', '正常', Icons.monitor_weight),
                      ),
                      Expanded(
                        child: _buildHealthMetric('体温', '38.5°C', '正常', Icons.thermostat),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHealthMetric('心率', '120bpm', '正常', Icons.favorite),
                      ),
                      Expanded(
                        child: _buildHealthMetric('活跃度', '85%', '良好', Icons.directions_run),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 即将到期提醒
            const Text(
              '即将到期',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F), // 深灰文字
              ),
            ),
            
            const SizedBox(height: 12),
            
            ..._upcomingTasks.map((task) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: task['urgent'] ? const Color(0xFFFFF8E1) : const Color(0xFFFFFFFF), // 浅黄卡片或纯白卡片
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: task['urgent'] ? const Color(0xFFFFD84D) : const Color(0xFFECEFF1), // 亮黄色或浅灰分隔
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: task['urgent'] ? const Color(0xFFFFD84D) : const Color(0xFFF5F5F0), // 亮黄色或浅米色
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      task['type'] == '疫苗' ? Icons.vaccines : Icons.health_and_safety,
                      color: task['urgent'] ? const Color(0xFF37474F) : const Color(0xFF78909C), // 深灰文字或中灰文字
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37474F), // 深灰文字
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task['date'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF78909C), // 中灰文字
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task['urgent'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD84D), // 亮黄色
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '紧急',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF37474F), // 深灰文字
                        ),
                      ),
                    ),
                ],
              ),
            )).toList(),
            
            const SizedBox(height: 24),
            
            // 快捷操作
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD84D), // 亮黄色
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: 导航到添加健康记录页面
                        },
                        child: const Center(
                          child: Text(
                            '添加记录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF37474F), // 深灰文字
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF), // 纯白卡片
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2F5233), width: 1), // 墨绿色边框
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: 导航到预约页面
                        },
                        child: const Center(
                          child: Text(
                            '预约体检',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F5233), // 墨绿色
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 疫苗接种卡片
            VaccinationCard(
              vaccination: VaccinationRecord.getMockData().first,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('疫苗接种卡片被点击')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // 健康记录卡片
            HealthRecordCard(
              record: HealthRecord.getMockData().first,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('健康记录卡片被点击')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // 病历详情卡片
            MedicalHistoryCard(
              history: MedicalHistory.getMockData().first,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('病历详情卡片被点击')),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // 健康记录列表
            const Text(
              '健康记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F), // 深灰文字
              ),
            ),
            
            const SizedBox(height: 16),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _healthRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = _healthRecords[index];
                return _buildHealthRecord(record);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, String status, IconData icon) {
    Color statusColor = const Color(0xFF4CAF50); // 中绿色
    if (status == '异常') statusColor = Colors.red;
    if (status == '注意') statusColor = const Color(0xFFFFD84D); // 亮黄色

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF2F5233), // 墨绿色
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF78909C), // 中灰文字
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F), // 深灰文字
          ),
        ),
        const SizedBox(height: 2),
        Text(
          status,
          style: TextStyle(
            fontSize: 12,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRecord(Map<String, dynamic> record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // 纯白卡片
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEFF1), width: 1), // 浅灰分隔
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  record['icon'],
                  color: record['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['type'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF37474F), // 深灰文字
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF78909C), // 中灰文字
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: record['status'] == '正常' || record['status'] == '已完成'
                      ? const Color(0xFFE8F5E9) // 浅绿背景
                      : const Color(0xFFFFF8E1), // 浅黄卡片
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: record['status'] == '正常' || record['status'] == '已完成'
                        ? const Color(0xFF2F5233) // 墨绿色
                        : const Color(0xFF37474F), // 深灰文字
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: const Color(0xFF90A4AE), // 浅灰辅助
              ),
              const SizedBox(width: 4),
              Text(
                record['date'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF90A4AE), // 浅灰辅助
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.local_hospital,
                size: 14,
                color: const Color(0xFF90A4AE), // 浅灰辅助
              ),
              const SizedBox(width: 4),
              Text(
                '${record['doctor']} · ${record['hospital']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF90A4AE), // 浅灰辅助
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}