enum AnalyzerType {
  local, // 完全离线本地分析器
}

class AppConfig {
  // 完全离线模式，不使用任何API
  static const AnalyzerType analyzer = AnalyzerType.local;
  
  // 移除API配置 - 完全离线应用
  // static const String apiBase = ''; // 已禁用
}