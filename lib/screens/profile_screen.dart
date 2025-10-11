import 'package:flutter/material.dart';
import '../models/pet_profile.dart';
import '../widgets/pet_id_card.dart';
import '../widgets/profile_management_section.dart';
import '../widgets/personality_tags_section.dart';
import 'health_screen.dart';
import 'habits_detail_screen.dart';
import 'life_records_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // 模拟宠物数据
  final PetProfile _petProfile = PetProfile(
    id: 'pet_001',
    name: '小白',
    type: '猫',
    breed: '田园猫',
    gender: '母',
    birthDate: DateTime(2022, 3, 15),
    weight: 4.2,
    color: '白色',
    avatarUrl: 'assets/images/pet_avatar.png',
    chipId: 'CH001234567',
    registrationNumber: 'REG2024001',
    personalityTags: ['超级黏人', '好奇宝宝', '爱撒娇', '胆小', '活泼', '聪明'],
    healthInfo: PetHealthInfo(
      isNeutered: true,
      allergies: [],
      medications: [],
      veterinarian: '张医生',
      veterinaryClinic: '爱宠医院',
      vaccinations: [],
    ),
    ownerInfo: PetOwnerInfo(
      name: '主人',
      phone: '13800138000',
      email: 'owner@example.com',
      address: '北京市朝阳区',
      emergencyContact: '紧急联系人',
      emergencyPhone: '13900139000',
    ),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 宠物身份证
          PetIdCard(
            petProfile: _petProfile,
            onTap: () {
              // 处理身份证点击事件
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('宠物身份证被点击')),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 性格特征
          PersonalityTagsSection(
            personalityTags: _petProfile.personalityTags,
          ),
          
          const SizedBox(height: 24),
          
          // 档案管理
          ProfileManagementSection(
            onEditProfile: () => _showEditDialog(context),
            onHealthRecords: () => _navigateToHealthRecords(context),
            onHabitsAnalysis: () => _navigateToHabitsAnalysis(context),
            onLifeRecords: () => _navigateToLifeRecords(context),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑档案'),
        content: const Text('编辑功能正在开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _navigateToHealthRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthScreen(),
      ),
    );
  }

  void _navigateToHabitsAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitsDetailScreen(),
      ),
    );
  }

  void _navigateToLifeRecords(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LifeRecordsScreen(),
      ),
    );
  }
}