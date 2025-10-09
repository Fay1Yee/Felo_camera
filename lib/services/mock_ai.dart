import 'dart:math';

import '../models/ai_result.dart';
import '../models/mode.dart';

class MockAI {
  final _rng = Random();

  // 移除所有预设数据，仅保留错误情况下的占位符
  AIResult analyze(Mode mode) {
    // 这个方法现在只用于错误情况的占位符
    // 所有正常分析都应该通过远程API进行
    return const AIResult(
      title: '分析失败',
      confidence: 0,
      // 所有正常分析都应该通过远程API进行
      subInfo: '远程API处理出现问题',
    );
  }
}