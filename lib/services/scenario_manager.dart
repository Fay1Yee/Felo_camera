import 'package:flutter/material.dart';
import '../models/pet_profile.dart';

/// 场景模式管理器
/// 提供场景切换、状态管理和相关功能
class ScenarioManager extends ChangeNotifier {
  static final ScenarioManager _instance = ScenarioManager._internal();
  factory ScenarioManager() => _instance;
  ScenarioManager._internal();

  ScenarioMode _currentScenario = ScenarioMode.home;
  DateTime _lastScenarioChange = DateTime.now();
  Map<ScenarioMode, ScenarioConfig> _scenarioConfigs = {};

  /// 当前场景模式
  ScenarioMode get currentScenario => _currentScenario;

  /// 上次场景切换时间
  DateTime get lastScenarioChange => _lastScenarioChange;

  /// 获取场景配置
  ScenarioConfig getScenarioConfig(ScenarioMode scenario) {
    return _scenarioConfigs[scenario] ?? ScenarioConfig.defaultConfig(scenario);
  }

  /// 切换场景模式
  void changeScenario(ScenarioMode newScenario) {
    if (_currentScenario != newScenario) {
      final oldScenario = _currentScenario;
      _currentScenario = newScenario;
      _lastScenarioChange = DateTime.now();
      
      // 触发场景切换事件
      _onScenarioChanged(oldScenario, newScenario);
      notifyListeners();
    }
  }

  /// 获取场景模式的推荐功能
  List<ScenarioFeature> getRecommendedFeatures(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return [
          ScenarioFeature(
            id: 'daily_care',
            title: '日常护理',
            description: '记录喂食、清洁等日常活动',
            icon: Icons.pets,
            priority: 1,
          ),
          ScenarioFeature(
            id: 'behavior_analysis',
            title: '行为分析',
            description: '分析宠物在家中的行为模式',
            icon: Icons.analytics,
            priority: 2,
          ),
          ScenarioFeature(
            id: 'smart_reminder',
            title: '智能提醒',
            description: '基于时间和行为的智能提醒',
            icon: Icons.notifications_active,
            priority: 3,
          ),
        ];
      case ScenarioMode.travel:
        return [
          ScenarioFeature(
            id: 'location_tracking',
            title: '位置追踪',
            description: '实时追踪宠物位置信息',
            icon: Icons.location_on,
            priority: 1,
          ),
          ScenarioFeature(
            id: 'travel_safety',
            title: '出行安全',
            description: '监控出行过程中的安全状况',
            icon: Icons.security,
            priority: 2,
          ),
          ScenarioFeature(
            id: 'emergency_contact',
            title: '紧急联系',
            description: '快速联系紧急联系人',
            icon: Icons.emergency,
            priority: 3,
          ),
        ];
      case ScenarioMode.medical:
        return [
          ScenarioFeature(
            id: 'health_monitoring',
            title: '健康监测',
            description: '实时监测宠物健康状况',
            icon: Icons.favorite,
            priority: 1,
          ),
          ScenarioFeature(
            id: 'medical_records',
            title: '医疗记录',
            description: '管理疫苗、体检等医疗记录',
            icon: Icons.medical_services,
            priority: 2,
          ),
          ScenarioFeature(
            id: 'symptom_tracker',
            title: '症状追踪',
            description: '记录和追踪异常症状',
            icon: Icons.monitor_heart,
            priority: 3,
          ),
        ];
      case ScenarioMode.urban:
        return [
          ScenarioFeature(
            id: 'public_services',
            title: '公共服务',
            description: '查找附近的宠物服务设施',
            icon: Icons.public,
            priority: 1,
          ),
          ScenarioFeature(
            id: 'social_interaction',
            title: '社交互动',
            description: '与其他宠物主人交流互动',
            icon: Icons.people,
            priority: 2,
          ),
          ScenarioFeature(
            id: 'city_regulations',
            title: '城市法规',
            description: '了解当地宠物相关法规',
            icon: Icons.gavel,
            priority: 3,
          ),
        ];
    }
  }

  /// 获取场景模式的快捷操作
  List<QuickAction> getQuickActions(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return [
          QuickAction(
            id: 'feed_pet',
            title: '喂食记录',
            icon: Icons.restaurant,
            color: Colors.orange,
          ),
          QuickAction(
            id: 'play_time',
            title: '游戏时间',
            icon: Icons.sports_esports,
            color: Colors.blue,
          ),
          QuickAction(
            id: 'sleep_track',
            title: '睡眠追踪',
            icon: Icons.bedtime,
            color: Colors.purple,
          ),
        ];
      case ScenarioMode.travel:
        return [
          QuickAction(
            id: 'check_location',
            title: '查看位置',
            icon: Icons.my_location,
            color: Colors.green,
          ),
          QuickAction(
            id: 'travel_checklist',
            title: '出行清单',
            icon: Icons.checklist,
            color: Colors.blue,
          ),
          QuickAction(
            id: 'emergency_call',
            title: '紧急呼叫',
            icon: Icons.phone,
            color: Colors.red,
          ),
        ];
      case ScenarioMode.medical:
        return [
          QuickAction(
            id: 'health_check',
            title: '健康检查',
            icon: Icons.health_and_safety,
            color: Colors.red,
          ),
          QuickAction(
            id: 'medication',
            title: '用药提醒',
            icon: Icons.medication,
            color: Colors.green,
          ),
          QuickAction(
            id: 'vet_appointment',
            title: '预约医生',
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
        ];
      case ScenarioMode.urban:
        return [
          QuickAction(
            id: 'find_services',
            title: '查找服务',
            icon: Icons.search,
            color: Colors.blue,
          ),
          QuickAction(
            id: 'community',
            title: '社区互动',
            icon: Icons.forum,
            color: Colors.green,
          ),
          QuickAction(
            id: 'report_issue',
            title: '问题举报',
            icon: Icons.report,
            color: Colors.orange,
          ),
        ];
    }
  }

  /// 场景切换事件处理
  void _onScenarioChanged(ScenarioMode oldScenario, ScenarioMode newScenario) {
    // 记录场景切换日志
    debugPrint('场景切换: $oldScenario -> $newScenario');
    
    // 可以在这里添加场景切换的业务逻辑
    // 例如：更新UI主题、调整功能权重、发送分析事件等
  }

  /// 获取场景使用统计
  Map<ScenarioMode, int> getScenarioUsageStats() {
    // 这里可以从本地存储或服务器获取真实的使用统计
    return {
      ScenarioMode.home: 45,
      ScenarioMode.travel: 20,
      ScenarioMode.medical: 25,
      ScenarioMode.urban: 10,
    };
  }

  /// 获取场景切换建议
  ScenarioMode? getSuggestedScenario() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // 基于时间的场景建议
    if (hour >= 6 && hour < 9) {
      return ScenarioMode.home; // 早晨居家时间
    } else if (hour >= 9 && hour < 17) {
      return ScenarioMode.urban; // 白天城市活动
    } else if (hour >= 17 && hour < 21) {
      return ScenarioMode.home; // 傍晚回家时间
    } else {
      return ScenarioMode.home; // 夜间居家
    }
  }
}

/// 场景配置
class ScenarioConfig {
  final ScenarioMode scenario;
  final Color primaryColor;
  final Color accentColor;
  final List<String> enabledFeatures;
  final Map<String, dynamic> settings;

  const ScenarioConfig({
    required this.scenario,
    required this.primaryColor,
    required this.accentColor,
    required this.enabledFeatures,
    required this.settings,
  });

  static ScenarioConfig defaultConfig(ScenarioMode scenario) {
    switch (scenario) {
      case ScenarioMode.home:
        return ScenarioConfig(
          scenario: scenario,
          primaryColor: Colors.blue,
          accentColor: Colors.lightBlue,
          enabledFeatures: ['daily_care', 'behavior_analysis', 'smart_reminder'],
          settings: {'auto_reminder': true, 'behavior_tracking': true},
        );
      case ScenarioMode.travel:
        return ScenarioConfig(
          scenario: scenario,
          primaryColor: Colors.green,
          accentColor: Colors.lightGreen,
          enabledFeatures: ['location_tracking', 'travel_safety', 'emergency_contact'],
          settings: {'gps_tracking': true, 'emergency_mode': false},
        );
      case ScenarioMode.medical:
        return ScenarioConfig(
          scenario: scenario,
          primaryColor: Colors.red,
          accentColor: Colors.pink,
          enabledFeatures: ['health_monitoring', 'medical_records', 'symptom_tracker'],
          settings: {'health_alerts': true, 'medication_reminders': true},
        );
      case ScenarioMode.urban:
        return ScenarioConfig(
          scenario: scenario,
          primaryColor: Colors.purple,
          accentColor: Colors.deepPurple,
          enabledFeatures: ['public_services', 'social_interaction', 'city_regulations'],
          settings: {'location_services': true, 'social_features': true},
        );
    }
  }
}

/// 场景功能
class ScenarioFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int priority;

  const ScenarioFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
  });
}

/// 快捷操作
class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}