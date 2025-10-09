#!/bin/bash

# Pet Camera Demo - 一键部署脚本
# 用于快速部署APK到Nothing Phone

echo "🔧 配置ADB环境..."
export PATH=$PATH:/Users/zephyruszhou/Library/Android/sdk/platform-tools

echo "📱 检查设备连接..."
DEVICE_COUNT=$(adb devices | grep -v "List of devices attached" | grep -c "device")

if [ $DEVICE_COUNT -eq 0 ]; then
    echo "❌ 未检测到连接的设备"
    echo "请确保："
    echo "1. 手机已通过USB连接到电脑"
    echo "2. 手机已开启开发者选项和USB调试"
    echo "3. 已授权此电脑进行调试"
    echo ""
    echo "当前连接的设备："
    adb devices
    exit 1
fi

echo "✅ 检测到 $DEVICE_COUNT 个设备"
adb devices

echo "📦 安装APK..."
APK_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
echo "APK大小: $APK_SIZE"

adb install -r build/app/outputs/flutter-apk/app-release.apk

if [ $? -eq 0 ]; then
    echo "🚀 启动应用..."
    adb shell am start -n com.example.pet_camera_demo/.MainActivity
    echo "✅ 部署完成! Pet Camera Demo已成功安装并启动"
    
    echo ""
    echo "📋 应用信息:"
    echo "- 包名: com.example.pet_camera_demo"
    echo "- APK大小: $APK_SIZE"
    echo "- 支持架构: ARM64"
    echo "- 最低Android版本: 5.0 (API 21)"
    echo ""
    echo "🔍 如需查看应用日志:"
    echo "adb logcat | grep pet_camera_demo"
    echo ""
    echo "📱 应用已在设备上启动，请检查相机和AI识别功能"
else
    echo "❌ APK安装失败，请检查设备连接和权限设置"
    echo "常见解决方案："
    echo "1. 确保手机已开启'允许安装未知来源应用'"
    echo "2. 检查存储空间是否充足"
    echo "3. 尝试先卸载旧版本应用"
    exit 1
fi