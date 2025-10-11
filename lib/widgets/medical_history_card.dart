import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class MedicalHistoryCard extends StatefulWidget {
  final MedicalHistory history;
  final VoidCallback? onTap;

  const MedicalHistoryCard({
    super.key,
    required this.history,
    this.onTap,
  });

  @override
  State<MedicalHistoryCard> createState() => _MedicalHistoryCardState();
}

class _MedicalHistoryCardState extends State<MedicalHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
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
                  if (_isExpanded) ...[
                    _buildExpandedContent(),
                  ] else ...[
                    _buildCollapsedContent(),
                  ],
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getSeverityColor().withOpacity(0.1),
            _getSeverityColor().withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: _isExpanded ? Radius.zero : const Radius.circular(16),
          bottomRight: _isExpanded ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSeverityIcon(),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.history.diagnosis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.history.severity,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSeverityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.history.date.year}年${widget.history.date.month}月${widget.history.date.day}日',
                      style: const TextStyle(
                        fontSize: 14,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: NothingTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.history.symptoms.take(3).join('、'),
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textPrimary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.history.clinic,
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.person,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.history.veterinarian,
                style: const TextStyle(
                  fontSize: 12,
                  color: NothingTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.history.symptoms.isNotEmpty) ...[
            _buildSection('症状描述', Icons.sick, widget.history.symptoms),
            const SizedBox(height: 16),
          ],
          if (widget.history.treatment.isNotEmpty) ...[
            _buildSection('治疗方案', Icons.medical_services, widget.history.treatment),
            const SizedBox(height: 16),
          ],
          if (widget.history.medications.isNotEmpty) ...[
            _buildSection('用药记录', Icons.medication, widget.history.medications),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(),
          if (widget.history.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: NothingTheme.accentPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 26, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8, right: 8),
                decoration: BoxDecoration(
                  color: NothingTheme.accentPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '医院',
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.history.clinic,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主治医生',
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.history.veterinarian,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NothingTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '费用',
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${widget.history.cost.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: NothingTheme.accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note_alt,
              size: 18,
              color: NothingTheme.accentPrimary,
            ),
            const SizedBox(width: 8),
            const Text(
              '医生备注',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NothingTheme.brandSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: NothingTheme.brandPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            widget.history.notes,
            style: const TextStyle(
              fontSize: 14,
              color: NothingTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor() {
    switch (widget.history.severity) {
      case '轻微':
        return Colors.green;
      case '中等':
        return Colors.orange;
      case '严重':
        return Colors.red;
      case '紧急':
        return Colors.purple;
      default:
        return NothingTheme.accentPrimary;
    }
  }

  IconData _getSeverityIcon() {
    switch (widget.history.severity) {
      case '轻微':
        return Icons.healing;
      case '中等':
        return Icons.medical_services;
      case '严重':
        return Icons.local_hospital;
      case '紧急':
        return Icons.emergency;
      default:
        return Icons.pets;
    }
  }
}

// 病历数据模型
class MedicalHistory {
  final String id;
  final String diagnosis;
  final String severity;
  final DateTime date;
  final String clinic;
  final String veterinarian;
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> medications;
  final double cost;
  final String notes;

  MedicalHistory({
    required this.id,
    required this.diagnosis,
    required this.severity,
    required this.date,
    required this.clinic,
    required this.veterinarian,
    required this.symptoms,
    required this.treatment,
    required this.medications,
    required this.cost,
    required this.notes,
  });

  // 获取模拟数据
  static List<MedicalHistory> getMockData() {
    final now = DateTime.now();
    return [
      MedicalHistory(
        id: 'mh_001',
        diagnosis: '急性肠胃炎',
        severity: '中等',
        date: DateTime(now.year, now.month, now.day - 5),
        clinic: '24小时宠物医院',
        veterinarian: '张医生',
        symptoms: ['呕吐', '腹泻', '食欲不振', '精神萎靡'],
        treatment: ['禁食12小时', '静脉输液补充电解质', '抗炎治疗'],
        medications: ['头孢菌素 100mg 每日2次', '益生菌 1包 每日1次', '止吐药 50mg 必要时使用'],
        cost: 680.0,
        notes: '建议观察3-5天，如症状未改善需复诊。注意饮食清淡，避免油腻食物。',
      ),
      MedicalHistory(
        id: 'mh_002',
        diagnosis: '皮肤过敏性皮炎',
        severity: '轻微',
        date: DateTime(now.year, now.month - 1, 20),
        clinic: '宠物皮肤科诊所',
        veterinarian: '李医生',
        symptoms: ['皮肤红肿', '瘙痒', '脱毛', '皮屑增多'],
        treatment: ['局部清洁消毒', '抗过敏治疗', '营养补充'],
        medications: ['抗组胺药 25mg 每日1次', '维生素E 100IU 每日1次', '外用消炎膏 每日2次'],
        cost: 320.0,
        notes: '过敏源可能是新换的猫粮，建议更换回原来的品牌。保持环境清洁干燥。',
      ),
      MedicalHistory(
        id: 'mh_003',
        diagnosis: '上呼吸道感染',
        severity: '轻微',
        date: DateTime(now.year, now.month - 2, 10),
        clinic: '爱宠动物医院',
        veterinarian: '王医生',
        symptoms: ['打喷嚏', '流鼻涕', '轻微咳嗽', '眼部分泌物增多'],
        treatment: ['抗病毒治疗', '对症支持治疗', '增强免疫力'],
        medications: ['阿莫西林 250mg 每日2次', '复合维生素 1片 每日1次', '眼药水 每日3次'],
        cost: 180.0,
        notes: '病毒性感染，一般7-10天自愈。注意保暖，多休息，增加营养。',
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis,
      'severity': severity,
      'date': date.toIso8601String(),
      'clinic': clinic,
      'veterinarian': veterinarian,
      'symptoms': symptoms,
      'treatment': treatment,
      'medications': medications,
      'cost': cost,
      'notes': notes,
    };
  }

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      id: json['id'],
      diagnosis: json['diagnosis'],
      severity: json['severity'],
      date: DateTime.parse(json['date']),
      clinic: json['clinic'],
      veterinarian: json['veterinarian'],
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatment: List<String>.from(json['treatment'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      cost: (json['cost'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }
}