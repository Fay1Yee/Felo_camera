import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// 权限管理服务
/// 处理应用所需的各种权限请求和状态检查
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  static PermissionManager get instance => _instance;

  /// 检查并请求存储权限
  /// 适配Android 13+的新权限模型
  Future<bool> requestStoragePermissions({BuildContext? context}) async {
    // Web平台不需要权限请求
    if (kIsWeb) {
      return true;
    }
    
    if (!Platform.isAndroid) {
      return true; // iOS不需要显式请求存储权限
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      List<Permission> permissionsToRequest = [];

      // Android 13+ (API 33+) 使用新的权限模型
      if (sdkInt >= 33) {
        permissionsToRequest.addAll([
          Permission.photos,
          Permission.videos,
          Permission.audio,
          // 对于文档访问，使用 manageExternalStorage 或 storage
          Permission.manageExternalStorage,
        ]);
      } 
      // Android 11-12 (API 30-32)
      else if (sdkInt >= 30) {
        permissionsToRequest.addAll([
          Permission.storage,
          Permission.manageExternalStorage,
        ]);
      }
      // Android 10及以下 (API 29-)
      else {
        permissionsToRequest.addAll([
          Permission.storage,
        ]);
      }

      // 检查当前权限状态
      Map<Permission, PermissionStatus> statuses = {};
      for (Permission permission in permissionsToRequest) {
        statuses[permission] = await permission.status;
      }

      // 过滤出需要请求的权限
      List<Permission> needRequest = [];
      for (Permission permission in permissionsToRequest) {
        final status = statuses[permission]!;
        if (status.isDenied || status.isRestricted) {
          needRequest.add(permission);
        }
      }

      if (needRequest.isEmpty) {
        return true; // 所有权限都已授予
      }

      // 显示权限说明对话框
      if (context != null && context.mounted) {
        final shouldRequest = await _showPermissionDialog(context, needRequest);
        if (!shouldRequest) {
          return false;
        }
      }

      // 请求权限
      Map<Permission, PermissionStatus> results = await needRequest.request();

      // 检查结果
      bool allGranted = true;
      List<Permission> deniedPermissions = [];
      List<Permission> permanentlyDeniedPermissions = [];

      for (Permission permission in needRequest) {
        final status = results[permission]!;
        if (status.isDenied) {
          allGranted = false;
          deniedPermissions.add(permission);
        } else if (status.isPermanentlyDenied) {
          allGranted = false;
          permanentlyDeniedPermissions.add(permission);
        }
      }

      // 处理被拒绝的权限
      if (!allGranted && context != null && context.mounted) {
        await _handleDeniedPermissions(
          context, 
          deniedPermissions, 
          permanentlyDeniedPermissions
        );
      }

      return allGranted;
    } catch (e) {
      debugPrint('权限请求失败: $e');
      return false;
    }
  }

  /// 检查相机权限
  Future<bool> requestCameraPermission({BuildContext? context}) async {
    // Web平台不需要权限请求
    if (kIsWeb) {
      return true;
    }
    
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      if (context != null && context.mounted) {
        final shouldRequest = await _showCameraPermissionDialog(context);
        if (!shouldRequest) {
          return false;
        }
      }

      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied && context != null && context.mounted) {
      await _showSettingsDialog(context, '相机权限');
      return false;
    }

    return false;
  }

  /// 显示权限说明对话框
  Future<bool> _showPermissionDialog(BuildContext context, List<Permission> permissions) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 8),
            Text('权限请求'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '为了正常使用文件导入功能，需要以下权限：',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...permissions.map((permission) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_getPermissionDescription(permission))),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '这些权限仅用于访问您选择的文件，不会收集或上传任何个人数据。',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('授予权限'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示相机权限对话框
  Future<bool> _showCameraPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.blue),
            SizedBox(width: 8),
            Text('相机权限'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '需要相机权限来拍摄照片进行AI分析。',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              '拍摄的照片仅用于AI分析，不会被存储或上传。',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('授予权限'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 处理被拒绝的权限
  Future<void> _handleDeniedPermissions(
    BuildContext context,
    List<Permission> deniedPermissions,
    List<Permission> permanentlyDeniedPermissions,
  ) async {
    if (permanentlyDeniedPermissions.isNotEmpty) {
      await _showSettingsDialog(context, '存储权限');
    } else if (deniedPermissions.isNotEmpty) {
      await _showRetryDialog(context, deniedPermissions);
    }
  }

  /// 显示设置对话框
  Future<void> _showSettingsDialog(BuildContext context, String permissionName) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange),
            const SizedBox(width: 8),
            Text('需要$permissionName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$permissionName已被永久拒绝，请在设置中手动开启。'),
            const SizedBox(height: 12),
            const Text(
              '操作步骤：\n1. 点击"前往设置"\n2. 找到"权限"或"应用权限"\n3. 开启所需权限',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('前往设置'),
          ),
        ],
      ),
    );
  }

  /// 显示重试对话框
  Future<void> _showRetryDialog(BuildContext context, List<Permission> permissions) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('权限被拒绝'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('没有相应权限，部分功能可能无法正常使用。'),
            SizedBox(height: 12),
            Text(
              '您可以稍后在设置中手动开启权限，或者重新尝试授权。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              requestStoragePermissions(context: context);
            },
            child: const Text('重新授权'),
          ),
        ],
      ),
    );
  }

  /// 获取权限描述
  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return '访问设备存储（读取文件）';
      case Permission.manageExternalStorage:
        return '管理外部存储（访问所有文件）';
      case Permission.photos:
        return '访问照片和图片';
      case Permission.videos:
        return '访问视频文件';
      case Permission.audio:
        return '访问音频文件';
      case Permission.camera:
        return '使用相机拍照';
      default:
        return '未知权限';
    }
  }

  /// 检查是否有存储权限
  Future<bool> hasStoragePermission() async {
    // Web平台不需要权限检查
    if (kIsWeb) {
      return true;
    }
    
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13+
        return await Permission.photos.isGranted ||
               await Permission.manageExternalStorage.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12
        return await Permission.storage.isGranted ||
               await Permission.manageExternalStorage.isGranted;
      } else {
        // Android 10及以下
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      debugPrint('检查存储权限失败: $e');
      return false;
    }
  }

  /// 检查是否有相机权限
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
}