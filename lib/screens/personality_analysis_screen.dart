import 'package:flutter/material.dart';
import '../models/pet_activity.dart';
import '../models/pet_mbti_personality.dart';
import '../services/pet_personality_analysis_service.dart';
import '../services/behavior_personality_correlation_service.dart';
import '../config/nothing_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/personality_analysis_card.dart';
import '../widgets/personality_dimension_chart.dart';
import '../widgets/behavior_pattern_list.dart';

class PersonalityAnalysisScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final List<PetActivity> activities;

  const PersonalityAnalysisScreen({
    super.key,
    required this.petId,
    required this.petName,
    required this.activities,
  });

  @override
  State<PersonalityAnalysisScreen> createState() => _PersonalityAnalysisScreenState();
}

class _PersonalityAnalysisScreenState extends State<PersonalityAnalysisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PetPersonalityAnalysisService _analysisService = PetPersonalityAnalysisService();
  
  ComprehensivePersonalityAnalysis? _analysisResult;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _performAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performAnalysis() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _analysisService.analyzePersonality(
        petId: widget.petId,
        petName: widget.petName,
        activities: widget.activities,
      );

      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        backgroundColor: NothingTheme.surface,
        elevation: 0,
        title: Text(
          '${widget.petName}的性格分析',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: NothingTheme.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: NothingTheme.textPrimary,
            ),
            onPressed: _isLoading ? null : _performAnalysis,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_analysisResult == null) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Tab栏
        Container(
          color: NothingTheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: NothingTheme.brandPrimary,
            unselectedLabelColor: NothingTheme.textSecondary,
            indicatorColor: NothingTheme.brandPrimary,
            tabs: const [
              Tab(text: '性格类型'),
              Tab(text: '维度分析'),
              Tab(text: '行为模式'),
            ],
          ),
        ),
        
        // Tab内容
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalityTypeTab(),
              _buildDimensionAnalysisTab(),
              _buildBehaviorPatternsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.brandPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            '正在分析${widget.petName}的性格特征...',
            style: TextStyle(
              color: NothingTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '这可能需要几秒钟时间',
            style: TextStyle(
              color: NothingTheme.textTertiary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: NothingTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '分析失败',
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '未知错误',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _performAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: NothingTheme.brandPrimary,
                foregroundColor: NothingTheme.textInverse,
              ),
              child: const Text('重新分析'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: NothingTheme.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无分析结果',
              style: TextStyle(
                color: NothingTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请确保有足够的活动数据进行分析',
              style: TextStyle(
                color: NothingTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTypeTab() {
    final result = _analysisResult!;
    final personality = PetMBTIDatabase.getPersonalityByType(result.personalityType);

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 24,
          desktop: 32,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 性格类型卡片
          PersonalityAnalysisCard(
            personalityType: result.personalityType,
            confidence: result.overallConfidence,
            traits: result.personalityTraits,
          ),
          
          const SizedBox(height: 24),
          
          // 详细报告
          if (result.detailedReport.isNotEmpty) ...[
            _buildSectionTitle('详细分析报告'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NothingTheme.gray200),
              ),
              child: Text(
                result.detailedReport,
                style: TextStyle(
                  color: NothingTheme.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // 建议
          if (result.recommendations.isNotEmpty) ...[
            _buildSectionTitle('个性化建议'),
            const SizedBox(height: 12),
            ...result.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: NothingTheme.brandPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDimensionAnalysisTab() {
    final result = _analysisResult!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 24,
          desktop: 32,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('性格维度得分'),
          const SizedBox(height: 16),
          
          // 维度图表
          PersonalityDimensionChart(
            dimensions: result.dimensionScores.map((key, value) => 
              MapEntry(key.displayName, value)),
          ),
          
          const SizedBox(height: 24),
          
          // 维度详细说明
          _buildSectionTitle('维度解释'),
          const SizedBox(height: 12),
          
          ...result.dimensionScores.entries.map((entry) {
            final dimension = entry.key;
            final score = entry.value;
            final percentage = ((score + 1) * 50).toStringAsFixed(1);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NothingTheme.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getDimensionName(dimension),
                        style: TextStyle(
                          color: NothingTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: NothingTheme.brandPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDimensionDescription(dimension, score),
                    style: TextStyle(
                      color: NothingTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBehaviorPatternsTab() {
    final result = _analysisResult!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        ResponsiveHelper.getResponsiveSpacing(
          context,
          mobile: 16,
          tablet: 24,
          desktop: 32,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('关键行为模式'),
          const SizedBox(height: 16),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: result.keyBehaviorPatterns.map((pattern) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pattern,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).toList(),
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('行为频率分析'),
          const SizedBox(height: 12),
          
          ...result.behaviorFrequencies.entries.map((entry) {
            final behavior = entry.key;
            final frequency = entry.value;
            final percentage = (frequency * 100).toStringAsFixed(1);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NothingTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NothingTheme.gray200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      behavior,
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: NothingTheme.brandPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // 分析统计
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NothingTheme.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NothingTheme.brandPrimary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分析统计',
                  style: TextStyle(
                    color: NothingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分析活动数量',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${result.totalActivitiesAnalyzed}条',
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分析时间',
                      style: TextStyle(
                        color: NothingTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(result.analysisDate),
                      style: TextStyle(
                        color: NothingTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: NothingTheme.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getDimensionName(PersonalityDimension dimension) {
    switch (dimension) {
      case PersonalityDimension.energyOrientation:
        return '能量导向';
      case PersonalityDimension.informationProcessing:
        return '信息处理';
      case PersonalityDimension.decisionMaking:
        return '决策方式';
      case PersonalityDimension.lifestylePreference:
        return '生活方式';
    }
  }

  String _getDimensionDescription(PersonalityDimension dimension, double score) {
    switch (dimension) {
      case PersonalityDimension.energyOrientation:
        return score > 0 ? '更倾向于外向，喜欢与外界互动' : '更倾向于内向，喜欢独处和安静';
      case PersonalityDimension.informationProcessing:
        return score > 0 ? '更依赖直觉，关注可能性和整体' : '更依赖感觉，关注具体细节和事实';
      case PersonalityDimension.decisionMaking:
        return score > 0 ? '更注重情感和价值观' : '更注重逻辑和客观分析';
      case PersonalityDimension.lifestylePreference:
        return score > 0 ? '更喜欢灵活和自发的生活方式' : '更喜欢有计划和结构化的生活方式';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}