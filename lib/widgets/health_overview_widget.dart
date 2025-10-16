import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/health_report.dart';

class HealthOverviewWidget extends StatefulWidget {
  final String petId;

  const HealthOverviewWidget({
    super.key,
    required this.petId,
  });

  @override
  State<HealthOverviewWidget> createState() => _HealthOverviewWidgetState();
}

class _HealthOverviewWidgetState extends State<HealthOverviewWidget> {
  HealthReport? _latestReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  void _loadHealthData() {
    // 模拟加载健康数据
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _latestReport = _getMockHealthReport();
        _isLoading = false;
      });
    });
  }

  HealthReport _getMockHealthReport() {
    return HealthReport(
      petId: widget.petId,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      petName: '泡泡',
      petType: '猫',
      breed: '英短',
      physicalIndicators: PhysicalIndicators(
        weight: 4.2,
        bodyTemperature: 38.5,
        heartRate: 140,
        respiratoryRate: 25,
        eyeCondition: '正常',
        noseCondition: '湿润',
        coatCondition: '光泽',
        skinCondition: '健康',
        teethCondition: '清洁',
        earCondition: '干净',
      ),
      behaviorAnalysis: BehaviorAnalysis(
        activityLevel: '高',
        appetiteStatus: '正常',
        sleepPattern: '正常',
        socialBehavior: '正常',
        playfulness: '正常',
        vocalBehavior: '正常',
        abnormalBehaviors: [],
        stressLevel: '低',
      ),
      healthAssessment: HealthAssessment(
        overallScore: 85,
        healthStatus: '良好',
        healthConcerns: [],
        positiveAspects: ['活跃度高', '食欲正常', '毛发光泽'],
        riskLevel: '低',
      ),
      recommendations: [
        '保持当前的饮食习惯',
        '增加互动游戏时间',
        '定期检查口腔卫生',
      ],
      archiveId: 'archive_001',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_latestReport == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 健康状态卡片
          _buildHealthStatusCard(),
          const SizedBox(height: 16),
          
          // 生理指标
          _buildPhysicalIndicators(),
          const SizedBox(height: 16),
          
          // 行为分析
          _buildBehaviorAnalysis(),
          const SizedBox(height: 16),
          
          // 建议和提醒
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 64,
            color: NothingTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无健康数据',
            style: TextStyle(
              fontSize: 16,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '使用AI相机扫描宠物获取健康报告',
            style: TextStyle(
              fontSize: 14,
              color: NothingTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    final report = _latestReport!;
    final overallScore = _calculateOverallScore(report);
    final statusColor = _getHealthStatusColor(overallScore);
    final statusText = _getHealthStatusText(overallScore);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.favorite,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '健康状态',
                      style: TextStyle(
                        fontSize: 14,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${overallScore.toInt()}分',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.healthAssessment.healthStatus,
            style: TextStyle(
              fontSize: 14,
              color: NothingTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: NothingTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '最后更新：${_formatDateTime(report.timestamp)}',
                style: TextStyle(
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

  Widget _buildPhysicalIndicators() {
    final indicators = _latestReport!.physicalIndicators;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '生理指标',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 数值指标
          Row(
            children: [
              Expanded(
                child: _buildIndicatorItem(
                  '体重',
                  '${indicators.weight}kg',
                  Icons.monitor_weight_outlined,
                  NothingTheme.info,
                ),
              ),
              Expanded(
                child: _buildIndicatorItem(
                  '体温',
                  '${indicators.bodyTemperature}°C',
                  Icons.thermostat_outlined,
                  NothingTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorItem(
                  '心率',
                  '${indicators.heartRate}次/分',
                  Icons.favorite_outline,
                  NothingTheme.error,
                ),
              ),
              Expanded(
                child: _buildIndicatorItem(
                  '呼吸',
                  '${indicators.respiratoryRate}次/分',
                  Icons.air_outlined,
                  NothingTheme.accentPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // 状态指标
          Text(
            '外观检查',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('眼部', indicators.eyeCondition),
              _buildStatusChip('鼻部', indicators.noseCondition),
              _buildStatusChip('毛发', indicators.coatCondition),
              _buildStatusChip('皮肤', indicators.skinCondition),
              _buildStatusChip('牙齿', indicators.teethCondition),
              _buildStatusChip('耳朵', indicators.earCondition),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorAnalysis() {
    final behavior = _latestReport!.behaviorAnalysis;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '行为分析',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBehaviorBar('活跃度', _getBehaviorScore(behavior.activityLevel), NothingTheme.success),
          const SizedBox(height: 12),
          _buildBehaviorBar('食欲', _getBehaviorScore(behavior.appetiteStatus), NothingTheme.warning),
          const SizedBox(height: 12),
          _buildBehaviorBar('睡眠', _getBehaviorScore(behavior.sleepPattern), NothingTheme.info),
          const SizedBox(height: 12),
          _buildBehaviorBar('社交', _getBehaviorScore(behavior.socialBehavior), NothingTheme.accentPrimary),
          const SizedBox(height: 12),
          _buildBehaviorBar('玩耍', _getBehaviorScore(behavior.playfulness), NothingTheme.brandPrimary),
          const SizedBox(height: 12),
          _buildBehaviorBar('压力水平', 10 - _getBehaviorScore(behavior.stressLevel), NothingTheme.error),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _latestReport!.recommendations;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: NothingTheme.warning,
              ),
              const SizedBox(width: 8),
              Text(
                '健康建议',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: NothingTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            
            return Padding(
              padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: NothingTheme.accentPrimary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 14,
                        color: NothingTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: NothingTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: NothingTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final isNormal = status == '正常' || status == '健康' || status == '清洁' || 
                     status == '干净' || status == '湿润' || status == '光泽';
    final color = isNormal ? NothingTheme.success : NothingTheme.warning;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: NothingTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorBar(String label, int value, Color color) {
    final progress = value / 10.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: NothingTheme.textPrimary,
              ),
            ),
            Text(
              '$value/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: NothingTheme.gray200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }

  double _calculateOverallScore(HealthReport report) {
    // 使用健康评估中的总体评分
    return report.healthAssessment.overallScore.toDouble();
  }

  int _getBehaviorScore(String behaviorLevel) {
    switch (behaviorLevel.toLowerCase()) {
      case '高':
      case '正常':
      case '优秀':
        return 8;
      case '中':
      case '良好':
        return 6;
      case '低':
      case '需关注':
        return 4;
      default:
        return 5;
    }
  }

  Color _getHealthStatusColor(double score) {
    if (score >= 80) return NothingTheme.success;
    if (score >= 60) return NothingTheme.warning;
    return NothingTheme.error;
  }

  String _getHealthStatusText(double score) {
    if (score >= 80) return '健康';
    if (score >= 60) return '良好';
    return '需关注';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}