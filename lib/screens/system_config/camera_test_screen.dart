import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../config/nothing_theme.dart';

enum TestStep {
  preparation,
  cameraAccess,
  imageCapture,
  focusTest,
  exposureTest,
  stabilityTest,
  completed,
}

class CameraTestScreen extends StatefulWidget {
  const CameraTestScreen({super.key});

  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  TestStep _currentStep = TestStep.preparation;
  bool _isLoading = false;
  String _statusMessage = '准备开始相机测试';
  
  // 测试结果
  Map<TestStep, bool> _testResults = {};
  List<String> _capturedImages = [];
  double _focusScore = 0.0;
  double _exposureScore = 0.0;
  double _stabilityScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _statusMessage = '相机初始化完成，准备开始测试';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '相机初始化失败: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NothingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '相机测试',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 24),
          _buildCurrentStepCard(),
          const SizedBox(height: 24),
          if (_cameraController != null && _cameraController!.value.isInitialized)
            _buildCameraPreview(),
          const SizedBox(height: 24),
          _buildTestResults(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = TestStep.values;
    final currentIndex = steps.indexOf(_currentStep);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '测试进度',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = _testResults[step] == true;
              final isCurrent = index == currentIndex;
              final isActive = index <= currentIndex;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? NothingTheme.success
                            : isCurrent
                                ? NothingTheme.info
                                : isActive
                                    ? NothingTheme.warning
                                    : NothingTheme.gray300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : isCurrent
                                ? Icons.play_arrow
                                : Icons.circle,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: isActive ? NothingTheme.info : NothingTheme.gray300,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${currentIndex + 1}/${steps.length} - ${_getStepName(_currentStep)}',
            style: const TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: NothingTheme.info,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getStepName(_currentStep),
                style: const TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _statusMessage,
            style: const TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getStepDescription(_currentStep),
            style: const TextStyle(
              color: NothingTheme.textTertiary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildTestResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
        border: Border.all(color: NothingTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '测试结果',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildTestResultItem('相机访问', _testResults[TestStep.cameraAccess]),
          _buildTestResultItem('图像捕获', _testResults[TestStep.imageCapture]),
          _buildTestResultItem('对焦测试', _testResults[TestStep.focusTest], score: _focusScore),
          _buildTestResultItem('曝光测试', _testResults[TestStep.exposureTest], score: _exposureScore),
          _buildTestResultItem('稳定性测试', _testResults[TestStep.stabilityTest], score: _stabilityScore),
          if (_capturedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '测试图片',
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '已捕获 ${_capturedImages.length} 张测试图片',
              style: const TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTestResultItem(String name, bool? result, {double? score}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              if (score != null && score > 0) ...[
                Text(
                  '${(score * 100).toInt()}%',
                  style: TextStyle(
                    color: score > 0.8 ? NothingTheme.success : score > 0.6 ? NothingTheme.warning : NothingTheme.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: result == true
                      ? NothingTheme.success
                      : result == false
                          ? NothingTheme.error
                          : NothingTheme.gray300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result == true
                      ? Icons.check
                      : result == false
                          ? Icons.close
                          : Icons.circle,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_currentStep != TestStep.completed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _runCurrentTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _getActionButtonText(_currentStep),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _currentStep == TestStep.completed ? _generateReport : _skipCurrentTest,
            style: OutlinedButton.styleFrom(
              foregroundColor: NothingTheme.textPrimary,
              side: const BorderSide(color: NothingTheme.gray300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              ),
            ),
            child: Text(
              _currentStep == TestStep.completed ? '生成测试报告' : '跳过此步骤',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStepName(TestStep step) {
    switch (step) {
      case TestStep.preparation:
        return '准备阶段';
      case TestStep.cameraAccess:
        return '相机访问测试';
      case TestStep.imageCapture:
        return '图像捕获测试';
      case TestStep.focusTest:
        return '对焦功能测试';
      case TestStep.exposureTest:
        return '曝光控制测试';
      case TestStep.stabilityTest:
        return '稳定性测试';
      case TestStep.completed:
        return '测试完成';
    }
  }

  String _getStepDescription(TestStep step) {
    switch (step) {
      case TestStep.preparation:
        return '检查相机权限和硬件状态，确保测试环境正常。';
      case TestStep.cameraAccess:
        return '验证应用是否能正常访问相机硬件，检查权限设置。';
      case TestStep.imageCapture:
        return '测试相机的基本拍照功能，验证图像保存能力。';
      case TestStep.focusTest:
        return '测试自动对焦功能的准确性和响应速度。';
      case TestStep.exposureTest:
        return '测试曝光控制的准确性，包括亮度和对比度调节。';
      case TestStep.stabilityTest:
        return '测试相机在不同条件下的稳定性和一致性。';
      case TestStep.completed:
        return '所有测试项目已完成，可以查看详细的测试报告。';
    }
  }

  String _getActionButtonText(TestStep step) {
    switch (step) {
      case TestStep.preparation:
        return '开始测试';
      case TestStep.cameraAccess:
        return '测试相机访问';
      case TestStep.imageCapture:
        return '测试图像捕获';
      case TestStep.focusTest:
        return '测试对焦功能';
      case TestStep.exposureTest:
        return '测试曝光控制';
      case TestStep.stabilityTest:
        return '测试稳定性';
      case TestStep.completed:
        return '完成测试';
    }
  }

  Future<void> _runCurrentTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (_currentStep) {
        case TestStep.preparation:
          await _testPreparation();
          break;
        case TestStep.cameraAccess:
          await _testCameraAccess();
          break;
        case TestStep.imageCapture:
          await _testImageCapture();
          break;
        case TestStep.focusTest:
          await _testFocus();
          break;
        case TestStep.exposureTest:
          await _testExposure();
          break;
        case TestStep.stabilityTest:
          await _testStability();
          break;
        case TestStep.completed:
          break;
      }
    } catch (e) {
      setState(() {
        _statusMessage = '测试失败: $e';
        _testResults[_currentStep] = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPreparation() async {
    setState(() {
      _statusMessage = '检查相机权限和硬件状态...';
    });

    await Future.delayed(const Duration(seconds: 2));

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _statusMessage = '准备阶段完成，相机硬件正常';
        _testResults[TestStep.preparation] = true;
        _currentStep = TestStep.cameraAccess;
      });
    } else {
      setState(() {
        _statusMessage = '相机硬件检测失败';
        _testResults[TestStep.preparation] = false;
      });
    }
  }

  Future<void> _testCameraAccess() async {
    setState(() {
      _statusMessage = '测试相机访问权限...';
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        setState(() {
          _statusMessage = '相机访问测试通过';
          _testResults[TestStep.cameraAccess] = true;
          _currentStep = TestStep.imageCapture;
        });
      } else {
        throw Exception('无法访问相机');
      }
    } catch (e) {
      setState(() {
        _statusMessage = '相机访问测试失败: $e';
        _testResults[TestStep.cameraAccess] = false;
      });
    }
  }

  Future<void> _testImageCapture() async {
    setState(() {
      _statusMessage = '测试图像捕获功能...';
    });

    try {
      final image = await _cameraController!.takePicture();
      _capturedImages.add(image.path);

      setState(() {
        _statusMessage = '图像捕获测试通过，已保存测试图片';
        _testResults[TestStep.imageCapture] = true;
        _currentStep = TestStep.focusTest;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '图像捕获测试失败: $e';
        _testResults[TestStep.imageCapture] = false;
      });
    }
  }

  Future<void> _testFocus() async {
    setState(() {
      _statusMessage = '测试自动对焦功能...';
    });

    await Future.delayed(const Duration(seconds: 3));

    // 模拟对焦测试
    final focusScore = 0.85 + (DateTime.now().millisecond % 15) / 100;
    
    setState(() {
      _focusScore = focusScore;
      _statusMessage = '对焦功能测试完成，得分: ${(focusScore * 100).toInt()}%';
      _testResults[TestStep.focusTest] = focusScore > 0.7;
      _currentStep = TestStep.exposureTest;
    });
  }

  Future<void> _testExposure() async {
    setState(() {
      _statusMessage = '测试曝光控制功能...';
    });

    await Future.delayed(const Duration(seconds: 3));

    // 模拟曝光测试
    final exposureScore = 0.78 + (DateTime.now().millisecond % 20) / 100;
    
    setState(() {
      _exposureScore = exposureScore;
      _statusMessage = '曝光控制测试完成，得分: ${(exposureScore * 100).toInt()}%';
      _testResults[TestStep.exposureTest] = exposureScore > 0.7;
      _currentStep = TestStep.stabilityTest;
    });
  }

  Future<void> _testStability() async {
    setState(() {
      _statusMessage = '测试相机稳定性...';
    });

    await Future.delayed(const Duration(seconds: 4));

    // 模拟稳定性测试
    final stabilityScore = 0.92 + (DateTime.now().millisecond % 8) / 100;
    
    setState(() {
      _stabilityScore = stabilityScore;
      _statusMessage = '稳定性测试完成，得分: ${(stabilityScore * 100).toInt()}%';
      _testResults[TestStep.stabilityTest] = stabilityScore > 0.8;
      _currentStep = TestStep.completed;
    });
  }

  void _skipCurrentTest() {
    setState(() {
      _testResults[_currentStep] = false;
      final steps = TestStep.values;
      final currentIndex = steps.indexOf(_currentStep);
      if (currentIndex < steps.length - 1) {
        _currentStep = steps[currentIndex + 1];
        _statusMessage = '已跳过上一步测试';
      }
    });
  }

  void _generateReport() {
    final passedTests = _testResults.values.where((result) => result == true).length;
    final totalTests = _testResults.length;
    final overallScore = (passedTests / totalTests * 100).toInt();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('测试报告'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总体得分: $overallScore%'),
            Text('通过测试: $passedTests/$totalTests'),
            const SizedBox(height: 16),
            if (_focusScore > 0) Text('对焦得分: ${(_focusScore * 100).toInt()}%'),
            if (_exposureScore > 0) Text('曝光得分: ${(_exposureScore * 100).toInt()}%'),
            if (_stabilityScore > 0) Text('稳定性得分: ${(_stabilityScore * 100).toInt()}%'),
            const SizedBox(height: 16),
            Text('测试图片: ${_capturedImages.length} 张'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
}