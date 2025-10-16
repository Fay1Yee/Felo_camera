import 'dart:convert';
import 'dart:io';

/// 简化的AI结果模型（用于测试）
class SimpleAIResult {
  final String title;
  final int confidence;
  final String? subInfo;

  const SimpleAIResult({
    required this.title,
    required this.confidence,
    this.subInfo,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'confidence': confidence,
        if (subInfo != null) 'subInfo': subInfo,
      };
}

/// 简化的分析历史模型（用于测试）
class SimpleAnalysisHistory {
  final String id;
  final DateTime timestamp;
  final SimpleAIResult result;
  final String mode;
  final bool isRealtimeAnalysis;

  const SimpleAnalysisHistory({
    required this.id,
    required this.timestamp,
    required this.result,
    required this.mode,
    required this.isRealtimeAnalysis,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'result': result.toJson(),
        'mode': mode,
        'isRealtimeAnalysis': isRealtimeAnalysis,
      };
}

void main() async {
  print('🐾 生成今天的宠物行为记录测试数据...');
  
  try {
    // 获取今天的日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    print('📅 今天日期: ${today.toString().split(' ')[0]}');
    
    // 创建今天的测试数据 - 涵盖一整天的活动
    final todayTestData = [
      {
        'title': '晨间观望行为',
        'subInfo': '宠物在窗边观察外面的鸟类，注意力集中，尾巴轻微摆动',
        'confidence': 92,
        'timestamp': today.add(const Duration(hours: 7, minutes: 30)),
        'category': 'observe',
      },
      {
        'title': '早餐进食行为',
        'subInfo': '宠物在厨房进食早餐，食欲良好，进食速度正常',
        'confidence': 95,
        'timestamp': today.add(const Duration(hours: 8, minutes: 15)),
        'category': 'eating',
      },
      {
        'title': '上午玩耍行为',
        'subInfo': '宠物在客厅与玩具互动，精神状态活跃，动作敏捷',
        'confidence': 88,
        'timestamp': today.add(const Duration(hours: 10, minutes: 45)),
        'category': 'playing',
      },
      {
        'title': '午间休息行为',
        'subInfo': '宠物在沙发上午睡，呼吸平稳，身体放松',
        'confidence': 94,
        'timestamp': today.add(const Duration(hours: 13, minutes: 20)),
        'category': 'sleeping',
      },
      {
        'title': '下午探索行为',
        'subInfo': '宠物在房间内巡视，嗅探不同角落，表现出好奇心',
        'confidence': 86,
        'timestamp': today.add(const Duration(hours: 15, minutes: 10)),
        'category': 'exploring',
      },
      {
        'title': '傍晚互动行为',
        'subInfo': '宠物与主人互动，表现亲昵，发出愉悦的声音',
        'confidence': 91,
        'timestamp': today.add(const Duration(hours: 18, minutes: 30)),
        'category': 'interacting',
      },
      {
        'title': '晚餐进食行为',
        'subInfo': '宠物享用晚餐，食欲旺盛，进食后满足地舔毛',
        'confidence': 96,
        'timestamp': today.add(const Duration(hours: 19, minutes: 45)),
        'category': 'eating',
      },
      {
        'title': '夜间警戒行为',
        'subInfo': '宠物在门口附近保持警觉，偶尔抬头观察周围环境',
        'confidence': 89,
        'timestamp': today.add(const Duration(hours: 21, minutes: 15)),
        'category': 'guarding',
      },
    ];
    
    print('📝 开始生成今天的行为记录...');
    
    List<SimpleAnalysisHistory> histories = [];
    int addedCount = 0;
    
    for (final data in todayTestData) {
      final result = SimpleAIResult(
        title: data['title'] as String,
        subInfo: data['subInfo'] as String,
        confidence: data['confidence'] as int,
      );
      
      final history = SimpleAnalysisHistory(
        id: (data['timestamp'] as DateTime).millisecondsSinceEpoch.toString(),
        timestamp: data['timestamp'] as DateTime,
        result: result,
        mode: 'behavior',
        isRealtimeAnalysis: false,
      );
      
      histories.add(history);
      addedCount++;
      
      final time = '${(data['timestamp'] as DateTime).hour}:${(data['timestamp'] as DateTime).minute.toString().padLeft(2, '0')}';
      print('  ✅ 生成记录 $addedCount: ${data['title']} ($time)');
    }
    
    // 保存到JSON文件
    final outputFile = File('today_behavior_test_data.json');
    final jsonData = {
      'generated_date': DateTime.now().toIso8601String(),
      'target_date': today.toIso8601String(),
      'total_records': histories.length,
      'records': histories.map((h) => h.toJson()).toList(),
    };
    
    await outputFile.writeAsString(jsonEncode(jsonData));
    print('\n💾 测试数据已保存到: ${outputFile.path}');
    
    // 验证数据
    print('\n🔍 验证生成的数据...');
    final todayHistories = histories.where((h) {
      final historyDate = DateTime(h.timestamp.year, h.timestamp.month, h.timestamp.day);
      return historyDate.isAtSameMomentAs(today);
    }).toList();
    
    print('📊 总记录数: ${histories.length}');
    print('📅 今天的记录数: ${todayHistories.length}');
    
    if (todayHistories.length == todayTestData.length) {
      print('✅ 所有今天的测试数据生成成功！');
      
      print('\n📋 今天的行为记录摘要:');
      for (int i = 0; i < todayHistories.length; i++) {
        final history = todayHistories[i];
        final time = '${history.timestamp.hour}:${history.timestamp.minute.toString().padLeft(2, '0')}';
        print('  ${i + 1}. [$time] ${history.result.title} (置信度: ${history.result.confidence}%)');
      }
      
      print('\n📈 行为类型统计:');
      final categoryCount = <String, int>{};
      for (final data in todayTestData) {
        final category = data['category'] as String;
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
      
      categoryCount.forEach((category, count) {
        print('  • $category: $count 次');
      });
      
    } else {
      print('❌ 数据生成可能有问题，预期 ${todayTestData.length} 条，实际 ${todayHistories.length} 条');
      exit(1);
    }
    
  } catch (e, stackTrace) {
    print('❌ 测试失败: $e');
    print('堆栈跟踪: $stackTrace');
    exit(1);
  }
  
  print('\n🎉 今天的行为记录测试数据生成完成！');
  print('📄 可以将生成的JSON文件导入到应用中进行测试');
  exit(0);
}