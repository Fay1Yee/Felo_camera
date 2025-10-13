import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../widgets/nothing_button.dart';
import '../../services/data_association_service.dart';
import '../../services/history_manager.dart';
import '../../models/analysis_history.dart';
import 'life_records_screen.dart';

/// 关联可视化界面
/// 展示分析历史与生活记录之间的关联关系
class AssociationVisualizationScreen extends StatefulWidget {
  const AssociationVisualizationScreen({super.key});

  @override
  State<AssociationVisualizationScreen> createState() => _AssociationVisualizationScreenState();
}

class _AssociationVisualizationScreenState extends State<AssociationVisualizationScreen> {
  bool _isLoading = true;
  List<DataAssociation> _associations = [];
  List<AnalysisHistory> _analysisHistories = [];
  List<LifeRecord> _lifeRecords = [];
  AssociationType? _selectedType;

  List<DataAssociation> get _filteredAssociations {
    if (_selectedType == null) {
      return _associations;
    }
    return _associations.where((a) => a.type == _selectedType).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载关联数据
      final associations = await DataAssociationService.instance.getAllAssociations();
      
      // 加载分析历史
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final histories = await HistoryManager.instance.getHistoriesByDateRange(startDate, now);
      
      // 生成模拟生活记录
      final lifeRecords = _generateMockLifeRecords();

      setState(() {
        _associations = associations;
        _analysisHistories = histories;
        _lifeRecords = lifeRecords;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  List<LifeRecord> _generateMockLifeRecords() {
    return [
      LifeRecord(
        id: '1',
        type: RecordType.feeding,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        title: '早餐喂食',
        description: '给宠物喂食了优质狗粮',
        duration: const Duration(minutes: 15),
        intensity: ActivityIntensity.low,
        mood: MoodState.happy,
        value: 200.0,
        unit: 'g',
        tags: ['喂食', '早餐'],
      ),
      LifeRecord(
        id: '2',
        type: RecordType.exercise,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        title: '户外运动',
        description: '在公园进行了愉快的散步',
        duration: const Duration(minutes: 30),
        intensity: ActivityIntensity.medium,
        mood: MoodState.happy,
        value: 30.0,
        unit: '分钟',
        tags: ['运动', '散步'],
      ),
      LifeRecord(
        id: '3',
        type: RecordType.sleep,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        title: '夜间休息',
        description: '安静的睡眠时间',
        duration: const Duration(hours: 8),
        intensity: ActivityIntensity.low,
        mood: MoodState.normal,
        value: 8.0,
        unit: '小时',
        tags: ['睡眠', '休息'],
      ),
    ];
  }

  Future<void> _generateAssociations() async {
    try {
      await DataAssociationService.instance.autoGenerateAndAssociate();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('关联生成成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成关联失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        title: const Text(
          '关联可视化',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontWeight: NothingTheme.fontWeightMedium,
          ),
        ),
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: NothingTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.brandPrimary),
              ),
            )
          : Column(
              children: [
                // 统计卡片
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: NothingTheme.surface,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                    boxShadow: NothingTheme.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '关联统计',
                        style: TextStyle(
                          fontSize: NothingTheme.fontSizeHeadline,
                          fontWeight: NothingTheme.fontWeightBold,
                          color: NothingTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('总关联', _associations.length.toString()),
                          _buildStatItem('分析历史', _analysisHistories.length.toString()),
                          _buildStatItem('生活记录', _lifeRecords.length.toString()),
                        ],
                      ),
                    ],
                  ),
                ),

                // 筛选区域
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: AssociationType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        label: Text(_getTypeDisplayName(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        backgroundColor: NothingTheme.surface,
                        selectedColor: NothingTheme.brandPrimary.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? NothingTheme.brandPrimary : NothingTheme.textSecondary,
                          fontSize: NothingTheme.fontSizeBase,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 关联列表
                Expanded(
                  child: _filteredAssociations.isEmpty
                      ? const Center(
                          child: Text(
                            '暂无关联数据',
                            style: TextStyle(
                              fontSize: NothingTheme.fontSizeBase,
                              color: NothingTheme.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredAssociations.length,
                          itemBuilder: (context, index) {
                            final association = _filteredAssociations[index];
                            return _buildAssociationCard(association);
                          },
                        ),
                ),

                // 生成按钮
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: NothingButton(
                    text: '生成新关联',
                    onPressed: _generateAssociations,
                    type: NothingButtonType.primary,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: NothingTheme.fontSize2xl,
            fontWeight: NothingTheme.fontWeightBold,
            color: NothingTheme.brandPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: NothingTheme.fontSizeBase,
            color: NothingTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAssociationCard(DataAssociation association) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        boxShadow: NothingTheme.shadowSm,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          _getTypeDisplayName(association.type),
          style: const TextStyle(
            fontWeight: NothingTheme.fontWeightMedium,
            color: NothingTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '置信度: ${(association.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: NothingTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '创建时间: ${_formatDateTime(association.createdAt)}',
              style: const TextStyle(
                color: NothingTheme.textTertiary,
                fontSize: NothingTheme.fontSizeXs,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: NothingTheme.surface,
            borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            border: Border.all(color: NothingTheme.gray300),
          ),
          child: Text(
            _getTypeDisplayName(association.type),
            style: const TextStyle(
              fontSize: NothingTheme.fontSizeXs,
              color: NothingTheme.textSecondary,
            ),
          ),
        ),
        onTap: () => _showAssociationDetails(association),
      ),
    );
  }

  String _getTypeDisplayName(AssociationType type) {
    switch (type) {
      case AssociationType.direct:
        return '直接关联';
      case AssociationType.derived:
        return '派生关联';
      case AssociationType.aggregated:
        return '聚合关联';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showAssociationDetails(DataAssociation association) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getTypeDisplayName(association.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分析历史ID: ${association.analysisHistoryId}'),
            const SizedBox(height: 8),
            Text('生活记录ID: ${association.lifeRecordId}'),
            const SizedBox(height: 8),
            Text('置信度: ${(association.confidence * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('创建时间: ${_formatDateTime(association.createdAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}