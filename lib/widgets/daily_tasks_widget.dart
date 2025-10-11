import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

class DailyTasksWidget extends StatefulWidget {
  final String petId;
  final ScenarioMode scenario;

  const DailyTasksWidget({
    super.key,
    required this.petId,
    required this.scenario,
  });

  @override
  State<DailyTasksWidget> createState() => _DailyTasksWidgetState();
}

class _DailyTasksWidgetState extends State<DailyTasksWidget> {
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didUpdateWidget(DailyTasksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scenario != widget.scenario) {
      _loadTasks();
    }
  }

  void _loadTasks() {
    setState(() {
      _tasks = _getTasksForScenario(widget.scenario);
    });
  }

  List<TaskItem> _getTasksForScenario(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return [
          TaskItem(
            id: '1',
            title: '早餐喂食',
            time: '08:00',
            completed: true,
            type: TaskType.feeding,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '2',
            title: '清理猫砂',
            time: '09:00',
            completed: false,
            type: TaskType.cleaning,
            priority: TaskPriority.medium,
          ),
          TaskItem(
            id: '3',
            title: '互动游戏',
            time: '16:00',
            completed: false,
            type: TaskType.play,
            priority: TaskPriority.medium,
          ),
          TaskItem(
            id: '4',
            title: '晚餐喂食',
            time: '18:00',
            completed: false,
            type: TaskType.feeding,
            priority: TaskPriority.high,
          ),
        ];
      case ScenarioMode.travel:
        return [
          TaskItem(
            id: '5',
            title: '检查航空箱',
            time: '07:00',
            completed: false,
            type: TaskType.preparation,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '6',
            title: '准备证件',
            time: '07:30',
            completed: false,
            type: TaskType.preparation,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '7',
            title: '携带应急药品',
            time: '08:00',
            completed: false,
            type: TaskType.medical,
            priority: TaskPriority.medium,
          ),
        ];
      case ScenarioMode.medical:
        return [
          TaskItem(
            id: '8',
            title: '体温测量',
            time: '09:00',
            completed: false,
            type: TaskType.medical,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '9',
            title: '服用药物',
            time: '12:00',
            completed: false,
            type: TaskType.medical,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '10',
            title: '记录症状',
            time: '15:00',
            completed: false,
            type: TaskType.medical,
            priority: TaskPriority.medium,
          ),
        ];
      case ScenarioMode.urban:
        return [
          TaskItem(
            id: '11',
            title: '佩戴牵引绳',
            time: '10:00',
            completed: false,
            type: TaskType.safety,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '12',
            title: '携带证件',
            time: '10:05',
            completed: false,
            type: TaskType.preparation,
            priority: TaskPriority.high,
          ),
          TaskItem(
            id: '13',
            title: '清理排泄物',
            time: '随时',
            completed: false,
            type: TaskType.cleaning,
            priority: TaskPriority.medium,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _tasks.where((task) => task.completed).length;
    final totalTasks = _tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度概览
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NothingTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '今日进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '$completedTasks/$totalTasks',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: NothingTheme.accentPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: NothingTheme.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    NothingTheme.success,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  progress == 1.0 
                      ? '🎉 今日任务全部完成！' 
                      : '还有 ${totalTasks - completedTasks} 个任务待完成',
                  style: TextStyle(
                    fontSize: 12,
                    color: progress == 1.0 
                        ? NothingTheme.success 
                        : NothingTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 任务列表
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return _buildTaskItem(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
        border: Border.all(
          color: NothingTheme.gray200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 完成状态
          GestureDetector(
            onTap: () => _toggleTask(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.completed 
                    ? NothingTheme.success 
                    : NothingTheme.surface,
                border: Border.all(
                  color: task.completed 
                      ? NothingTheme.success 
                      : NothingTheme.gray300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: task.completed
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: NothingTheme.textInverse,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          // 任务图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTaskTypeColor(task.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTaskTypeIcon(task.type),
              size: 20,
              color: _getTaskTypeColor(task.type),
            ),
          ),

          const SizedBox(width: 16),

          // 任务信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: task.completed 
                              ? NothingTheme.textSecondary 
                              : NothingTheme.textPrimary,
                          decoration: task.completed 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    if (task.priority == TaskPriority.high)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: NothingTheme.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getTaskTypeColor(task.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getTaskTypeName(task.type),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getTaskTypeColor(task.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: NothingTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: NothingTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(String taskId) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          completed: !_tasks[index].completed,
        );
      }
    });
  }

  IconData _getTaskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.feeding:
        return Icons.restaurant_outlined;
      case TaskType.cleaning:
        return Icons.cleaning_services_outlined;
      case TaskType.play:
        return Icons.sports_esports_outlined;
      case TaskType.medical:
        return Icons.medical_services_outlined;
      case TaskType.preparation:
        return Icons.checklist_outlined;
      case TaskType.safety:
        return Icons.security_outlined;
    }
  }

  String _getTaskTypeName(TaskType type) {
    switch (type) {
      case TaskType.feeding:
        return '喂食';
      case TaskType.cleaning:
        return '清洁';
      case TaskType.play:
        return '游戏';
      case TaskType.medical:
        return '医疗';
      case TaskType.preparation:
        return '准备';
      case TaskType.safety:
        return '安全';
    }
  }

  Color _getTaskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.feeding:
        return NothingTheme.success;
      case TaskType.cleaning:
        return NothingTheme.info;
      case TaskType.play:
        return NothingTheme.warning;
      case TaskType.medical:
        return NothingTheme.error;
      case TaskType.preparation:
        return NothingTheme.accentPrimary;
      case TaskType.safety:
        return NothingTheme.brandPrimary;
    }
  }
}

// 任务数据模型
class TaskItem {
  final String id;
  final String title;
  final String time;
  final bool completed;
  final TaskType type;
  final TaskPriority priority;

  TaskItem({
    required this.id,
    required this.title,
    required this.time,
    required this.completed,
    required this.type,
    required this.priority,
  });

  TaskItem copyWith({
    String? id,
    String? title,
    String? time,
    bool? completed,
    TaskType? type,
    TaskPriority? priority,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      completed: completed ?? this.completed,
      type: type ?? this.type,
      priority: priority ?? this.priority,
    );
  }
}

enum TaskType {
  feeding,     // 喂食
  cleaning,    // 清洁
  play,        // 游戏
  medical,     // 医疗
  preparation, // 准备
  safety,      // 安全
}

enum TaskPriority {
  high,    // 高优先级
  medium,  // 中优先级
  low,     // 低优先级
}