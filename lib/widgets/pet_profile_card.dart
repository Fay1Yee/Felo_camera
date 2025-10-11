import 'package:flutter/material.dart';
import '../config/nothing_theme.dart';
import '../models/pet_profile.dart';

class PetProfileCard extends StatelessWidget {
  final PetProfile pet;
  final VoidCallback? onTap;

  const PetProfileCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              NothingTheme.brandPrimary,
              NothingTheme.brandSecondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(NothingTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: NothingTheme.blackAlpha10,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 宠物头像
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: NothingTheme.whiteAlpha20,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: NothingTheme.whiteAlpha20,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: pet.avatarUrl.isNotEmpty
                    ? Image.asset(
                        pet.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: 30,
                            color: NothingTheme.textInverse,
                          );
                        },
                      )
                    : Icon(
                        Icons.pets,
                        size: 30,
                        color: NothingTheme.textInverse,
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 宠物信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: NothingTheme.textInverse,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: NothingTheme.whiteAlpha20,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pet.gender,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NothingTheme.textInverse,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                      '${pet.breed} · ${_getAge()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: NothingTheme.textInverse.withOpacity(0.9),
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // 个性标签
                  if (pet.personalityTags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: pet.personalityTags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NothingTheme.whiteAlpha20,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: NothingTheme.textInverse,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            
            // 箭头图标
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: NothingTheme.textInverse.withOpacity(0.7),
              ),
          ],
        ),
      ),
    );
  }

  String _getAge() {
    final now = DateTime.now();
    final age = now.difference(pet.birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return '${years}岁${months > 0 ? '${months}个月' : ''}';
    } else {
      return '${months}个月';
    }
  }
}