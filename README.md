# Felo App - 智能宠物管理应用

<div align="center">

![Felo App Logo](https://img.shields.io/badge/Felo-App-blue?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)

**以"宠物身份证 + 档案"为核心的智能宠物管理应用**

融合 AI 相机识别、日常行为追踪与性格建模三项核心技术

</div>

## 📋 项目信息

- **软件名称**: Felo App
- **版本号**: V1.0
- **开发完成日期**: 2025年10月10日
- **著作权人**: Felo设计团队（Felo Design Team）
- **运行平台**: Android 移动端（Nothing OS）

## 🚀 核心功能

### 🪪 宠物身份证系统
- 官方证件样式设计
- 包含证件照、二维码、芯片编号等信息
- 数字化宠物身份管理

### 🤖 AI相机识别系统
- 基于相机采集宠物的日常动作、表情与活动频率
- 实时行为识别与健康分析
- 智能数据采集与处理

### 📊 性格建模系统
- 通过 AI 算法对日常行为进行聚类与特征提取
- 生成宠物五型人格档案
- 个性化性格分析报告

### 📁 宠物档案系统
- **Guardian（守护型）**: 依附强、情绪稳定
- **Explorer（探索型）**: 好奇、活跃、喜欢新环境
- **Socializer（社交型）**: 亲人、互动频繁
- **Thinker（思考型）**: 安静、有规律
- **Adventurer（冒险型）**: 高能、容易兴奋

### 🎯 多场景管理系统
- **出行场景**: 出行箱控制与管理
- **居家场景**: 日常活动监控
- **医疗场景**: 健康提醒与病历管理
- **城市场景**: 城市服务与社交互动

## 🛠 技术栈

### 前端技术
- **开发语言**: Flutter (Dart)
- **UI框架**: Flutter Material Design
- **状态管理**: Provider + ChangeNotifier
- **主题系统**: Nothing Design System

### 后端技术
- **开发语言**: Python 3.11
- **后端框架**: FastAPI
- **数据库**: SQLite
- **AI算法**: 行为分析与人格建模

### 开发环境
- **操作系统**: Android 14
- **版本管理**: GitHub（私有仓库）
- **目标平台**: Android 移动端（Nothing OS）

## 🏗 系统架构

```
┌───────────────────────────────┐
│          Felo App（前端）             │
│ ├─ UI模块（Flutter Material）        │
│ ├─ 场景模块（出行/居家/医疗/城市）   │
│ ├─ AI相机识别模块                    │
│ ├─ 宠物档案与性格生成模块            │
│ └─ 数据可视化模块                    │
└───────────────▲──────────────┘
                │
                │ RESTful API
┌───────────────▼──────────────┐
│         Felo Backend（后端）         │
│ ├─ FastAPI 控制器                   │
│ ├─ 行为分析与人格建模接口           │
│ ├─ 文件上传与数据存储               │
│ └─ SQLite 数据记录与日志模块        │
└──────────────────────────────┘
```

## 🧠 核心算法

### 人格建模算法流程

1. **数据采集**
   - 来源：AI相机、出行箱摄像头、手动记录
   - 内容：活动频率、休息时长、饮食次数、情绪识别结果
   - 时间分辨率：每小时汇总一次

2. **特征提取**
   - 活跃度、探索度、依附性、情绪稳定性、社交意愿等五维指标

3. **权重计算**
   - 各维度赋权（活跃度0.25、社交度0.2、情绪度0.2、依附性0.2、探索性0.15）
   - 生成特征矩阵 → 标准化 → 聚类分析

4. **五型人格输出**
   - 基于多维度分析生成个性化人格标签

5. **档案生成**
   - 输出词云 + 雷达图 + 行为曲线
   - 汇总为宠物个性报告（PDF + 页面档案）

## 📱 主要界面

- 🏠 **主界面**: 宠物状态总览
- 🪪 **宠物身份证**: 数字化身份管理
- 📷 **AI相机实时识别界面**: 行为识别与分析
- 📊 **性格雷达图与词云**: 个性化分析展示
- 📈 **健康趋势曲线**: 健康数据可视化
- 🧳 **出行场景控制页**: 出行管理功能
- 🏥 **医疗病历页**: 健康档案管理
- 🏙 **城市服务页**: 城市功能集成
- ⚙️ **设置页**: 应用配置管理
- 📤 **快速档案分享页**: 档案分享功能

## 🎯 应用场景

- 智能宠物设备与家庭管理
- 宠物健康档案记录与数据分析
- 宠物行为研究与性格分类
- 宠物出行管理与AI健康检测
- 教学、实验与宠物心理研究辅助工具

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK >= 30
- Python 3.11+（后端服务）

### 安装步骤

1. **克隆项目**
```bash
git clone [repository-url]
cd felo-camera
```

2. **安装依赖**
```bash
flutter pub get
```

3. **启动后端服务**
```bash
cd backend
pip install -r requirements.txt
python main.py
```

4. **运行应用**
```bash
flutter run --release
```

## 📁 项目结构

```
lib/
├── config/          # 配置文件
├── models/          # 数据模型
├── screens/         # 页面组件
├── services/        # 业务服务
├── ui/             # UI组件
├── utils/          # 工具类
└── widgets/        # 自定义组件

backend/
├── main.py         # 后端入口
├── requirements.txt # Python依赖
└── ...
```

## 🤝 贡献指南

本项目为私有项目，由 Felo 设计团队维护开发。

## 📄 许可证

Copyright © 2025 Felo Design Team. All rights reserved.

---

<div align="center">

**Felo App - 让每只宠物都有自己的数字档案** 🐾

Made with ❤️ by Felo Design Team

</div>