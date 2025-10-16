import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lib/services/history_manager.dart';
import 'lib/models/ai_result.dart';
import 'lib/models/analysis_history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 开始为移动端导入今天的行为记录测试数据...');
  
  try {
    // 获取 HistoryManager 实例并初始化
    final historyManager = HistoryManager.instance;
    await historyManager.initialize();
    print('✅ HistoryManager 初始化成功');
    
    // 获取当前日期
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    print('📅 准备导入 ${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} 的测试数据');
    
    // 移动端优化的测试数据
    final testData = [
      {
        'id': 'mobile_test_001',
        'timestamp': today.add(const Duration(hours: 7, minutes: 30)).millisecondsSinceEpoch,
        'result': {
          'title': '晨间观望行为',
          'confidence': 0.92,
          'subInfo': '宠物在窗边观察外界环境，表现出好奇心'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_002', 
        'timestamp': today.add(const Duration(hours: 8, minutes: 15)).millisecondsSinceEpoch,
        'result': {
          'title': '早餐进食行为',
          'confidence': 0.95,
          'subInfo': '正常进食，食欲良好，进食速度适中'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_003',
        'timestamp': today.add(const Duration(hours: 10, minutes: 45)).millisecondsSinceEpoch,
        'result': {
          'title': '上午玩耍行为',
          'confidence': 0.88,
          'subInfo': '与玩具互动，活动量适中，精神状态良好'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_004',
        'timestamp': today.add(const Duration(hours: 13, minutes: 20)).millisecondsSinceEpoch,
        'result': {
          'title': '午间休息行为',
          'confidence': 0.94,
          'subInfo': '在舒适位置休息，呼吸平稳，睡眠质量良好'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_005',
        'timestamp': today.add(const Duration(hours: 15, minutes: 10)).millisecondsSinceEpoch,
        'result': {
          'title': '下午探索行为',
          'confidence': 0.86,
          'subInfo': '在房间内探索，嗅闻各处，表现出探索欲'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_006',
        'timestamp': today.add(const Duration(hours: 18, minutes: 30)).millisecondsSinceEpoch,
        'result': {
          'title': '傍晚互动行为',
          'confidence': 0.91,
          'subInfo': '与主人互动，响应呼唤，情绪积极'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_007',
        'timestamp': today.add(const Duration(hours: 19, minutes: 45)).millisecondsSinceEpoch,
        'result': {
          'title': '晚餐进食行为',
          'confidence': 0.96,
          'subInfo': '晚餐进食正常，食量适中，无异常表现'
        },
        'mode': 'behavior'
      },
      {
        'id': 'mobile_test_008',
        'timestamp': today.add(const Duration(hours: 21, minutes: 15)).millisecondsSinceEpoch,
        'result': {
          'title': '夜间警戒行为',
          'confidence': 0.89,
          'subInfo': '保持警觉状态，注意周围环境变化'
        },
        'mode': 'behavior'
      },
    ];
    
    // 导入测试数据
    for (final data in testData) {
      final result = AIResult.fromJson(data['result'] as Map<String, dynamic>);
      final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int);
      
      await historyManager.addHistoryWithTimestamp(
        result: result,
        mode: data['mode'] as String,
        timestamp: timestamp,
      );
    }
    
    print('✅ 成功导入 ${testData.length} 条移动端测试记录');
    
    // 验证导入结果
    final allRecords = await historyManager.getAllHistories();
    final todayRecords = allRecords.where((record) {
      final recordDate = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      return recordDate.isAtSameMomentAs(today);
    }).toList();
    print('📊 今天共有 ${todayRecords.length} 条记录');
    
    // 显示记录摘要
    print('\n📋 移动端测试数据摘要:');
    for (int i = 0; i < todayRecords.length; i++) {
      final record = todayRecords[i];
      final time = '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}';
      print('${i + 1}. [$time] ${record.result.title} (置信度: ${(record.result.confidence * 100).toInt()}%)');
    }
    
    // 统计行为类型
    final behaviorTypes = <String, int>{};
    for (final record in todayRecords) {
      final title = record.result.title;
      final type = title.contains('进食') ? '进食' :
                   title.contains('休息') ? '休息' :
                   title.contains('玩耍') ? '玩耍' :
                   title.contains('探索') ? '探索' :
                   title.contains('互动') ? '互动' :
                   title.contains('观望') ? '观望' :
                   title.contains('警戒') ? '警戒' : '其他';
      behaviorTypes[type] = (behaviorTypes[type] ?? 0) + 1;
    }
    
    print('\n📈 移动端行为类型统计:');
    behaviorTypes.forEach((type, count) {
      print('  $type: $count 次');
    });
    
    print('\n🎉 移动端测试数据导入完成！');
    print('💡 提示：数据已保存到移动端本地存储，可在应用中查看');
    
  } catch (e) {
    print('❌ 移动端导入失败: $e');
  }
}