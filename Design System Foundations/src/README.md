# Felo 宠物管家应用

> 基于 Nothing OS 极简设计风格的移动端宠物管理应用

[![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue.svg)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-4.0-38bdf8.svg)](https://tailwindcss.com/)

## 📱 应用概述

Felo 是一个采用"宠物身份证"概念的现代化宠物管理应用，实现"一次登记，处处可用"。应用采用 Nothing OS 极简设计语言，支持出行、医疗、保险、城市管理四大场景，所有内容采用"宠物视角"的可爱叙述风格。

### ✨ 核心特性

- **🪪 宠物身份证系统** - 官方证件样式，包含证件照、认证印章、芯片编号
- **🎨 Nothing OS 设计** - 米白背景、亮黄强调、墨绿辅助的极简配色
- **📲 移动端优先** - 为 390×844 移动设备优化
- **🎯 多场景应用** - 出行、医疗、保险、城市管理四大场景
- **🤖 AI 相机** - 智能识别宠物行为和健康状态
- **📊 数据可视化** - 性格词云、健康趋势、习惯分析

## 🎨 设计系统

### 配色方案

```css
/* 主色调 */
--color-background: #FAFAFA        /* 米白背景 */
--color-brand-primary: #FFD84D     /* 亮黄强调 */
--color-accent-primary: #2F5233    /* 墨绿辅助 */

/* 灰度系统 */
--color-gray-800: #424242          /* 主文字 */
--color-gray-500: #9E9E9E          /* 次要文字 */
--color-gray-400: #BDBDBD          /* 辅助文字 */
```

### 字体系统

```css
/* 轻量化字重 */
--font-weight-medium: 450
--font-weight-normal: 350

/* 字号层级 */
--text-display: 32px/44px          /* 标题 */
--text-title: 20px/32px            /* 副标题 */
--text-body: 15px/26px             /* 正文 */
--text-caption: 13px/20px          /* 说明 */
```

### 间距与圆角

```css
/* 紧凑间距 */
--space-4: 16px    /* 基础间距 */
--space-5: 20px    /* 页面边距 */

/* 轻微圆角 */
--radius-md: 6px   /* 按钮 */
--radius-lg: 8px   /* 卡片 */
```

## 🏗️ 技术架构

### 技术栈

- **前端框架**: React 18 + TypeScript
- **样式系统**: Tailwind CSS V4
- **UI 组件**: Shadcn UI
- **图标库**: Lucide React
- **状态管理**: React Context API
- **导航系统**: 自定义页面栈

### 项目结构

```
├── App.tsx                        # 应用入口与路由管理
├── components/
│   ├── templates/                 # 页面模板（23个页面）
│   │   ├── HomeTemplate.tsx       # 今日页面
│   │   ├── PetProfileDetailTemplate.tsx  # 宠物档案
│   │   ├── ScenariosTemplate.tsx  # 场景切换
│   │   ├── SettingsTemplate.tsx   # 个人中心
│   │   └── ...                    # 其他页面模板
│   ├── ui/                        # UI组件库（43个组件）
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   └── ...
│   ├── AICameraInterface.tsx      # AI相机组件
│   ├── OnboardingGuide.tsx        # 引导页
│   ├── PhoneStatusBar.tsx         # 手机状态栏
│   └── PhoneHomeIndicator.tsx     # Home指示器
├── styles/
│   └── globals.css                # 全局样式与设计令牌
└── guidelines/                    # 设计指南文档
```

### 核心组件

#### 1. 应用入口 (`App.tsx`)

- **导航系统**: 基于页面栈的导航管理
- **场景上下文**: 全局场景状态（出行/居家/医疗/城市）
- **底部导航**: 5个主Tab（今日/档案/相机/出行箱/我的）
- **状态栏**: 模拟iPhone状态栏和Home指示器

#### 2. 页面模板 (`components/templates/`)

23个页面模板，分为4大模块：

**核心模块**
- `HomeTemplate`: 今日页面 - 日常管理中枢
- `PetProfileDetailTemplate`: 档案 - 宠物身份证
- `ScenariosTemplate`: 出行箱 - 场景切换器
- `SettingsTemplate`: 我的 - 个人中心

**健康模块**
- `HealthTemplate`: 健康记录
- `HealthDetailTemplate`: 病历详情
- `ReminderTemplate`: 健康提醒

**出行模块**
- `TravelHubTemplate`: 出行中枢
- `TravelPlanDetailTemplate`: 出行计划
- `TravelBoxSettingsTemplate`: 设备设置
- `TravelBoxWiFiTemplate/BluetoothTemplate/...`: 设备控制

**管理模块**
- `LifeRecordsTemplate`: 生活记录
- `HabitsDetailTemplate`: 习惯分析
- `DataBackupTemplate`: 数据备份

#### 3. UI组件库 (`components/ui/`)

基于 Shadcn UI 的43个组件：
- **表单**: Button, Input, Select, Checkbox, Switch
- **布局**: Card, Sheet, Dialog, Drawer, Tabs
- **反馈**: Alert, Toast (Sonner), Progress
- **数据**: Table, Chart, Calendar
- **导航**: Breadcrumb, Pagination, Navigation Menu

## 🎯 核心功能

### 1. 宠物身份证系统

```typescript
// 官方证件样式设计
- 证件照框架（带圆角边框）
- 官方认证印章（红色印章图案）
- 芯片编号（唯一标识）
- 二维码（快速识别）
- 核心信息展示（品种、生日、性别等）
```

### 2. 场景切换系统

```typescript
export type ScenarioType = 'travel' | 'home' | 'medical' | 'city';

// 场景上下文
export const ScenarioContext = createContext<ScenarioContextType>({
  currentScenario: 'travel',
  setCurrentScenario: () => {},
});
```

4个应用场景：
- **出行场景**: 出行箱控制、GPS定位、航班信息
- **居家场景**: 日常管理、习惯分析、性格词云
- **医疗场景**: 健康记录、疫苗提醒、病历管理
- **城市场景**: 城市服务、社区互动

### 3. 导航系统

```typescript
// 页面栈管理
const [pageStack, setPageStack] = useState<PageType[]>(['home']);

// 导航规则
- 主Tab切换：重置页面栈
- 子页面跳转：压入页面栈
- 返回操作：弹出页面栈
```

### 4. AI相机功能

智能识别模式：
- **健康检查**: 眼睛、皮肤、牙齿状态
- **行为分析**: 活跃度、情绪状态
- **饮食记录**: 食物识别、份量分析
- **AR滤镜**: 可爱装饰效果

### 5. 性格词云分析

```typescript
// 基于日常习惯生成
const personalityTags = [
  { text: "超级黏人", size: 26, isYellow: true },
  { text: "好奇宝宝", size: 20, isYellow: true },
  { text: "小吃货", size: 18, isYellow: false },
  // ...
];
```

## 📱 页面导航地图

```
引导页 (OnboardingGuide)
    ↓
┌─────────────────────────────────┐
│      底部Tab导航（主要页面）       │
├─────────────────────────────────┤
│ [今日] [档案] [📷] [出行箱] [我的] │
└─────────────────────────────────┘
    ↓       ↓       ↓       ↓       ↓
  今日     档案    相机   出行箱    我的
    │       │       │       │       │
    ├─健康  │      AI     │       ├─设置
    ├─提醒  ├─编辑  相机   ├─设备  ├─备份
    ├─记录  ├─习惯  界面   ├─计划  └─帮助
    └─...   └─...         └─...
```

## 🎨 设计特色

### 1. 点阵图案装饰

```css
/* 点阵背景 */
.dot-grid-bg {
  background-image: radial-gradient(circle, currentColor 1px, transparent 1px);
  background-size: 8px 8px;
  opacity: 0.05;
}

/* 点阵分割线 */
.dot-divider {
  background-image: linear-gradient(to right, currentColor 33%, transparent 0%);
  background-size: 6px 1px;
}
```

### 2. 宠物视角文案

```typescript
// 所有提醒采用可爱的宠物语气
"主人，我该去打疫苗啦！"
"今天和主人玩了好久呀～"
"我的小饭碗空空的，该吃饭啦！"
```

### 3. 卡片式布局

```typescript
// 分层展示，减少跳转
<Card>
  <CardHeader>标题区</CardHeader>
  <CardContent>内容区</CardContent>
  <CardFooter>操作区</CardFooter>
</Card>
```

### 4. 场景化配色

```css
/* 出行场景 - 蓝色系 */
travel: #42A5F5

/* 居家场景 - 黄色系 */
home: #FFD84D

/* 医疗场景 - 红色系 */
medical: #EF5350

/* 城市场景 - 绿色系 */
city: #66BB6A
```

## 🚀 开发指南

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

## 📂 关键文件说明

| 文件 | 说明 |
|------|------|
| `App.tsx` | 应用入口、路由管理、导航系统 |
| `styles/globals.css` | 全局样式、设计令牌、字体系统 |
| `components/templates/` | 所有页面模板 |
| `components/ui/` | Shadcn UI组件库 |
| `components/AICameraInterface.tsx` | AI相机核心功能 |
| `components/OnboardingGuide.tsx` | 新用户引导 |
| `guidelines/` | 设计指南文档 |

## 📄 文档资源

- [架构文档](./ARCHITECTURE_OVERVIEW.md) - 详细架构说明
- [设计指南](./guidelines/Guidelines.md) - UI/UX设计规范
- [配色系统](./guidelines/ColorSystem.md) - 颜色使用指南
- [AI相机指南](./guidelines/AICameraGuide.md) - AI功能说明

## 🎯 设计原则

1. **极简主义** - Nothing OS风格，去除冗余装饰
2. **移动优先** - 为触摸交互优化
3. **模块化** - 卡片式布局，减少层级
4. **一致性** - 统一的视觉语言和交互模式
5. **可爱友好** - 宠物视角的文案和插图

## 📊 应用数据

- **页面总数**: 23个页面模板
- **UI组件**: 43个Shadcn组件
- **设计令牌**: 60+个CSS变量
- **屏幕尺寸**: 390×844 (iPhone 12/13/14)
- **支持场景**: 4大应用场景

## 🔧 技术细节

### 状态管理

```typescript
// 场景上下文
const ScenarioContext = createContext<ScenarioContextType>({
  currentScenario: 'travel',
  setCurrentScenario: () => {},
});

// 页面栈
const [pageStack, setPageStack] = useState<PageType[]>(['home']);
```

### 导航逻辑

```typescript
const navigateTo = (page: PageType) => {
  if (pages[page].showInNav) {
    setPageStack([page]);  // 主Tab：重置栈
  } else {
    setPageStack([...pageStack, page]);  // 子页面：压栈
  }
};
```

### 固定定位系统

```css
/* 状态栏 - top: 0 */
PhoneStatusBar: fixed top-0

/* 顶部导航 - top: 44px */
Header: fixed top-44px

/* 主内容 - paddingTop: 104px */
Content: paddingTop: 104px

/* 底部导航 - bottom: 0 */
BottomNav: fixed bottom-0

/* Home指示器 - bottom: 0 */
PhoneHomeIndicator: fixed bottom-0
```

## 🎨 视觉规范

### 卡片阴影

```css
--elevation-1: 0 1px 2px rgba(0, 0, 0, 0.04)
--elevation-2: 0 1px 3px rgba(0, 0, 0, 0.06)
--elevation-3: 0 2px 6px rgba(0, 0, 0, 0.08)
```

### 过渡动画

```css
/* 通用过渡 */
transition: all 0.2s ease

/* 淡入动画 */
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
```

## 📝 更新日志

详见各个专项文档：
- [CHANGELOG.md](./CHANGELOG.md) - 完整更新历史
- [PHONE_UI_UPDATE.md](./PHONE_UI_UPDATE.md) - 手机UI更新
- [NEW_MINIMALISM_UPDATE.md](./NEW_MINIMALISM_UPDATE.md) - 极简化改版
- [PET_PROFILE_UPDATE.md](./PET_PROFILE_UPDATE.md) - 身份证系统
- [TRAVEL_BOX_UPDATE.md](./TRAVEL_BOX_UPDATE.md) - 出行箱功能

## 🤝 贡献指南

本项目遵循 Nothing OS 设计规范，贡献时请注意：

1. 保持极简风格，避免过度装饰
2. 使用设计令牌，不要硬编码颜色
3. 文案采用宠物视角的可爱语气
4. 新增页面需更新路由配置
5. UI组件优先使用Shadcn组件

## 📄 许可证

MIT License

---

**Felo 宠物管家** - 让宠物管理更简单、更可爱 🐾
