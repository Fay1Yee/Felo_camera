import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/nothing_theme.dart';
import '../widgets/nothing_button.dart';
import '../widgets/nothing_card.dart';
import '../services/permission_manager.dart';

class PermissionTestScreen extends StatefulWidget {
  const PermissionTestScreen({super.key});

  @override
  State<PermissionTestScreen> createState() => _PermissionTestScreenState();
}

class _PermissionTestScreenState extends State<PermissionTestScreen> {
  final PermissionManager _permissionManager = PermissionManager();
  
  Map<Permission, PermissionStatus> _permissionStatuses = {};
  bool _isLoading = false;

  final List<Permission> _testPermissions = [
    Permission.camera,
    Permission.storage,
    Permission.photos,
    Permission.videos,
    Permission.manageExternalStorage,
  ];

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);
    
    try {
      Map<Permission, PermissionStatus> statuses = {};
      for (Permission permission in _testPermissions) {
        statuses[permission] = await permission.status;
      }
      
      setState(() {
        _permissionStatuses = statuses;
      });
    } catch (e) {
      _showErrorSnackBar('检查权限状态失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestStoragePermissions() async {
    setState(() => _isLoading = true);
    
    try {
      bool granted = await _permissionManager.requestStoragePermissions();
      
      if (granted) {
        _showSuccessSnackBar('存储权限已授予');
        await _checkAllPermissions();
      } else {
        _showErrorSnackBar('存储权限被拒绝');
      }
    } catch (e) {
      _showErrorSnackBar('请求存储权限失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _isLoading = true);
    
    try {
      PermissionStatus status = await Permission.camera.request();
      
      if (status.isGranted) {
        _showSuccessSnackBar('相机权限已授予');
        await _checkAllPermissions();
      } else {
        _showErrorSnackBar('相机权限被拒绝');
      }
    } catch (e) {
      _showErrorSnackBar('请求相机权限失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await openAppSettings();
      _showInfoSnackBar('已打开应用设置，请手动授予权限后返回');
    } catch (e) {
      _showErrorSnackBar('打开设置失败: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NothingTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NothingTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: NothingTheme.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '相机权限';
      case Permission.storage:
        return '存储权限';
      case Permission.photos:
        return '照片权限';
      case Permission.videos:
        return '视频权限';
      case Permission.manageExternalStorage:
        return '外部存储管理权限';
      default:
        return permission.toString();
    }
  }

  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '用于拍摄照片和录制视频';
      case Permission.storage:
        return '用于读取和写入设备存储';
      case Permission.photos:
        return '用于访问设备中的照片';
      case Permission.videos:
        return '用于访问设备中的视频';
      case Permission.manageExternalStorage:
        return '用于管理外部存储文件';
      default:
        return '应用功能所需权限';
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return NothingTheme.success;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        return NothingTheme.error;
      case PermissionStatus.restricted:
        return NothingTheme.warning;
      default:
        return NothingTheme.textSecondary;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授予';
      case PermissionStatus.denied:
        return '已拒绝';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      default:
        return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NothingTheme.background,
      appBar: AppBar(
        title: const Text(
          '权限管理',
          style: TextStyle(
            color: NothingTheme.textPrimary,
            fontWeight: NothingTheme.fontWeightMedium,
          ),
        ),
        backgroundColor: NothingTheme.surface,
        foregroundColor: NothingTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _checkAllPermissions,
            tooltip: '刷新权限状态',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(NothingTheme.brandPrimary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(NothingTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 权限状态概览
                  NothingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '权限状态概览',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeHeadline,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: NothingTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: NothingTheme.spacingMedium),
                        ..._testPermissions.map((permission) {
                          final status = _permissionStatuses[permission] ?? PermissionStatus.denied;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: NothingTheme.spacingSmall),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: NothingTheme.spacingSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getPermissionName(permission),
                                        style: const TextStyle(
                                          fontSize: NothingTheme.fontSizeBody,
                                          fontWeight: NothingTheme.fontWeightMedium,
                                          color: NothingTheme.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        _getPermissionDescription(permission),
                                        style: const TextStyle(
                                          fontSize: NothingTheme.fontSizeCaption,
                                          color: NothingTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: NothingTheme.spacingSmall,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(NothingTheme.radiusSm),
                                  ),
                                  child: Text(
                                    _getStatusText(status),
                                    style: TextStyle(
                                      fontSize: NothingTheme.fontSizeCaption,
                                      fontWeight: NothingTheme.fontWeightMedium,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: NothingTheme.spacingLarge),
                  
                  // 权限操作按钮
                  NothingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '权限操作',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeHeadline,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: NothingTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: NothingTheme.spacingMedium),
                        
                        NothingButton(
                          text: '请求存储权限',
                          onPressed: _isLoading ? null : _requestStoragePermissions,
                          type: NothingButtonType.primary,
                          fullWidth: true,
                          loading: _isLoading,
                        ),
                        
                        const SizedBox(height: NothingTheme.spacingSmall),
                        
                        NothingButton(
                          text: '请求相机权限',
                          onPressed: _isLoading ? null : _requestCameraPermission,
                          type: NothingButtonType.secondary,
                          fullWidth: true,
                          loading: _isLoading,
                        ),
                        
                        const SizedBox(height: NothingTheme.spacingSmall),
                        
                        NothingButton(
                          text: '打开应用设置',
                          onPressed: _openAppSettings,
                          type: NothingButtonType.outline,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: NothingTheme.spacingLarge),
                  
                  // 使用说明
                  NothingCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '使用说明',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeHeadline,
                            fontWeight: NothingTheme.fontWeightMedium,
                            color: NothingTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: NothingTheme.spacingMedium),
                        const Text(
                          '1. 点击"请求存储权限"来获取文档分析所需的存储访问权限\n'
                          '2. 点击"请求相机权限"来获取拍照功能所需的相机权限\n'
                          '3. 如果权限被永久拒绝，请点击"打开应用设置"手动授予权限\n'
                          '4. 授予权限后，您就可以正常使用文档分析和拍照功能了',
                          style: TextStyle(
                            fontSize: NothingTheme.fontSizeBody,
                            color: NothingTheme.textSecondary,
                            height: 1.5,
                          ),
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