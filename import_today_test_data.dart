import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'lib/services/history_manager.dart';
import 'lib/models/ai_result.dart';

void main() async {
  print('📥 开始导入今天的行为记录测试数据...');
  
  try {
    // 初始化HistoryManager
    await HistoryManager.instance.initialize();
    print('✅ HistoryManager初始化成功');
    
    // 获取今天的日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 直接嵌入测试数据（避免Web环境文件读取问题）
    final testData = {
      'generated_date': DateTime.now().toIso8601String(),
      'target_date': today.toIso8601String(),
      'total_records': 8,
      'records': [
        {
          'id': '${today.add(const Duration(hours: 7, minutes: 30)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 7, minutes: 30)).toIso8601String(),
          'result': {
            'title': '晨间观望行为',
            'confidence': 92,
            'subInfo': '宠物在窗边观察外面的鸟类，注意力集中，尾巴轻微摆动'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 8, minutes: 15)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 8, minutes: 15)).toIso8601String(),
          'result': {
            'title': '早餐进食行为',
            'confidence': 95,
            'subInfo': '宠物在厨房进食早餐，食欲良好，进食速度正常'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 10, minutes: 45)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 10, minutes: 45)).toIso8601String(),
          'result': {
            'title': '上午玩耍行为',
            'confidence': 88,
            'subInfo': '宠物在客厅与玩具互动，精神状态活跃，动作敏捷'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 13, minutes: 20)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 13, minutes: 20)).toIso8601String(),
          'result': {
            'title': '午间休息行为',
            'confidence': 94,
            'subInfo': '宠物在沙发上午睡，呼吸平稳，身体放松'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 15, minutes: 10)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 15, minutes: 10)).toIso8601String(),
          'result': {
            'title': '下午探索行为',
            'confidence': 86,
            'subInfo': '宠物在房间内巡视，嗅探不同角落，表现出好奇心'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 18, minutes: 30)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 18, minutes: 30)).toIso8601String(),
          'result': {
            'title': '傍晚互动行为',
            'confidence': 91,
            'subInfo': '宠物与主人互动，表现亲昵，发出愉悦的声音'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 19, minutes: 45)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 19, minutes: 45)).toIso8601String(),
          'result': {
            'title': '晚餐进食行为',
            'confidence': 96,
            'subInfo': '宠物享用晚餐，食欲旺盛，进食后满足地舔毛'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
        {
          'id': '${today.add(const Duration(hours: 21, minutes: 15)).millisecondsSinceEpoch}',
          'timestamp': today.add(const Duration(hours: 21, minutes: 15)).toIso8601String(),
          'result': {
            'title': '夜间警戒行为',
            'confidence': 89,
            'subInfo': '宠物在门口附近保持警觉，偶尔抬头观察周围环境'
          },
          'mode': 'behavior',
          'isRealtimeAnalysis': false,
        },
      ]
    };
    
    print('📄 读取测试数据文件成功');
    print('📅 目标日期: ${testData['target_date']}');
    print('📊 总记录数: ${testData['total_records']}');
    
    // 清空现有数据（可选）
    print('\n🗑️ 清理旧的测试数据...');
    await HistoryManager.instance.clearAllHistories();
    
    // 导入测试数据
    final records = testData['records'] as List<dynamic>;
    int importedCount = 0;
    
    print('\n📝 开始导入行为记录...');
    
    for (final recordData in records) {
      final record = recordData as Map<String, dynamic>;
      final resultData = record['result'] as Map<String, dynamic>;
      
      // 创建AIResult对象
      final result = AIResult(
        title: resultData['title'] as String,
        subInfo: resultData['subInfo'] as String?,
        confidence: resultData['confidence'] as int,
      );
      
      // 解析时间戳
      final timestamp = DateTime.parse(record['timestamp'] as String);
      
      // 添加到HistoryManager
      await HistoryManager.instance.addHistoryWithTimestamp(
        result: result,
        mode: record['mode'] as String,
        timestamp: timestamp,
        isRealtimeAnalysis: record['isRealtimeAnalysis'] as bool,
      );
      
      importedCount++;
      final time = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
      print('  ✅ 导入记录 $importedCount: ${result.title} ($time)');
    }
    
    // 验证导入结果
    print('\n🔍 验证导入的数据...');
    final allHistories = await HistoryManager.instance.getAllHistories();
    
    // 获取今天的记录
    final todayHistories = allHistories.where((h) {
      final historyDate = DateTime(h.timestamp.year, h.timestamp.month, h.timestamp.day);
      return historyDate.isAtSameMomentAs(today);
    }).toList();
    
    print('📊 总历史记录数: ${allHistories.length}');
    print('📅 今天的记录数: ${todayHistories.length}');
    
    if (todayHistories.length == records.length) {
      print('✅ 所有测试数据导入成功！');
      
      print('\n📋 今天的行为记录摘要:');
      for (int i = 0; i < todayHistories.length; i++) {
        final history = todayHistories[i];
        final time = '${history.timestamp.hour}:${history.timestamp.minute.toString().padLeft(2, '0')}';
        print('  ${i + 1}. [$time] ${history.result.title} (置信度: ${history.result.confidence}%)');
      }
      
      // 统计行为类型
      print('\n📈 行为类型统计:');
      final titleCount = <String, int>{};
      for (final history in todayHistories) {
        final title = history.result.title;
        final category = _getCategoryFromTitle(title);
        titleCount[category] = (titleCount[category] ?? 0) + 1;
      }
      
      titleCount.forEach((category, count) {
        print('  • $category: $count 次');
      });
      
    } else {
      print('❌ 数据导入可能有问题，预期 ${records.length} 条，实际 ${todayHistories.length} 条');
      exit(1);
    }
    
  } catch (e, stackTrace) {
    print('❌ 导入失败: $e');
    print('堆栈跟踪: $stackTrace');
    exit(1);
  }
  
  print('\n🎉 今天的行为记录测试数据导入完成！');
  print('📱 现在可以在应用中查看这些测试数据了');
  exit(0);
}

String _getCategoryFromTitle(String title) {
  if (title.contains('观望') || title.contains('观察')) return '观望行为';
  if (title.contains('进食') || title.contains('吃')) return '进食行为';
  if (title.contains('玩耍') || title.contains('玩')) return '玩耍行为';
  if (title.contains('休息') || title.contains('睡')) return '休息行为';
  if (title.contains('探索')) return '探索行为';
  if (title.contains('互动')) return '互动行为';
  if (title.contains('警戒') || title.contains('守卫')) return '警戒行为';
  return '其他行为';
}