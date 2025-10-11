import 'package:flutter/material.dart';
import '../../config/nothing_theme.dart';
import '../../models/pet_profile.dart';

class ProfileFillingScreen extends StatefulWidget {
  final PetProfile? existingProfile;

  const ProfileFillingScreen({
    super.key,
    this.existingProfile,
  });

  @override
  State<ProfileFillingScreen> createState() => _ProfileFillingScreenState();
}

class _ProfileFillingScreenState extends State<ProfileFillingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 表单控制器
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _chipIdController = TextEditingController();
  final _registrationController = TextEditingController();
  final _veterinarianController = TextEditingController();
  final _clinicController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  // 表单数据
  String _selectedType = 'cat';
  String _selectedGender = 'male';
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365));
  bool _isNeutered = false;
  List<String> _selectedPersonalities = [];
  List<String> _selectedAllergies = [];
  List<String> _selectedMedications = [];

  // 可选项
  final List<String> _personalityOptions = [
    '活泼', '安静', '友好', '独立', '粘人', '胆小', '勇敢', '聪明',
    '顽皮', '温顺', '警觉', '懒惰', '好奇', '害羞', '社交', '护主'
  ];

  final List<String> _allergyOptions = [
    '花粉', '尘螨', '某些食物', '化学清洁剂', '香水', '烟雾',
    '特定蛋白质', '海鲜', '牛肉', '鸡肉', '谷物', '乳制品'
  ];

  final List<String> _medicationOptions = [
    '驱虫药', '心丝虫预防药', '关节保健品', '维生素', '益生菌',
    '皮肤药膏', '眼药水', '耳朵清洁剂', '口腔护理', '消炎药'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExistingProfile();
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

  void _loadExistingProfile() {
    if (widget.existingProfile != null) {
      final profile = widget.existingProfile!;
      _nameController.text = profile.name;
      _breedController.text = profile.breed;
      _weightController.text = profile.weight.toString();
      _colorController.text = profile.color;
      _chipIdController.text = profile.chipId;
      _registrationController.text = profile.registrationNumber;
      _veterinarianController.text = profile.healthInfo.veterinarian;
      _clinicController.text = profile.healthInfo.veterinaryClinic;
      _ownerNameController.text = profile.ownerInfo.name;
      _ownerPhoneController.text = profile.ownerInfo.phone;
      _ownerEmailController.text = profile.ownerInfo.email;
      _ownerAddressController.text = profile.ownerInfo.address;
      _emergencyContactController.text = profile.ownerInfo.emergencyContact;
      _emergencyPhoneController.text = profile.ownerInfo.emergencyPhone;

      _selectedType = profile.type;
      _selectedGender = profile.gender;
      _birthDate = profile.birthDate;
      _isNeutered = profile.healthInfo.isNeutered;
      _selectedPersonalities = List.from(profile.personalityTags);
      _selectedAllergies = List.from(profile.healthInfo.allergies);
      _selectedMedications = List.from(profile.healthInfo.medications);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _chipIdController.dispose();
    _registrationController.dispose();
    _veterinarianController.dispose();
    _clinicController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _ownerAddressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _notesController.dispose();
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
        title: Text(
          widget.existingProfile != null ? '编辑档案' : '完善档案',
          style: const TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              '保存',
              style: TextStyle(
                color: _isLoading ? NothingTheme.gray400 : NothingTheme.info,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildHealthInfoSection(),
          const SizedBox(height: 24),
          _buildOwnerInfoSection(),
          const SizedBox(height: 24),
          _buildPersonalitySection(),
          const SizedBox(height: 24),
          _buildAllergySection(),
          const SizedBox(height: 24),
          _buildMedicationSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
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
              const Text(
                '基本信息',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('宠物姓名', _nameController, '请输入宠物姓名'),
          const SizedBox(height: 16),
          _buildTextField('品种', _breedController, '请输入品种'),
          const SizedBox(height: 16),
          _buildTextField('体重 (kg)', _weightController, '请输入体重', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField('毛色', _colorController, '请输入毛色'),
          const SizedBox(height: 16),
          _buildTextField('芯片ID', _chipIdController, '请输入芯片ID'),
          const SizedBox(height: 16),
          _buildTextField('登记号', _registrationController, '请输入登记号'),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildGenderSelector(),
          const SizedBox(height: 16),
          _buildNeuteredSwitch(),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection() {
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
                  color: NothingTheme.success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '健康信息',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('兽医姓名', _veterinarianController, '请输入兽医姓名'),
          const SizedBox(height: 16),
          _buildTextField('兽医诊所', _clinicController, '请输入兽医诊所'),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoSection() {
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
                  color: NothingTheme.brandAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '主人信息',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('主人姓名', _ownerNameController, '请输入主人姓名'),
          const SizedBox(height: 16),
          _buildTextField('联系电话', _ownerPhoneController, '请输入联系电话', keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField('邮箱', _ownerEmailController, '请输入邮箱', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField('地址', _ownerAddressController, '请输入地址'),
          const SizedBox(height: 16),
          _buildTextField('紧急联系人', _emergencyContactController, '请输入紧急联系人'),
          const SizedBox(height: 16),
          _buildTextField('紧急联系电话', _emergencyPhoneController, '请输入紧急联系电话', keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildPersonalitySection() {
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
                  color: NothingTheme.accentPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '性格特征',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _personalityOptions.map((personality) {
              final isSelected = _selectedPersonalities.contains(personality);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPersonalities.remove(personality);
                    } else {
                      _selectedPersonalities.add(personality);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? NothingTheme.accentPrimary.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? NothingTheme.accentPrimary : NothingTheme.gray300,
                    ),
                  ),
                  child: Text(
                    personality,
                    style: TextStyle(
                      color: isSelected ? NothingTheme.accentPrimary : NothingTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergySection() {
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
                  color: NothingTheme.warning,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '过敏信息',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergyOptions.map((allergy) {
              final isSelected = _selectedAllergies.contains(allergy);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAllergies.remove(allergy);
                    } else {
                      _selectedAllergies.add(allergy);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? NothingTheme.warning.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? NothingTheme.warning : NothingTheme.gray300,
                    ),
                  ),
                  child: Text(
                    allergy,
                    style: TextStyle(
                      color: isSelected ? NothingTheme.warning : NothingTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection() {
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
                  color: NothingTheme.error,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '用药信息',
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _medicationOptions.map((medication) {
              final isSelected = _selectedMedications.contains(medication);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMedications.remove(medication);
                    } else {
                      _selectedMedications.add(medication);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? NothingTheme.error.withOpacity(0.1) : NothingTheme.gray100,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? NothingTheme.error : NothingTheme.gray300,
                    ),
                  ),
                  child: Text(
                    medication,
                    style: TextStyle(
                      color: isSelected ? NothingTheme.error : NothingTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: NothingTheme.gray400,
              fontSize: 14,
            ),
            filled: true,
            fillColor: NothingTheme.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: const BorderSide(color: NothingTheme.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: const BorderSide(color: NothingTheme.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              borderSide: const BorderSide(color: NothingTheme.info, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '出生日期',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _birthDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _birthDate = date;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: NothingTheme.gray50,
              borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
              border: Border.all(color: NothingTheme.gray300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_birthDate.year}-${_birthDate.month.toString().padLeft(2, '0')}-${_birthDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: NothingTheme.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'male' ? Colors.blue.withOpacity(0.1) : NothingTheme.gray50,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                    border: Border.all(
                      color: _selectedGender == 'male' ? Colors.blue : NothingTheme.gray300,
                      width: _selectedGender == 'male' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        color: _selectedGender == 'male' ? Colors.blue : NothingTheme.gray400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'female';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'female' ? Colors.pink.withOpacity(0.1) : NothingTheme.gray50,
                    borderRadius: BorderRadius.circular(NothingTheme.radiusMd),
                    border: Border.all(
                      color: _selectedGender == 'female' ? Colors.pink : NothingTheme.gray300,
                      width: _selectedGender == 'female' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        color: _selectedGender == 'female' ? Colors.pink : NothingTheme.gray400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
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
      ],
    );
  }

  Widget _buildNeuteredSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '是否绝育',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
    );
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入宠物姓名')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟保存过程
      await Future.delayed(const Duration(seconds: 1));

      final profile = PetProfile(
        id: widget.existingProfile?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        breed: _breedController.text,
        gender: _selectedGender,
        birthDate: _birthDate,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        color: _colorController.text,
        avatarUrl: widget.existingProfile?.avatarUrl ?? '',
        chipId: _chipIdController.text,
        registrationNumber: _registrationController.text,
        personalityTags: _selectedPersonalities,
        healthInfo: PetHealthInfo(
          isNeutered: _isNeutered,
          allergies: _selectedAllergies,
          medications: _selectedMedications,
          veterinarian: _veterinarianController.text,
          veterinaryClinic: _clinicController.text,
          vaccinations: widget.existingProfile?.healthInfo.vaccinations ?? [],
        ),
        ownerInfo: PetOwnerInfo(
          name: _ownerNameController.text,
          phone: _ownerPhoneController.text,
          email: _ownerEmailController.text,
          address: _ownerAddressController.text,
          emergencyContact: _emergencyContactController.text,
          emergencyPhone: _emergencyPhoneController.text,
        ),
        createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.pop(context, profile);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('档案保存成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}