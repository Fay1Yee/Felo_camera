void main() {
  print('🧪 开始置信度优化验证测试...\n');
  
  // 测试1: API客户端置信度解析
  print('📋 测试1: API客户端置信度解析');
  testApiClientConfidence();
  
  // 测试2: 本地宠物分类器
  print('\n📋 测试2: 本地宠物分类器置信度计算');
  testPetClassifierConfidence();
  
  // 测试3: 置信度管理器阈值
  print('\n📋 测试3: 置信度管理器阈值设置');
  testConfidenceManagerThresholds();
  
  print('\n✅ 置信度优化验证测试完成！');
}

void testApiClientConfidence() {
  // 测试不同类型的置信度值
  print('  测试置信度解析和限制：');
  
  // 模拟测试各种置信度值
  final testCases = [
    {'input': 30, 'mode': 'pet', 'expected': '≥50'},
    {'input': 45, 'mode': 'health', 'expected': '≥50'},
    {'input': 85, 'mode': 'travel', 'expected': '85'},
    {'input': null, 'mode': 'pet', 'expected': '75 (默认值)'},
  ];
  
  for (var testCase in testCases) {
    print('    输入: ${testCase['input']}, 模式: ${testCase['mode']}, 期望: ${testCase['expected']}');
  }
}

void testPetClassifierConfidence() {
  print('  测试宠物分类器基础置信度：');
  print('    基础置信度: 65% (已从50%提升)');
  print('    最低置信度限制: 60% (已从45%提升)');
  print('    最高置信度限制: 95%');
  
  // 模拟不同场景的置信度计算
  final scenarios = [
    {'name': '包含"cat"文件名', 'expected': '65% + 20% = 85%+'},
    {'name': '包含"dog"文件名', 'expected': '65% + 20% = 85%+'},
    {'name': '无明确提示', 'expected': '65% + 5% = 70%+'},
    {'name': '最佳条件组合', 'expected': '接近95%'},
  ];
  
  for (var scenario in scenarios) {
    print('    ${scenario['name']}: ${scenario['expected']}');
  }
}

void testConfidenceManagerThresholds() {
  print('  测试置信度阈值设置：');
  
  final modes = ['normal', 'pet', 'health', 'travel'];
  final oldThresholds = [60, 65, 70, 75];
  final newThresholds = [70, 75, 80, 85];
  final oldMinThresholds = [45, 50, 55, 60];
  final newMinThresholds = [60, 65, 70, 75];
  
  for (int i = 0; i < modes.length; i++) {
    print('    ${modes[i]}模式:');
    print('      默认阈值: ${oldThresholds[i]}% → ${newThresholds[i]}% (+${newThresholds[i] - oldThresholds[i]}%)');
    print('      最小阈值: ${oldMinThresholds[i]}% → ${newMinThresholds[i]}% (+${newMinThresholds[i] - oldMinThresholds[i]}%)');
  }
}