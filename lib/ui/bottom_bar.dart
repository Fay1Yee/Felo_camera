import 'package:flutter/material.dart';
import '../models/mode.dart';
import '../config/nothing_theme.dart';
import '../config/device_config.dart';

class BottomBar extends StatelessWidget {
  final Mode current;
  final ValueChanged<Mode> onModeChanged;
  final VoidCallback onShutter;
  final VoidCallback? onCameraSwitch; // 添加摄像头切换回调
  final VoidCallback? onGallerySelect; // 添加相册选择回调

  const BottomBar({
    super.key,
    required this.current,
    required this.onModeChanged,
    required this.onShutter,
    this.onCameraSwitch, // 可选参数
    this.onGallerySelect, // 可选参数
  });

  Widget _modeChip(BuildContext context, Mode mode, String label) {
    final selected = current == mode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = DeviceConfig.isTablet(context);
    
    // 根据设备类型调整芯片大小
    final chipPadding = isTablet 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    
    final fontSize = isTablet ? NothingTheme.fontSizeBody : NothingTheme.fontSizeCaption;
    
    return Container(
      decoration: BoxDecoration(
        color: selected 
            ? NothingTheme.yellowAlpha20
            : NothingTheme.whiteAlpha10,
        borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
        border: Border.all(
          color: selected 
              ? NothingTheme.nothingYellow
              : NothingTheme.grayAlpha30,
          width: 1.5,
        ),
        boxShadow: selected ? [
          BoxShadow(
            color: NothingTheme.yellowAlpha30,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: NothingTheme.blackAlpha20,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(NothingTheme.radiusLarge),
          onTap: () => onModeChanged(mode),
          child: Padding(
            padding: chipPadding,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? NothingTheme.nothingYellow : NothingTheme.nothingWhite,
                fontSize: fontSize,
                fontWeight: selected ? NothingTheme.fontWeightMedium : NothingTheme.fontWeightRegular,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = DeviceConfig.isTablet(context);
    
    // 根据设备类型调整底部栏高度和间距
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final containerPadding = isTablet 
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    
    // 调整快门按钮大小
    final shutterButtonSize = isTablet ? 28.0 : 24.0;
    final shutterButtonPadding = isTablet ? 20.0 : 16.0;
    
    return Container(
      padding: containerPadding.copyWith(bottom: containerPadding.bottom + bottomPadding),
      decoration: BoxDecoration(
        color: NothingTheme.blackAlpha90,
        border: Border(
          top: BorderSide(
            color: NothingTheme.whiteAlpha10,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: NothingTheme.blackAlpha30,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: isTablet || screenWidth > 600
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 左侧按钮组
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 相册选择按钮
                      if (onGallerySelect != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NothingTheme.whiteAlpha10,
                            border: Border.all(
                              color: NothingTheme.grayAlpha30,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: NothingTheme.blackAlpha20,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: onGallerySelect,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.photo_library,
                                  color: NothingTheme.nothingWhite,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (onGallerySelect != null && onCameraSwitch != null) 
                        const SizedBox(width: NothingTheme.spacingSmall),
                      // 摄像头切换按钮
                      if (onCameraSwitch != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NothingTheme.whiteAlpha10,
                            border: Border.all(
                              color: NothingTheme.grayAlpha30,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: NothingTheme.blackAlpha20,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: onCameraSwitch,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.flip_camera_ios,
                                  color: NothingTheme.nothingWhite,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 模式选择器
                  Expanded(
                    child: Wrap(
                      spacing: NothingTheme.spacingMedium,
                      runSpacing: NothingTheme.spacingSmall,
                      children: [
                        _modeChip(context, Mode.normal, '普通'),
                        _modeChip(context, Mode.pet, '宠物'),
                        _modeChip(context, Mode.health, '健康'),
                        _modeChip(context, Mode.travel, '出行箱'),
                      ],
                    ),
                  ),
                  const SizedBox(width: NothingTheme.spacingLarge),
                  // 快门按钮
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: NothingTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: NothingTheme.yellowAlpha30,
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: NothingTheme.yellowAlpha20,
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: onShutter,
                        child: Padding(
                          padding: EdgeInsets.all(shutterButtonPadding),
                          child: Icon(
                            Icons.camera_alt,
                            color: NothingTheme.nothingBlack,
                            size: shutterButtonSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 模式选择器和摄像头切换按钮行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 相册选择按钮
                      if (onGallerySelect != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NothingTheme.nothingBlack.withValues(alpha: 0.3),
                            border: Border.all(
                              color: NothingTheme.nothingWhite.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: onGallerySelect,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.photo_library,
                                  color: NothingTheme.nothingWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (onGallerySelect != null) const SizedBox(width: NothingTheme.spacingSmall),
                      // 摄像头切换按钮
                      if (onCameraSwitch != null)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NothingTheme.nothingBlack.withValues(alpha: 0.3),
                            border: Border.all(
                              color: NothingTheme.nothingWhite.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: onCameraSwitch,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.flip_camera_ios,
                                  color: NothingTheme.nothingWhite,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (onCameraSwitch != null) const SizedBox(width: NothingTheme.spacingSmall),
                      // 模式选择器
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: NothingTheme.spacingSmall,
                          runSpacing: NothingTheme.spacingSmall,
                          children: [
                            _modeChip(context, Mode.normal, '普通'),
                            _modeChip(context, Mode.pet, '宠物'),
                            _modeChip(context, Mode.health, '健康'),
                            _modeChip(context, Mode.travel, '出行箱'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NothingTheme.spacingMedium),
                  // 快门按钮
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            NothingTheme.nothingYellow,
                            NothingTheme.nothingYellow.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NothingTheme.nothingYellow.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: onShutter,
                          child: Padding(
                            padding: EdgeInsets.all(shutterButtonPadding),
                            child: Icon(
                              Icons.camera_alt,
                              color: NothingTheme.nothingBlack,
                              size: shutterButtonSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}