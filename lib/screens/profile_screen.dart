import 'package:flutter/material.dart';
import '../models/pet_profile.dart';
import '../widgets/pet_id_card.dart';
import '../widgets/profile_management_section.dart';
import '../widgets/personality_tags_section.dart';
import '../utils/responsive_helper.dart';
import 'health_screen.dart';
import 'habits_detail_screen.dart';
import 'life_records_screen.dart';
import 'personality_analysis_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  // 模拟宠物数据 - 基于布偶猫图片特征
  final PetProfile _petProfile = PetProfile(
    id: 'pet_001',
    name: '泡泡',
    type: '猫',
    breed: '布偶猫',
    gender: '母',
    birthDate: DateTime(2022, 3, 20),
    weight: 5.2,
    color: '纯白色长毛',
    avatarUrl: 'assets/images/pet_photo.jpg',
    chipId: 'CH001234567',
    registrationNumber: 'REG2024001',
    personalityTags: ['温和安静', '眼神温顺', '亲人型', '温柔可亲', '优雅贵族'],
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
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 20,
          tablet: 32,
          desktop: 48,
        ),
      ),
      child: ResponsiveContainer(
        mobilePadding: EdgeInsets.zero,
        tabletPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        desktopPadding: const EdgeInsets.symmetric(horizontal: 48.0),
        mobileMaxWidth: double.infinity,
        tabletMaxWidth: 800,
        desktopMaxWidth: 1000,
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
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          
          // 性格特征
          PersonalityTagsSection(
            personalityTags: _petProfile.personalityTags,
          ),
          
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          
          // 档案管理
          ProfileManagementSection(
            onEditProfile: () => _showEditDialog(context),
            onPersonalityAnalysis: () => _navigateToPersonalityAnalysis(context),
            onHealthRecords: () => _navigateToHealthRecords(context),
            onHabitsAnalysis: () => _navigateToHabitsAnalysis(context),
            onLifeRecords: () => _navigateToLifeRecords(context),
          ),
          ],
        ),
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

  void _navigateToPersonalityAnalysis(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalityAnalysisScreen(
          petId: _petProfile.id,
          petName: _petProfile.name,
          activities: const [], // 可以从宠物档案中获取活动数据
        ),
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