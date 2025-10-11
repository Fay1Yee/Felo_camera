import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';

class VaccinationCard extends StatefulWidget {
  final VaccinationRecord vaccination;
  final VoidCallback? onTap;

  const VaccinationCard({
    super.key,
    required this.vaccination,
    this.onTap,
  });

  @override
  State<VaccinationCard> createState() => _VaccinationCardState();
}

class _VaccinationCardState extends State<VaccinationCard>
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
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NothingTheme.gray900.withOpacity(0.08),
                    blurRadius: 12,
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
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(),
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
                  widget.vaccination.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NothingTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.vaccination.type,
                  style: TextStyle(
                    fontSize: 12,
                    color: NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
        children: [
          _buildInfoRow('接种日期', _formatDate(widget.vaccination.date)),
          const SizedBox(height: 8),
          _buildInfoRow('有效期至', _formatDate(widget.vaccination.expiryDate)),
          const SizedBox(height: 8),
          _buildInfoRow('接种医院', widget.vaccination.clinic),
          const SizedBox(height: 8),
          _buildInfoRow('批次号', widget.vaccination.batchNumber),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final daysUntilExpiry = widget.vaccination.expiryDate.difference(DateTime.now()).inDays;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surfaceSecondary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: NothingTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              daysUntilExpiry > 0 
                  ? '还有 $daysUntilExpiry 天到期'
                  : daysUntilExpiry == 0
                      ? '今天到期'
                      : '已过期 ${-daysUntilExpiry} 天',
              style: TextStyle(
                fontSize: 12,
                color: daysUntilExpiry <= 30 
                    ? NothingTheme.accentPrimary
                    : NothingTheme.textSecondary,
                fontWeight: daysUntilExpiry <= 30 
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          if (daysUntilExpiry <= 30)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NothingTheme.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '即将到期',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: NothingTheme.accentPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: NothingTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: NothingTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    final daysUntilExpiry = widget.vaccination.expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return const Color(0xFFE53E3E); // 红色 - 已过期
    } else if (daysUntilExpiry <= 30) {
      return const Color(0xFFFF8C00); // 橙色 - 即将到期
    } else {
      return const Color(0xFF38A169); // 绿色 - 有效
    }
  }

  IconData _getStatusIcon() {
    final daysUntilExpiry = widget.vaccination.expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return Icons.error;
    } else if (daysUntilExpiry <= 30) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }

  String _getStatusText() {
    final daysUntilExpiry = widget.vaccination.expiryDate.difference(DateTime.now()).inDays;
    
    if (daysUntilExpiry < 0) {
      return '已过期';
    } else if (daysUntilExpiry <= 30) {
      return '即将到期';
    } else {
      return '有效';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

// 疫苗记录数据模型
class VaccinationRecord {
  final String id;
  final String name;
  final String type;
  final DateTime date;
  final DateTime expiryDate;
  final String clinic;
  final String veterinarian;
  final String batchNumber;
  final String notes;

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.date,
    required this.expiryDate,
    required this.clinic,
    required this.veterinarian,
    required this.batchNumber,
    this.notes = '',
  });

  // 获取模拟数据
  static List<VaccinationRecord> getMockData() {
    final now = DateTime.now();
    return [
      VaccinationRecord(
        id: 'vac_001',
        name: '狂犬疫苗',
        type: '核心疫苗',
        date: DateTime(now.year - 1, now.month, now.day),
        expiryDate: DateTime(now.year, now.month, now.day + 15),
        clinic: '爱宠动物医院',
        veterinarian: '张医生',
        batchNumber: 'RAB2024001',
      ),
      VaccinationRecord(
        id: 'vac_002',
        name: '猫三联疫苗',
        type: '核心疫苗',
        date: DateTime(now.year, now.month - 2, now.day),
        expiryDate: DateTime(now.year + 1, now.month - 2, now.day),
        clinic: '宠物健康中心',
        veterinarian: '李医生',
        batchNumber: 'FVRCP2024002',
      ),
      VaccinationRecord(
        id: 'vac_003',
        name: '猫白血病疫苗',
        type: '非核心疫苗',
        date: DateTime(now.year, now.month - 6, now.day),
        expiryDate: DateTime(now.year + 1, now.month - 6, now.day),
        clinic: '爱宠动物医院',
        veterinarian: '王医生',
        batchNumber: 'FELV2024003',
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'date': date.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'clinic': clinic,
      'veterinarian': veterinarian,
      'batchNumber': batchNumber,
      'notes': notes,
    };
  }

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    return VaccinationRecord(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      expiryDate: DateTime.parse(json['expiryDate']),
      clinic: json['clinic'],
      veterinarian: json['veterinarian'],
      batchNumber: json['batchNumber'],
      notes: json['notes'] ?? '',
    );
  }
}