import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ai_result.dart';
import 'api_client.dart';

/// 实时画面分析服务
class RealtimeAnalyzer {
  static RealtimeAnalyzer? _instance;
  static RealtimeAnalyzer get instance {
    _instance ??= RealtimeAnalyzer._();
    return _instance!;
  }
  
  RealtimeAnalyzer._();
  
  final ApiClient _apiClient = ApiClient.instance;
  Timer? _analysisTimer;
  bool _isAnalyzing = false;
  bool _isEnabled = false;
  File? _lastAnalyzedFile;
  
  // 分析结果回调
  Function(AIResult, File)? _onAnalysisResult;
  Function(String)? _onAnalysisError;
  
  /// 开始实时分析
  void startRealtimeAnalysis({
    required CameraController? controller,
    required Function(AIResult, File) onResult,
    required Function(String) onError,
    Duration interval = const Duration(seconds: 3),
  }) {
    if (_isEnabled || controller == null) return;
    
    _isEnabled = true;
    _onAnalysisResult = onResult;
    _onAnalysisError = onError;
    
    debugPrint('🎥 开始实时画面分析，间隔: ${interval.inSeconds}秒');
    
    _analysisTimer = Timer.periodic(interval, (timer) async {
      if (!_isEnabled || _isAnalyzing) return;
      
      await _performAnalysis(controller);
    });
  }
  
  /// 停止实时分析
  void stopRealtimeAnalysis() {
    if (!_isEnabled) return;
    
    _isEnabled = false;
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _onAnalysisResult = null;
    _onAnalysisError = null;
    
    debugPrint('⏹️ 停止实时画面分析');
  }
  
  /// 执行单次分析
  Future<void> _performAnalysis(CameraController controller) async {
    if (_isAnalyzing || !controller.value.isInitialized) return;
    
    _isAnalyzing = true;
    
    try {
      debugPrint('📸 捕获实时画面进行分析...');
      
      // 拍摄当前画面
      final XFile file = await controller.takePicture();
      
      // 保存到应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/realtime_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final fileName = 'realtime_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = '${imagesDir.path}/$fileName';
      final localFile = await File(file.path).copy(permanentPath);
      _lastAnalyzedFile = localFile;
      
      // 进行AI分析
      final result = await _apiClient.analyzeImage(localFile);
      
      // 回调结果
      _onAnalysisResult?.call(result, localFile);
      
      debugPrint('✅ 实时分析完成: ${result.title}');
      
      // 延迟清理临时文件（保留永久文件用于历史记录）
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await File(file.path).delete(); // 只删除临时文件
        } catch (e) {
          debugPrint('清理临时文件失败: $e');
        }
      });
      
    } catch (e) {
      debugPrint('❌ 实时分析失败: $e');
      _onAnalysisError?.call('实时分析失败: $e');
    } finally {
      _isAnalyzing = false;
    }
  }
  
  /// 检查是否正在分析
  bool get isAnalyzing => _isAnalyzing;
  
  /// 检查是否已启用
  bool get isEnabled => _isEnabled;
  
  /// 设置分析间隔
  void setAnalysisInterval(Duration interval) {
    if (_isEnabled && _analysisTimer != null) {
      stopRealtimeAnalysis();
      // 重新启动需要外部调用
    }
  }
}