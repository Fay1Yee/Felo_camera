# Nothing Phone 3a Camera - AI 智能相机应用

🚀 基于 Flutter + FastAPI + 火山引擎 Ark 的智能相机应用，专为 Nothing Phone 3a 设计

一款集成了先进 AI 图像识别技术的智能相机应用，支持多种分析模式，为用户提供专业的图像分析和识别服务。

## ✨ 核心功能

### 📸 智能拍照
- **实时相机预览**：流畅的相机界面，支持前后摄像头切换
- **多平台支持**：原生支持 Android、iOS 和 Web 平台
- **智能对焦**：自动对焦和曝光调节
- **高质量图像**：支持高分辨率图像捕获

### 🤖 AI 图像分析
- **普通场景识别**：识别日常物体、场景和环境
- **宠物识别**：专业的宠物品种识别和行为分析
- **健康分析**：从图像中识别健康相关信息并提供建议
- **旅行助手**：识别旅行场景、地标和景点信息

### 🎨 用户体验
- **Nothing 设计语言**：遵循 Nothing Phone 的设计风格
- **暗色主题**：护眼的深色界面设计
- **流畅动画**：丰富的交互动画和过渡效果
- **直观操作**：简洁明了的用户界面

## 🏗 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Nothing Phone 3a Camera                 │
├─────────────────────────────────────────────────────────────┤
│                      Flutter 前端                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   相机界面       │  │   图像处理       │  │   结果展示   │ │
│  │  - 实时预览      │  │  - 格式转换      │  │  - AI分析    │ │
│  │  - 拍照功能      │  │  - 尺寸调整      │  │  - 结果展示  │ │
│  │  - 模式选择      │  │  - 质量优化      │  │  - 历史记录  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                │ HTTP/HTTPS API
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    FastAPI 后端服务                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │   API 网关       │  │   图像处理       │  │   AI 集成    │ │
│  │  - 请求路由      │  │  - 格式验证      │  │  - 模式管理  │ │
│  │  - 参数验证      │  │  - 自动压缩      │  │  - 结果解析  │ │
│  │  - 错误处理      │  │  - Base64编码    │  │  - 响应格式  │ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
                                │ OpenAI Compatible API
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    火山引擎 Ark AI 服务                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐ │
│  │  doubao-seed    │  │   图像理解       │  │   自然语言   │ │
│  │   AI 模型       │  │  - 物体识别      │  │  - 中文生成  │ │
│  │  - 多模态理解    │  │  - 场景分析      │  │  - 结构化输出│ │
│  │  - 高精度识别    │  │  - 特征提取      │  │  - 置信度评估│ │
│  └─────────────────┘  └─────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📱 技术栈

### 前端 (Flutter)
- **框架**: Flutter 3.x
- **语言**: Dart
- **相机**: camera 插件
- **权限**: permission_handler
- **存储**: path_provider, gallery_saver
- **网络**: http, dio
- **状态管理**: Provider/Riverpod

### 后端 (FastAPI)
- **框架**: FastAPI 0.104+
- **语言**: Python 3.8+
- **AI服务**: 火山引擎 Ark API
- **图像处理**: Pillow (PIL)
- **服务器**: Uvicorn ASGI
- **环境管理**: python-dotenv

### AI 服务
- **模型**: doubao-seed-1-6-250615
- **API**: OpenAI 兼容接口
- **功能**: 多模态图像理解
- **语言**: 中文优化

## 🗂️ 项目结构

```
├── lib/                    # Flutter 应用源码
│   ├── main.dart          # 应用入口
│   ├── config/            # 配置文件
│   ├── models/            # 数据模型
│   ├── services/          # 服务层
│   ├── screens/           # 页面组件
│   ├── widgets/           # UI 组件
│   └── utils/             # 工具函数
├── backend/               # FastAPI 后端服务
│   ├── main.py           # 后端入口
│   ├── requirements.txt  # Python 依赖
│   └── .env.example      # 环境变量模板
├── android/              # Android 平台配置
├── ios/                  # iOS 平台配置
├── web/                  # Web 平台配置
├── assets/               # 静态资源
└── pubspec.yaml          # Flutter 依赖配置
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
