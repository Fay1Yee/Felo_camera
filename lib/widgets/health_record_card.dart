import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class HealthRecordCard extends StatefulWidget {
  final HealthRecord record;
  final VoidCallback? onTap;

  const HealthRecordCard({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  State<HealthRecordCard> createState() => _HealthRecordCardState();
}

class _HealthRecordCardState extends State<HealthRecordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NothingTheme.surface,
                    NothingTheme.surface.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: NothingTheme.gray300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildContent(),
                  _buildFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTypeColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.record.type,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.record.status,
              style: TextStyle(
                fontSize: 10,
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.record.date.year}年${widget.record.date.month}月${widget.record.date.day}日',
                style: const TextStyle(
                  fontSize: 14,
                  color: NothingTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.local_hospital,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.record.clinic,
                style: const TextStyle(
                  fontSize: 14,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.record.description.isNotEmpty) ...[
            Text(
              widget.record.description,
              style: const TextStyle(
                fontSize: 14,
                color: NothingTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.record.symptoms.isNotEmpty) ...[
            const Text(
              '症状：',
              style: TextStyle(
                fontSize: 12,
                color: NothingTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.record.symptoms.map((symptom) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NothingTheme.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: NothingTheme.brandPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 10,
                      color: NothingTheme.brandPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            size: 16,
            color: NothingTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            widget.record.veterinarian,
            style: const TextStyle(
              fontSize: 12,
              color: NothingTheme.textSecondary,
            ),
          ),
          const Spacer(),
          if (widget.record.nextAppointment != null) ...[
            Icon(
              Icons.schedule,
              size: 16,
              color: NothingTheme.accentPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              '下次复诊：${widget.record.nextAppointment!.month}/${widget.record.nextAppointment!.day}',
              style: TextStyle(
                fontSize: 12,
                color: NothingTheme.accentPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.record.type) {
      case '常规检查':
        return Colors.blue;
      case '疫苗接种':
        return Colors.green;
      case '疾病治疗':
        return Colors.red;
      case '手术':
        return Colors.orange;
      case '急诊':
        return Colors.purple;
      default:
        return NothingTheme.accentPrimary;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.record.type) {
      case '常规检查':
        return Icons.health_and_safety;
      case '疫苗接种':
        return Icons.vaccines;
      case '疾病治疗':
        return Icons.medical_services;
      case '手术':
        return Icons.local_hospital;
      case '急诊':
        return Icons.emergency;
      default:
        return Icons.pets;
    }
  }

  Color _getStatusColor() {
    switch (widget.record.status) {
      case '已完成':
        return Colors.green;
      case '进行中':
        return Colors.orange;
      case '待复诊':
        return Colors.blue;
      case '已取消':
        return Colors.grey;
      default:
        return NothingTheme.textSecondary;
    }
  }
}

// 健康记录数据模型
class HealthRecord {
  final String id;
  final String title;
  final String type;
  final String status;
  final DateTime date;
  final String clinic;
  final String veterinarian;
  final String description;
  final List<String> symptoms;
  final DateTime? nextAppointment;

  HealthRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
    required this.clinic,
    required this.veterinarian,
    required this.description,
    this.symptoms = const [],
    this.nextAppointment,
  });

  // 获取模拟数据
  static List<HealthRecord> getMockData() {
    final now = DateTime.now();
    return [
      HealthRecord(
        id: 'hr_001',
        title: '年度健康体检',
        type: '常规检查',
        status: '已完成',
        date: DateTime(now.year, now.month - 1, 15),
        clinic: '宠物健康中心',
        veterinarian: '李医生',
        description: '全面健康检查，包括血液检测、心脏检查、牙齿检查等。整体健康状况良好。',
        symptoms: [],
      ),
      HealthRecord(
        id: 'hr_002',
        title: '狂犬病疫苗接种',
        type: '疫苗接种',
        status: '已完成',
        date: DateTime(now.year, now.month - 2, 10),
        clinic: '爱宠动物医院',
        veterinarian: '王医生',
        description: '按时接种狂犬病疫苗，无不良反应。',
        symptoms: [],
      ),
      HealthRecord(
        id: 'hr_003',
        title: '肠胃炎治疗',
        type: '疾病治疗',
        status: '待复诊',
        date: DateTime(now.year, now.month, now.day - 5),
        clinic: '24小时宠物医院',
        veterinarian: '张医生',
        description: '因饮食不当导致的急性肠胃炎，已开始药物治疗。',
        symptoms: ['呕吐', '腹泻', '食欲不振'],
        nextAppointment: DateTime(now.year, now.month, now.day + 3),
      ),
      HealthRecord(
        id: 'hr_004',
        title: '绝育手术',
        type: '手术',
        status: '已完成',
        date: DateTime(now.year - 1, 8, 20),
        clinic: '宠物外科医院',
        veterinarian: '陈医生',
        description: '绝育手术顺利完成，术后恢复良好。',
        symptoms: [],
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'date': date.toIso8601String(),
      'clinic': clinic,
      'veterinarian': veterinarian,
      'description': description,
      'symptoms': symptoms,
      'nextAppointment': nextAppointment?.toIso8601String(),
    };
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      clinic: json['clinic'],
      veterinarian: json['veterinarian'],
      description: json['description'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      nextAppointment: json['nextAppointment'] != null
          ? DateTime.parse(json['nextAppointment'])
          : null,
    );
  }
}