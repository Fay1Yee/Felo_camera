import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';
import '../widgets/pet_profile_card.dart';
import '../widgets/scenario_selector.dart';
import '../widgets/enhanced_scenario_selector.dart';
import '../widgets/enhanced_device_control_panel.dart';
import '../widgets/enhanced_data_visualization.dart';
import '../widgets/today_status_card.dart';
import '../widgets/pet_personality_cloud.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/daily_tasks_widget.dart';
import '../widgets/health_overview_widget.dart';
import '../widgets/recent_activities_widget.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScenarioMode _currentScenario = ScenarioMode.home;

  // 模拟数据
  final PetProfile _currentPet = PetProfile(
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
    personalityTags: ['超级黏人', '好奇宝宝', '爱撒娇', '胆小'],
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
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NothingTheme.background,
      child: CustomScrollView(
        slivers: [
          // 宠物档案卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PetProfileCard(
                pet: _currentPet,
                onTap: () {
                  // 跳转到详细档案页面
                },
              ),
            ),
          ),

          // 场景选择器
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: EnhancedScenarioSelector(
                currentScenario: _currentScenario,
                onScenarioChanged: (mode) {
                  setState(() {
                    _currentScenario = mode;
                  });
                },
              ),
            ),
          ),

          // 今日状态卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TodayStatusCard(
                status: PetTodayStatus.getMockData(),
                onTap: () {
                  // 跳转到详细状态页面
                },
              ),
            ),
          ),

          // 宠物性格词云
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: PetPersonalityCloud(
                traits: PersonalityTrait.getDefaultTraits(),
                onTraitTap: () {
                  // 处理性格特征点击
                },
              ),
            ),
          ),

          // 快捷功能网格
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuickActionsGrid(
                onActionTap: (actionType) {
                  _handleQuickAction(actionType);
                },
              ),
            ),
          ),

          // 内容区域 - Tab视图
          SliverFillRemaining(
            child: Container(
              margin: const EdgeInsets.all(16.0),
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
                  // Tab栏
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: NothingTheme.gray200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: NothingTheme.textPrimary,
                      unselectedLabelColor: NothingTheme.textSecondary,
                      indicatorColor: NothingTheme.brandPrimary,
                      indicatorWeight: 2,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: const [
                        Tab(text: '今日任务'),
                        Tab(text: '健康概览'),
                        Tab(text: '设备控制'),
                        Tab(text: '数据分析'),
                        Tab(text: '最近活动'),
                      ],
                    ),
                  ),

                  // Tab内容
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // 今日任务
                        DailyTasksWidget(
                          petId: _currentPet.id,
                          scenario: _currentScenario,
                        ),

                        // 健康概览
                        HealthOverviewWidget(
                          petId: _currentPet.id,
                        ),

                        // 设备控制
                        EnhancedDeviceControlPanel(
                          currentScenario: _currentScenario,
                        ),

                        // 数据分析
                        EnhancedDataVisualization(
                          currentScenario: _currentScenario,
                        ),

                        // 最近活动
                        RecentActivitiesWidget(
                          petId: _currentPet.id,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(QuickActionType actionType) {
    switch (actionType) {
      case QuickActionType.healthRecord:
        // 跳转到健康记录页面
        break;
      case QuickActionType.reminderCenter:
        // 跳转到提醒中心页面
        break;
      case QuickActionType.lifeRecord:
        // 跳转到生活记录页面
        break;
      case QuickActionType.aiCamera:
        // 跳转到AI相机页面
        break;
      case QuickActionType.travelBox:
        // 跳转到出行箱页面
        break;
      case QuickActionType.dataAnalysis:
        // 跳转到数据分析页面
        break;
      case QuickActionType.vaccination:
        // 跳转到疫苗管理页面
        break;
      case QuickActionType.emergency:
        // 跳转到紧急联系页面
        break;
      case QuickActionType.settings:
        // 跳转到设置页面
        break;
    }
  }
}