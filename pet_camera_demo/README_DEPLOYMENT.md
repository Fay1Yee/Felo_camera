# Pet Camera Demo - APK部署指南

## 🎯 项目概述

Pet Camera Demo是一个基于Flutter的宠物相机应用，支持AI识别、健康检测和旅行模式。

**APK信息:**
- 文件位置: `build/app/outputs/flutter-apk/app-release.apk`
- 文件大小: 37.6MB
- 支持架构: ARM64
- 版本类型: Release (已优化)

## 🔧 环境准备

### 1. ADB工具配置

**问题**: 如果遇到 `adb: command not found` 错误

**解决方案**: 
```bash
# 1. 检查ADB是否存在
find ~/Library/Android -name "adb" 2>/dev/null

# 2. 添加ADB到PATH (临时)
export PATH=$PATH:/Users/zephyruszhou/Library/Android/sdk/platform-tools

# 3. 验证ADB可用
adb version
```

**永久配置** (可选):
```bash
# 添加到 ~/.zshrc 或 ~/.bash_profile
echo 'export PATH=$PATH:/Users/zephyruszhou/Library/Android/sdk/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

### 2. Android SDK要求

- **最低SDK版本**: API 21 (Android 5.0)
- **目标SDK版本**: API 34 (Android 14)
- **编译SDK版本**: API 34

## 📱 部署方式

### 方式一: USB连接部署 (推荐)

#### 步骤1: 设备准备
1. **连接设备**: 用USB线连接Nothing Phone到Mac
2. **启用开发者选项**:
   - 设置 → 关于手机 → 连续点击"版本号"7次
3. **启用USB调试**:
   - 设置 → 系统 → 开发者选项 → USB调试 (开启)
4. **允许计算机调试**: 在手机上点击"允许"

#### 步骤2: 验证连接
```bash
# 检查设备连接状态
adb devices

# 应该显示类似输出:
# List of devices attached
# ABC123DEF456    device
```

#### 步骤3: 安装APK
```bash
# 进入项目目录
cd /Users/zephyruszhou/Documents/Felo- camera/pet_camera_demo

# 安装APK (-r 参数允许重新安装)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

#### 步骤4: 启动应用
```bash
# 方式1: 手动在手机上找到"Pet Camera Demo"应用
# 方式2: 通过ADB启动
adb shell am start -n com.example.pet_camera_demo/.MainActivity
```

### 方式二: 文件传输安装

1. **传输APK**:
   - 将 `app-release.apk` 复制到手机存储
   - 可通过AirDrop、云盘、邮件等方式

2. **手机端安装**:
   - 在手机文件管理器中找到APK文件
   - 点击安装 (需要允许"未知来源"应用)

### 方式三: Flutter直接部署

```bash
# 确保设备已连接并被识别
adb devices

# 直接运行到设备 (会自动构建和安装)
export PUB_HOSTED_URL=https://mirrors.cloud.tencent.com/dart-pub && \
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn && \
tools/flutter/bin/flutter run --release
```

## 🚀 一键部署脚本

创建快速部署脚本:

```bash
#!/bin/bash
# deploy.sh

echo "🔧 配置ADB环境..."
export PATH=$PATH:/Users/zephyruszhou/Library/Android/sdk/platform-tools

echo "📱 检查设备连接..."
adb devices

echo "📦 安装APK..."
adb install -r build/app/outputs/flutter-apk/app-release.apk

echo "🚀 启动应用..."
adb shell am start -n com.example.pet_camera_demo/.MainActivity

echo "✅ 部署完成!"
```

使用方法:
```bash
chmod +x deploy.sh
./deploy.sh
```

## 🛠 故障排除

### 常见问题

1. **ADB未找到**
   ```bash
   # 解决方案: 添加ADB到PATH
   export PATH=$PATH:/Users/zephyruszhou/Library/Android/sdk/platform-tools
   ```

2. **设备未识别**
   ```bash
   # 检查USB调试是否开启
   # 尝试重新连接USB线
   # 检查驱动程序
   ```

3. **安装失败**
   ```bash
   # 卸载旧版本后重新安装
   adb uninstall com.example.pet_camera_demo
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

4. **权限问题**
   - 确保在手机上允许"未知来源"应用安装
   - 检查存储权限和相机权限

### 日志调试

```bash
# 查看应用日志
adb logcat | grep "pet_camera_demo"

# 查看系统日志
adb logcat

# 清除日志缓存
adb logcat -c
```

## 📋 应用功能验证

安装完成后，验证以下功能:

1. **相机功能**: 能否正常打开相机预览
2. **拍照功能**: 能否成功拍照
3. **模式切换**: 普通/健康/旅行模式切换
4. **AI识别**: 拍照后是否显示识别结果
5. **权限请求**: 相机和存储权限是否正常申请

## 🔗 相关链接

- **Web预览**: http://localhost:7357 (开发模式)
- **后端API**: http://localhost:8000 (需要启动后端服务)
- **项目仓库**: 本地开发环境

## 📞 技术支持

如遇到部署问题，请检查:
1. Android SDK是否正确安装
2. USB调试是否启用
3. 设备驱动是否正常
4. APK文件是否完整

---

**最后更新**: 2024年10月
**兼容设备**: Nothing Phone (Android 5.0+)
**开发环境**: macOS + Flutter + Android SDK