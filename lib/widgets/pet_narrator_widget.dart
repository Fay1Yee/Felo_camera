import 'dart:async';
import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../services/pet_narrator_service.dart';
import '../models/pet_profile.dart';
import '../models/pet_activity.dart';

/// 宠物第一人称叙述组件
/// 以宠物的视角和口吻展示各种信息
class PetNarratorWidget extends StatefulWidget {
  final PetProfile petProfile;
  final String? specificMessage;
  final String? emotionalState;
  final PetActivity? recentActivity;
  final bool showTimeBasedExpression;
  final bool autoRefresh;
  final Duration refreshInterval;

  const PetNarratorWidget({
    super.key,
    required this.petProfile,
    this.specificMessage,
    this.emotionalState,
    this.recentActivity,
    this.showTimeBasedExpression = true,
    this.autoRefresh = false,
    this.refreshInterval = const Duration(minutes: 10),
  });

  @override
  State<PetNarratorWidget> createState() => _PetNarratorWidgetState();
}

class _PetNarratorWidgetState extends State<PetNarratorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final PetNarratorService _narratorService = PetNarratorService();
  String _currentMessage = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _initializeNarrator();
    
    if (widget.autoRefresh) {
      _startAutoRefresh();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(PetNarratorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.petProfile != widget.petProfile ||
        oldWidget.specificMessage != widget.specificMessage ||
        oldWidget.emotionalState != widget.emotionalState ||
        oldWidget.recentActivity != widget.recentActivity) {
      _updateMessage();
    }
  }

  void _initializeNarrator() {
    _narratorService.initialize(widget.petProfile);
    _updateMessage();
  }

  void _updateMessage() {
    setState(() {
      if (widget.specificMessage != null) {
        _currentMessage = widget.specificMessage!;
      } else if (widget.recentActivity != null) {
        _currentMessage = _narratorService.getActivityDescription(widget.recentActivity!);
      } else if (widget.emotionalState != null) {
        _currentMessage = _narratorService.getEmotionalExpression(widget.emotionalState!);
      } else if (widget.showTimeBasedExpression) {
        _currentMessage = _narratorService.getTimeBasedExpression();
      } else {
        _currentMessage = _narratorService.getRandomDailyExpression();
      }
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(widget.refreshInterval, (timer) {
      if (widget.specificMessage == null) {
        _updateMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFFFFBEA),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFFD84D).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 宠物头像和基本信息
                  Row(
                    children: [
                      // 宠物头像
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFFD84D).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: widget.petProfile.avatarUrl.isNotEmpty
                              ? Image.asset(
                                  widget.petProfile.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFFFD84D).withOpacity(0.1),
                                      child: const Icon(
                                        Icons.pets,
                                        color: Color(0xFFFFD84D),
                                        size: 24,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: const Color(0xFFFFD84D).withOpacity(0.1),
                                  child: const Icon(
                                    Icons.pets,
                                    color: Color(0xFFFFD84D),
                                    size: 24,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 宠物名字和状态
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.petProfile.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: NothingTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF7ED),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '在线',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getCurrentMood(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 刷新按钮
                      if (widget.specificMessage == null)
                        GestureDetector(
                          onTap: _updateMessage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD84D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFFFFD84D),
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 第一人称叙述内容
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD84D).withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _currentMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: NothingTheme.textPrimary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 性格标签和时间
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 性格标签
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: widget.petProfile.personalityTags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD84D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFFFD84D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // 时间戳
                      Text(
                        _formatCurrentTime(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getCurrentMood() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      return '精神饱满 · 早晨时光';
    } else if (hour >= 12 && hour < 18) {
      return '慵懒惬意 · 下午时光';
    } else if (hour >= 18 && hour < 22) {
      return '活跃玩耍 · 傍晚时光';
    } else {
      return '安静休息 · 夜晚时光';
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

/// 简化版第一人称信息卡片
class PetNarratorCard extends StatelessWidget {
  final PetProfile petProfile;
  final String message;
  final VoidCallback? onTap;

  const PetNarratorCard({
    super.key,
    required this.petProfile,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFFD84D).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFD84D).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.5),
                child: petProfile.avatarUrl.isNotEmpty
                    ? Image.asset(
                        petProfile.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFFFD84D).withOpacity(0.1),
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFFFFD84D),
                              size: 18,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFFFD84D).withOpacity(0.1),
                        child: const Icon(
                          Icons.pets,
                          color: Color(0xFFFFD84D),
                          size: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petProfile.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: NothingTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: NothingTheme.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}