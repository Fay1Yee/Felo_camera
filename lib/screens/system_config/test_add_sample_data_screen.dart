import 'package:flutter/material.dart';
import '../../services/history_manager.dart';
import '../../models/analysis_history.dart';
import '../../models/ai_result.dart';

/// 添加示例数据的测试页面
class TestAddSampleDataScreen extends StatefulWidget {
  const TestAddSampleDataScreen({super.key});

  @override
  State<TestAddSampleDataScreen> createState() => _TestAddSampleDataScreenState();
}

class _TestAddSampleDataScreenState extends State<TestAddSampleDataScreen> {
  bool _isLoading = false;
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加测试数据'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _addSampleData,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('添加示例数据'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _message = '正在添加示例数据...';
    });

    try {
      await HistoryManager.instance.initialize();
      
      // 创建示例数据
      final sampleData = [
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'title': '进食行为',
          'content': '宠物在厨房进食，表现正常',
          'confidence': 95.0,
          'mode': 'pet_activity',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'title': '玩耍行为',
          'content': '宠物在客厅玩耍，精神状态良好',
          'confidence': 88.0,
          'mode': 'pet_activity',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
          'title': '观察行为',
          'content': '宠物在窗边观望，注意力集中',
          'confidence': 92.0,
          'mode': 'pet_activity',
        },
      ];

      for (final data in sampleData) {
        final result = AIResult(
          title: data['title'] as String,
          confidence: (data['confidence'] as double).round(),
          subInfo: data['content'] as String,
        );

        await HistoryManager.instance.addHistoryWithTimestamp(
          result: result,
          mode: data['mode'] as String,
          timestamp: data['timestamp'] as DateTime,
        );
      }

      final allHistories = await HistoryManager.instance.getAllHistories();
      
      setState(() {
        _isLoading = false;
        _message = '成功添加 ${sampleData.length} 条示例数据！\n总记录数: ${allHistories.length}';
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = '添加数据失败: $e';
      });
    }
  }
}