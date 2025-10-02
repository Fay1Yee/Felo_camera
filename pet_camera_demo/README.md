# Pet Camera Demo — Nothing Phone 3a

一个面向 **Nothing Phone 3a** 的 Flutter 相机 Demo，用于演示“宠物档案相机识别”的 4 种模式：
- **普通拍摄**（normal）
- **宠物识别 → 体检报告**（pet）
- **健康标记 → 眼部区域 + 可添加健康标记**（health）
- **出行箱视角 → 电量状态**（travel）

默认使用 **Mock** 分析器返回假数据；可切换到 **TFLite 本地推理** 或 **远程 API**。

---

## ✨ Features
- CameraX 预览与拍照（`camera` 插件）
- Nothing OS 风格 UI：暗色背景、黄白配色、点阵网格、中心十字、圆角取景框
- 顶部浮动标签（标题 + 置信度徽章 + 副标签）
- 健康模式支持绘制相对坐标 `bbox`
- 一键切换 4 种模式，拍照后自动保存并显示识别结果
- 可配置分析后端（Mock / TFLite / API）

---

## 🗂️ 目录结构

```
lib/
  main.dart
  config/
    app_config.dart        # AnalyzerType 切换（mock/tflite/api）
  models/
    ai_result.dart
  services/
    mock_ai.dart           # 默认：假数据
    pet_classifier.dart    # 可选：TFLite 实现
    api_client.dart        # 可选：远程推理
  ui/
    camera_screen.dart     # 相机主界面（预览 + overlay + 底栏）
    bottom_bar.dart
    overlay/
      yellow_frame_painter.dart
      top_tag.dart
  utils/
    image_utils.dart       # TFLite 预处理（可选）
assets/
  models/                  # 放置 .tflite 与 labels.txt（如使用）
```

---

## 🔧 环境要求

- Flutter 3.x（稳定版）
- Android Studio（含 Android SDK/Platform Tools）
- Android 最低 SDK：24
- 目标设备：Nothing Phone 3a（或任意 Android 设备）

---

## 📦 依赖

`pubspec.yaml` 主要依赖：
- `camera`
- `permission_handler`
- `path_provider`
- `gallery_saver`
- 可选：`tflite_flutter`, `image`, `http`

---

## 🔐 权限与配置（Android）

`android/app/src/main/AndroidManifest.xml` 增加：
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```
android/app/build.gradle：
```
defaultConfig {
  minSdkVersion 24
}
```

---

## ▶️ 运行步骤

1. 开发设备安装 Flutter 与 Android Studio，flutter doctor 通过检查
2. 手机开启 开发者选项 → USB 调试，用数据线连接电脑
3. 项目根目录执行：
   - `flutter pub get`
   - `flutter run`    # 首次可用 debug；成功后可切换 --release

手机上即可看到 Demo 界面（默认 Mock 分析器）

---

## 🧠 模式与交互流

- 模式枚举：normal | pet | health | travel
- 拍照流程：
  1. 点击底部快门 → CameraController.takePicture()
  2. 保存到相册（可关闭）
  3. 调用分析器（由 AppConfig.analyzer 决定）
  4. 更新顶部标签（title + confidence + subInfo）与 bbox（仅健康模式）
  5. 弹出 SnackBar：已保存并完成识别（Demo/Mock）

---

## UI 规范（Nothing 视觉）

- 背景：#121416（暗色）
- 主题黄：#FFD54A
- 点阵网格：不透明度 ~ 0.18，步进 ~ 28px
- 中心十字线：不透明度 ~ 0.35
- 主取景框：圆角 12，2px 描边
- 四角短边装饰：长度 ~24px，3px 圆角描边
- 顶部标签：半透明黑底、黄边圆角胶囊；置信度独立小徽章

---

## ⚙️ 配置分析后端

`lib/config/app_config.dart`
```dart
enum AnalyzerType { mock, tflite, api }
class AppConfig {
  static const analyzer = AnalyzerType.mock; // mock | tflite | api
  static const apiBase = 'https://example.com'; // if api
}
```

### Mock（默认）
`services/mock_ai.dart` 随机返回：
- pet: 体检报告 + 85–96%
- health: 眼部区域 + 85–96% + 可添加健康标记 + 随机 bbox
- travel: 出行箱视角 + 85–96% + 电量: 85%
- normal: 普通拍摄 + 已保存照片

### TFLite（本地真识别）
- 将 model.tflite 与 labels.txt 放入 assets/models/
- pubspec.yaml 声明 assets
- `services/pet_classifier.dart` 中加载模型、做预处理（`utils/image_utils.dart`），返回 top-1 标签与概率
- 将 `AppConfig.analyzer` 改为 `AnalyzerType.tflite`

### 远程 API
- `services/api_client.dart` POST `${API_BASE}/analyze` 上传图片（multipart/form-data）
- 服务器返回：
```json
{
  "title": "体检报告",
  "confidence": 94,
  "subInfo": "识别宠物品种、情绪",
  "bbox": { "x":0.33, "y":0.26, "w":0.28, "h":0.22 }  // 可选
}
```
- 将 `AppConfig.analyzer` 改为 `AnalyzerType.api`

---

## ✅ 验收标准

- 应用能在 Nothing Phone 3a 打开相机预览、拍照、保存图片
- 4 种模式可切换，切换后清空上次结果
- 拍照后顶部出现相应标签与百分比；健康模式出现子框
- UI 符合 Nothing 视觉（点阵、中心十字、黄白配色、圆角取景框）
- 默认 mock 无需联网即可演示
