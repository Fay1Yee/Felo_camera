# Nothing Phone 3a Camera - AI 智能相机应用

> 🚀 基于 Flutter + FastAPI + 火山引擎 Ark 的智能相机应用，专为 Nothing Phone 3a 设计

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
- **框架**：Flutter 3.9.2+
- **语言**：Dart
- **相机**：camera ^0.11.2
- **权限管理**：permission_handler ^12.0.1
- **网络请求**：http ^0.13.6
- **图像处理**：image ^4.5.4
- **AI 集成**：tflite_flutter ^0.11.0

### 后端 (FastAPI)
- **框架**：FastAPI
- **语言**：Python 3.8+
- **AI 服务**：火山引擎 Ark API
- **图像处理**：Pillow (PIL)
- **服务器**：Uvicorn ASGI
- **环境管理**：python-dotenv

### AI 服务
- **提供商**：火山引擎 (字节跳动)
- **模型**：doubao-seed-1-6-250615
- **接口**：OpenAI 兼容 API
- **功能**：多模态图像理解

## 🚀 快速开始

### 环境要求

- **Flutter**: 3.9.2 或更高版本
- **Python**: 3.8 或更高版本
- **Android Studio** 或 **Xcode**（移动端开发）
- **火山引擎 Ark API Key**

### 1. 克隆项目

```bash
git clone https://github.com/your-username/nothing-phone-3a-camera.git
cd nothing-phone-3a-camera
```

### 2. 后端设置

```bash
# 进入后端目录
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 或 venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入你的 API 密钥

# 启动后端服务
python main.py
```

### 3. 前端设置

```bash
# 进入前端目录
cd pet_camera_demo

# 安装 Flutter 依赖
flutter pub get

# 运行应用
flutter run
```

### 4. Web 版本运行

```bash
# 在前端目录下
flutter run -d chrome --web-port=7357
```

## 📂 项目结构

```
nothing-phone-3a-camera/
├── backend/                    # FastAPI 后端服务
│   ├── main.py                # 主应用文件
│   ├── requirements.txt       # Python 依赖
│   ├── .env.example          # 环境变量模板
│   └── README.md             # 后端文档
├── pet_camera_demo/           # Flutter 前端应用
│   ├── lib/
│   │   ├── config/           # 配置文件
│   │   │   ├── app_config.dart
│   │   │   └── device_config.dart
│   │   ├── models/           # 数据模型
│   │   │   ├── ai_result.dart
│   │   │   └── mode.dart
│   │   ├── services/         # 服务层
│   │   │   ├── api_client.dart
│   │   │   ├── mock_ai.dart
│   │   │   └── pet_classifier.dart
│   │   ├── ui/              # 用户界面
│   │   │   ├── camera_screen.dart
│   │   │   ├── camera_screen_io.dart
│   │   │   ├── camera_screen_web.dart
│   │   │   ├── bottom_bar.dart
│   │   │   └── overlay/
│   │   ├── utils/           # 工具类
│   │   │   └── image_utils.dart
│   │   └── main.dart        # 应用入口
│   ├── android/             # Android 配置
│   ├── ios/                 # iOS 配置
│   ├── web/                 # Web 配置
│   └── pubspec.yaml         # Flutter 依赖
└── README.md                # 项目文档
```

## 🔧 配置说明

### 后端配置

在 `backend/.env` 文件中配置：

```env
# 火山引擎 Ark API 配置
ARK_API_KEY=your_ark_api_key_here

# 服务器配置
HOST=0.0.0.0
PORT=8000
DEBUG=true

# 日志级别
LOG_LEVEL=info
```

### 前端配置

在 `pet_camera_demo/lib/config/app_config.dart` 中配置：

```dart
class AppConfig {
  static const String apiBase = 'http://127.0.0.1:8000';
  static const int requestTimeout = 30;
  static const bool enableLogging = true;
}
```

## 📱 支持平台

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Web** (Chrome, Safari, Firefox)
- 🔄 **macOS** (计划中)
- 🔄 **Windows** (计划中)

## 🎯 使用场景

### 日常生活
- 识别未知物体和场景
- 获取物品信息和使用建议
- 记录生活中的有趣发现

### 宠物护理
- 识别宠物品种和特征
- 分析宠物行为和状态
- 获取宠物护理建议

### 健康管理
- 识别食物营养信息
- 分析健康相关图像
- 获取健康建议和提醒

### 旅行探索
- 识别旅行目的地和景点
- 获取地点历史和文化信息
- 记录旅行回忆

## 🔒 隐私与安全

- **本地处理**：图像在设备上进行预处理
- **安全传输**：使用 HTTPS 加密传输
- **不存储图像**：服务器不保存用户上传的图像
- **API 密钥保护**：后端 API 密钥安全存储
- **权限控制**：最小化权限请求

## 🚀 部署指南

### 开发环境
- 后端：`python main.py`
- 前端：`flutter run`

### 生产环境
- **后端**：Docker 容器化部署
- **前端**：构建 APK/IPA 或 Web 应用
- **云服务**：支持阿里云、腾讯云、华为云等

详细部署说明请参考 [backend/README.md](backend/README.md)

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献
1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 开发规范
- 遵循 Flutter 和 Python 代码规范
- 添加适当的注释和文档
- 确保测试通过
- 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- **Nothing** - 设计灵感和品牌支持
- **Flutter Team** - 优秀的跨平台框架
- **火山引擎** - 强大的 AI 服务支持
- **FastAPI** - 高性能的 Python Web 框架

## 📞 联系我们

- **项目主页**：[GitHub Repository](https://github.com/your-username/nothing-phone-3a-camera)
- **问题反馈**：[Issues](https://github.com/your-username/nothing-phone-3a-camera/issues)
- **功能建议**：[Discussions](https://github.com/your-username/nothing-phone-3a-camera/discussions)

---

<div align="center">

**🌟 如果这个项目对你有帮助，请给我们一个 Star！🌟**

Made with ❤️ for Nothing Phone 3a

</div>