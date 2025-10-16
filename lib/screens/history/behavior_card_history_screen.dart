import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../widgets/behavior_card_timeline.dart';

/// 行为卡片历史页面
/// 采用卡片式布局展示行为记录，支持相同行为类型合并
class BehaviorCardHistoryScreen extends StatefulWidget {
  const BehaviorCardHistoryScreen({super.key});

  @override
  State<BehaviorCardHistoryScreen> createState() => _BehaviorCardHistoryScreenState();
}

class _BehaviorCardHistoryScreenState extends State<BehaviorCardHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _behaviorFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        title: const Text('行为记录'),
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选器显示
          if (_startDate != null || _endDate != null || _behaviorFilter != null)
            _buildFilterChips(),
          
          // 卡片式时间轴
          Expanded(
            child: BehaviorCardTimeline(
              startDate: _startDate,
              endDate: _endDate,
              behaviorFilter: _behaviorFilter,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选器芯片
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_startDate != null || _endDate != null)
            FilterChip(
              label: Text(_getDateRangeText()),
              selected: true,
              onSelected: (bool value) {},
              onDeleted: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              backgroundColor: NothingTheme.brandSecondary,
              selectedColor: NothingTheme.brandPrimary,
              side: BorderSide(color: NothingTheme.brandPrimary),
            ),
          if (_behaviorFilter != null)
            FilterChip(
              label: Text('行为: $_behaviorFilter'),
              selected: true,
              onSelected: (bool value) {},
              onDeleted: () {
                setState(() {
                  _behaviorFilter = null;
                });
              },
              backgroundColor: NothingTheme.accentSecondary,
              selectedColor: NothingTheme.accentPrimary,
              side: BorderSide(color: NothingTheme.accentPrimary),
            ),
        ],
      ),
    );
  }

  /// 获取日期范围文本
  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
    } else if (_startDate != null) {
      return '从 ${_formatDate(_startDate!)}';
    } else if (_endDate != null) {
      return '到 ${_formatDate(_endDate!)}';
    }
    return '';
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 日期范围选择
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('日期范围'),
              subtitle: Text(_getDateRangeText().isEmpty ? '全部' : _getDateRangeText()),
              onTap: _selectDateRange,
            ),
            
            // 行为类型选择
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('行为类型'),
              subtitle: Text(_behaviorFilter ?? '全部'),
              onTap: _selectBehaviorType,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
                _behaviorFilter = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 选择日期范围
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  /// 选择行为类型
  void _selectBehaviorType() {
    final behaviorTypes = [
      '全部',
      '喂食',
      '饮水',
      '运动',
      '睡眠',
      '玩耍',
      '健康',
      '美容',
      '训练',
      '社交',
      '其他',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择行为类型'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: behaviorTypes.length,
            itemBuilder: (context, index) {
              final type = behaviorTypes[index];
              final isSelected = type == '全部' 
                  ? _behaviorFilter == null 
                  : _behaviorFilter == type;
              
              return ListTile(
                title: Text(type),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _behaviorFilter = type == '全部' ? null : type;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}