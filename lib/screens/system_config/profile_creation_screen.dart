import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

/// 档案创建步骤
enum ProfileCreationStep {
  basic('基本信息', Icons.pets, '录入宠物基本信息'),
  physical('体征信息', Icons.monitor_weight, '记录身体特征数据'),
  health('健康状况', Icons.favorite, '了解健康历史'),
  behavior('行为习惯', Icons.psychology, '记录行为特点'),
  preferences('偏好设置', Icons.tune, '个性化配置'),
  complete('完成创建', Icons.check_circle, '档案创建完成');

  const ProfileCreationStep(this.title, this.icon, this.description);
  
  final String title;
  final IconData icon;
  final String description;
}

/// 档案创建界面
class ProfileCreationScreen extends StatefulWidget {
  final ScenarioMode currentScenario;

  const ProfileCreationScreen({
    super.key,
    required this.currentScenario,
  });

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _stepAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final PageController _pageController = PageController();
  ProfileCreationStep _currentStep = ProfileCreationStep.basic;
  int _currentStepIndex = 0;

  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _chestController = TextEditingController();
  final _notesController = TextEditingController();

  // 档案数据
  String _selectedSpecies = 'cat';
  String _selectedGender = 'male';
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  bool _isNeutered = false;
  List<String> _selectedColors = [];
  List<String> _selectedPersonalities = [];
  List<String> _selectedHealthIssues = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedFavoriteActivities = [];
  List<String> _selectedFavoriteFoods = [];
  String? _selectedAvatar;

  // 选项数据
  final List<String> _colorOptions = [
    '黑色', '白色', '棕色', '灰色', '橙色', '黄色', 
    '奶油色', '银色', '蓝色', '巧克力色', '三花', '虎斑'
  ];

  final List<String> _personalityOptions = [
    '活泼好动', '温顺安静', '聪明机警', '独立自主', '粘人撒娇',
    '胆小谨慎', '勇敢无畏', '好奇心强', '懒散悠闲', '社交友好'
  ];

  final List<String> _healthIssueOptions = [
    '无特殊问题', '关节炎', '皮肤过敏', '消化不良', '呼吸道问题',
    '心脏病', '肾脏疾病', '糖尿病', '眼部疾病', '耳部感染'
  ];

  final List<String> _allergyOptions = [
    '无过敏', '食物过敏', '花粉过敏', '尘螨过敏', '化学品过敏',
    '某些药物', '特定蛋白质', '环境过敏原', '跳蚤过敏', '其他'
  ];

  final List<String> _activityOptions = [
    '散步', '跑步', '游泳', '玩球', '捉迷藏',
    '攀爬', '追逐', '晒太阳', '看窗外', '互动游戏'
  ];

  final List<String> _foodOptions = [
    '干粮', '湿粮', '生食', '鸡肉', '鱼肉',
    '牛肉', '蔬菜', '水果', '零食', '特殊配方'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepAnimationController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    _chestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: const Text(
          '创建宠物档案',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NothingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentStepIndex > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                '上一步',
                style: TextStyle(
                  color: NothingTheme.info,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 进度指示器
            _buildProgressIndicator(),
            
            // 内容区域
            Expanded(
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildBasicInfoStep(),
                        _buildPhysicalInfoStep(),
                        _buildHealthInfoStep(),
                        _buildBehaviorInfoStep(),
                        _buildPreferencesStep(),
                        _buildCompleteStep(),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // 底部按钮
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 步骤标题
          Text(
            _currentStep.title,
            style: const TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            _currentStep.description,
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // 进度条
          Row(
            children: ProfileCreationStep.values.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = index <= _currentStepIndex;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive ? NothingTheme.info : NothingTheme.gray300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < ProfileCreationStep.values.length - 1)
                      const SizedBox(width: 4),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          
          // 步骤图标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ProfileCreationStep.values.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isActive = index <= _currentStepIndex;
              final isCurrent = index == _currentStepIndex;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? NothingTheme.info : NothingTheme.gray300,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isCurrent ? [
                    BoxShadow(
                      color: NothingTheme.info.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Icon(
                  step.icon,
                  color: isActive ? Colors.white : NothingTheme.gray500,
                  size: 16,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像选择
            Center(
              child: GestureDetector(
                onTap: _selectAvatar,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: NothingTheme.info,
                      width: 2,
                    ),
                  ),
                  child: _selectedAvatar != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: Image.asset(
                                _selectedAvatar!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              _selectedSpecies == 'cat' ? Icons.pets : Icons.pets,
                              color: NothingTheme.info,
                              size: 40,
                            ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Center(
              child: Text(
                '点击选择头像',
                style: TextStyle(
                  color: NothingTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // 宠物名称
            _buildInputField(
              label: '宠物名称',
              controller: _nameController,
              hint: '请输入宠物的名字',
              icon: Icons.badge,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入宠物名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            // 宠物种类
            _buildSectionTitle('宠物种类'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpecies = 'cat';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedSpecies == 'cat' ? NothingTheme.info.withOpacity(0.1) : NothingTheme.surface,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        border: Border.all(
                          color: _selectedSpecies == 'cat' ? NothingTheme.info : NothingTheme.gray300,
                          width: _selectedSpecies == 'cat' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets,
                            color: _selectedSpecies == 'cat' ? NothingTheme.info : NothingTheme.gray400,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '猫咪',
                            style: TextStyle(
                              color: _selectedSpecies == 'cat' ? NothingTheme.info : NothingTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpecies = 'dog';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedSpecies == 'dog' ? NothingTheme.info.withOpacity(0.1) : NothingTheme.surface,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        border: Border.all(
                          color: _selectedSpecies == 'dog' ? NothingTheme.info : NothingTheme.gray300,
                          width: _selectedSpecies == 'dog' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets,
                            color: _selectedSpecies == 'dog' ? NothingTheme.info : NothingTheme.gray400,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '狗狗',
                            style: TextStyle(
                              color: _selectedSpecies == 'dog' ? NothingTheme.info : NothingTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 品种
            _buildInputField(
              label: '品种',
              controller: _breedController,
              hint: '请输入宠物品种',
              icon: Icons.category,
            ),
            const SizedBox(height: 20),
            
            // 性别
            _buildSectionTitle('性别'),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = 'male';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'male' ? Colors.blue.withOpacity(0.1) : NothingTheme.surface,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        border: Border.all(
                          color: _selectedGender == 'male' ? Colors.blue : NothingTheme.gray300,
                          width: _selectedGender == 'male' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.male,
                            color: _selectedGender == 'male' ? Colors.blue : NothingTheme.gray400,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '雄性',
                            style: TextStyle(
                              color: _selectedGender == 'male' ? Colors.blue : NothingTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGender = 'female';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedGender == 'female' ? Colors.pink.withOpacity(0.1) : NothingTheme.surface,
                        borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                        border: Border.all(
                          color: _selectedGender == 'female' ? Colors.pink : NothingTheme.gray300,
                          width: _selectedGender == 'female' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.female,
                            color: _selectedGender == 'female' ? Colors.pink : NothingTheme.gray400,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '雌性',
                            style: TextStyle(
                              color: _selectedGender == 'female' ? Colors.pink : NothingTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 出生日期
            _buildSectionTitle('出生日期'),
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: _selectBirthDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NothingTheme.surface,
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                  border: Border.all(color: NothingTheme.gray300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: NothingTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Text(
                        '${_birthDate.year}年${_birthDate.month}月${_birthDate.day}日',
                        style: const TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    Text(
                      '${_calculateAge(_birthDate)}岁',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 绝育状态
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                border: Border.all(color: NothingTheme.gray300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: NothingTheme.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Text(
                      '已绝育',
                      style: const TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  Switch(
                    value: _isNeutered,
                    onChanged: (value) {
                      setState(() {
                        _isNeutered = value;
                      });
                    },
                    activeColor: NothingTheme.success,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 体重
          _buildInputField(
            label: '体重 (kg)',
            controller: _weightController,
            hint: '请输入体重',
            icon: Icons.monitor_weight,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
          ),
          const SizedBox(height: 20),
          
          // 身高
          _buildInputField(
            label: '身高 (cm)',
            controller: _heightController,
            hint: '请输入身高',
            icon: Icons.height,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
          ),
          const SizedBox(height: 20),
          
          // 体长
          _buildInputField(
            label: '体长 (cm)',
            controller: _lengthController,
            hint: '请输入体长',
            icon: Icons.straighten,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
          ),
          const SizedBox(height: 20),
          
          // 胸围
          _buildInputField(
            label: '胸围 (cm)',
            controller: _chestController,
            hint: '请输入胸围',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
          ),
          const SizedBox(height: 20),
          
          // 毛色
          _buildSectionTitle('毛色特征'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _colorOptions,
            selectedOptions: _selectedColors,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedColors = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 健康问题
          _buildSectionTitle('健康状况'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _healthIssueOptions,
            selectedOptions: _selectedHealthIssues,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedHealthIssues = selected;
              });
            },
          ),
          const SizedBox(height: 24),
          
          // 过敏情况
          _buildSectionTitle('过敏情况'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _allergyOptions,
            selectedOptions: _selectedAllergies,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedAllergies = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 性格特点
          _buildSectionTitle('性格特点'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _personalityOptions,
            selectedOptions: _selectedPersonalities,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedPersonalities = selected;
              });
            },
          ),
          const SizedBox(height: 24),
          
          // 喜欢的活动
          _buildSectionTitle('喜欢的活动'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _activityOptions,
            selectedOptions: _selectedFavoriteActivities,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedFavoriteActivities = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 喜欢的食物
          _buildSectionTitle('喜欢的食物'),
          const SizedBox(height: 12),
          
          _buildMultiSelectChips(
            options: _foodOptions,
            selectedOptions: _selectedFavoriteFoods,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedFavoriteFoods = selected;
              });
            },
          ),
          const SizedBox(height: 24),
          
          // 备注
          _buildInputField(
            label: '其他备注',
            controller: _notesController,
            hint: '记录其他重要信息...',
            icon: Icons.note,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 成功图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: NothingTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.check_circle,
              color: NothingTheme.success,
              size: 60,
            ),
          ),
          const SizedBox(height: 32),
          
          const Text(
            '档案创建成功！',
            style: TextStyle(
              color: NothingTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            '${_nameController.text}的档案已经创建完成\n您可以开始使用智能宠物管家的各项功能了',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // 档案预览卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NothingTheme.surface,
              borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: NothingTheme.blackAlpha05,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 头像和基本信息
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: NothingTheme.gray100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.pets,
                        color: NothingTheme.info,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isNotEmpty ? _nameController.text : '未命名',
                            style: const TextStyle(
                              color: NothingTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          Text(
                            '${_selectedSpecies == 'cat' ? '猫咪' : '狗狗'} • ${_selectedGender == 'male' ? '雄性' : '雌性'} • ${_calculateAge(_birthDate)}岁',
                            style: TextStyle(
                              color: NothingTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 统计信息
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('体重', _weightController.text.isNotEmpty ? '${_weightController.text}kg' : '--'),
                    ),
                    Expanded(
                      child: _buildStatItem('品种', _breedController.text.isNotEmpty ? _breedController.text : '--'),
                    ),
                    Expanded(
                      child: _buildStatItem('绝育', _isNeutered ? '是' : '否'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: NothingTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStepIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: NothingTheme.gray300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                  ),
                ),
                child: Text(
                  '上一步',
                  style: TextStyle(
                    color: NothingTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          
          if (_currentStepIndex > 0)
            const SizedBox(width: 16),
          
          Expanded(
            flex: _currentStepIndex > 0 ? 2 : 1,
            child: ElevatedButton(
              onPressed: _currentStepIndex == ProfileCreationStep.values.length - 1
                  ? _completeCreation
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.info,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                ),
              ),
              child: Text(
                _currentStepIndex == ProfileCreationStep.values.length - 1
                    ? '完成创建'
                    : '下一步',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: NothingTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: NothingTheme.info,
              size: 20,
            ),
            filled: true,
            fillColor: NothingTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.info, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: BorderSide(color: NothingTheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return GestureDetector(
          onTap: () {
            final newSelection = List<String>.from(selectedOptions);
            if (isSelected) {
              newSelection.remove(option);
            } else {
              newSelection.add(option);
            }
            onSelectionChanged(newSelection);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? NothingTheme.info.withOpacity(0.1) : NothingTheme.surface,
              borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
              border: Border.all(
                color: isSelected ? NothingTheme.info : NothingTheme.gray300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? NothingTheme.info : NothingTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _selectAvatar() {
    // 显示头像选择对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择头像'),
        content: const Text('头像选择功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 30年前
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _nextStep() {
    if (_currentStepIndex == 0) {
      // 验证基本信息
      if (_formKey.currentState?.validate() != true) {
        return;
      }
    }

    if (_currentStepIndex < ProfileCreationStep.values.length - 1) {
      setState(() {
        _currentStepIndex++;
        _currentStep = ProfileCreationStep.values[_currentStepIndex];
      });
      
      _stepAnimationController.forward().then((_) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _stepAnimationController.reset();
      });
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _currentStep = ProfileCreationStep.values[_currentStepIndex];
      });
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeCreation() {
    // 创建宠物档案
    final profile = PetProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _selectedSpecies,
      breed: _breedController.text,
      gender: _selectedGender,
      birthDate: _birthDate,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      color: _selectedColors.join(', '),
      avatarUrl: _selectedAvatar ?? '',
      chipId: '',
      registrationNumber: '',
      personalityTags: _selectedPersonalities,
      healthInfo: PetHealthInfo(
        isNeutered: _isNeutered,
        allergies: _selectedAllergies,
        medications: [],
        veterinarian: '',
        veterinaryClinic: '',
        vaccinations: [],
      ),
      ownerInfo: PetOwnerInfo(
        name: '',
        phone: '',
        email: '',
        address: '',
        emergencyContact: '',
        emergencyPhone: '',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 保存档案并返回
    Navigator.pop(context, profile);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${profile.name}的档案创建成功！'),
        backgroundColor: NothingTheme.success,
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}