# Felo 应用架构综述

> 深度解析宠物管家应用的技术架构与设计决策

## 📐 整体架构

### 架构模式

```
┌──────────────────────────────────────────┐
│         用户界面层 (UI Layer)              │
│  ┌────────────────────────────────────┐  │
│  │  Phone Status Bar (固定)           │  │
│  ├────────────────────────────────────┤  │
│  │  App Header (固定)                 │  │
│  ├────────────────────────────────────┤  │
│  │  Page Template (可滚动)           │  │
│  │  - HomeTemplate                    │  │
│  │  - PetProfileDetailTemplate        │  │
│  │  - ScenariosTemplate               │  │
│  │  - 其他20个页面模板...              │  │
│  ├────────────────────────────────────┤  │
│  │  Bottom Navigation (固定)          │  │
│  ├────────────────────────────────────┤  │
│  │  Phone Home Indicator (固定)       │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────┐
│      应用逻辑层 (Logic Layer)             │
│  - 页面栈导航系统                         │
│  - 场景上下文管理                         │
│  - 路由配置管理                           │
└──────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────┐
│      组件库层 (Component Layer)           │
│  - Shadcn UI (43个组件)                  │
│  - 自定义组件 (AI相机、引导页等)          │
└──────────────────────────────────────────┘
            ↓
┌──────────────────────────────────────────┐
│      样式系统层 (Style Layer)             │
│  - Tailwind CSS V4                       │
│  - 设计令牌 (60+ CSS变量)                 │
│  - 全局样式 (globals.css)                │
└──────────────────────────────────────────┘
```

## 🗂️ 文件结构详解

### 核心文件层级

```
Felo/
│
├── 📱 应用入口
│   └── App.tsx                    # 主应用组件（420行）
│       ├── 导航系统
│       ├── 场景管理
│       ├── 页面配置
│       └── UI布局
│
├── 🎨 样式系统
│   └── styles/
│       └── globals.css            # 全局样式（500+行）
│           ├── CSS变量定义
│           ├── 字体系统
│           ├── 颜色系统
│           ├── 点阵图案
│           └── 动画定义
│
├── 🧩 组件库
│   └── components/
│       │
│       ├── 📄 页面模板 (templates/)
│       │   ├── HomeTemplate.tsx              # 今日页
│       │   ├── PetProfileDetailTemplate.tsx  # 档案页
│       │   ├── ScenariosTemplate.tsx         # 场景页
│       │   ├── SettingsTemplate.tsx          # 设置页
│       │   ├── TravelHubTemplate.tsx         # 出行中枢
│       │   ├── HealthTemplate.tsx            # 健康管理
│       │   ├── ReminderTemplate.tsx          # 提醒中心
│       │   ├── LifeRecordsTemplate.tsx       # 生活记录
│       │   ├── HabitsDetailTemplate.tsx      # 习惯分析
│       │   ├── DataBackupTemplate.tsx        # 数据备份
│       │   ├── TravelBoxSettingsTemplate.tsx # 设备设置
│       │   ├── TravelBoxWiFiTemplate.tsx     # WiFi设置
│       │   ├── TravelBoxBluetoothTemplate.tsx # 蓝牙设置
│       │   ├── TravelBoxTemperatureTemplate.tsx # 温度控制
│       │   ├── TravelBoxSoundTemplate.tsx    # 声音控制
│       │   ├── TravelBoxFanTemplate.tsx      # 风扇控制
│       │   ├── TravelPlanDetailTemplate.tsx  # 出行计划
│       │   ├── HealthDetailTemplate.tsx      # 病历详情
│       │   ├── NotificationSettingsTemplate.tsx # 通知设置
│       │   ├── CreateProfileTemplate.tsx     # 创建档案
│       │   ├── PetRegistrationTemplate.tsx   # 档案填写
│       │   └── CameraTestTemplate.tsx        # 相机测试
│       │
│       ├── 🔧 功能组件
│       │   ├── AICameraInterface.tsx         # AI相机界面
│       │   ├── OnboardingGuide.tsx           # 引导页
│       │   ├── PhoneStatusBar.tsx            # 状态栏
│       │   └── PhoneHomeIndicator.tsx        # Home指示器
│       │
│       └── 🎨 UI组件库 (ui/)
│           ├── button.tsx                    # 按钮
│           ├── card.tsx                      # 卡片
│           ├── dialog.tsx                    # 对话框
│           ├── sheet.tsx                     # 抽屉
│           ├── tabs.tsx                      # 标签页
│           ├── switch.tsx                    # 开关
│           ├── slider.tsx                    # 滑块
│           ├── select.tsx                    # 选择器
│           ├── input.tsx                     # 输入框
│           ├── badge.tsx                     # 徽章
│           ├── avatar.tsx                    # 头像
│           ├── progress.tsx                  # 进度条
│           ├── sonner.tsx                    # Toast通知
│           ├── chart.tsx                     # 图表
│           ├── calendar.tsx                  # 日历
│           └── ... (共43个组件)
│
└── 📚 文档
    ├── guidelines/                # 设计指南
    │   ├── Guidelines.md          # 总体规范
    │   ├── ColorSystem.md         # 配色系统
    │   └── AICameraGuide.md       # AI相机指南
    └── 更新日志/
        ├── CHANGELOG.md           # 完整历史
        ├── PHONE_UI_UPDATE.md     # 手机UI更新
        ├── NEW_MINIMALISM_UPDATE.md # 极简化改版
        ├── PET_PROFILE_UPDATE.md  # 身份证系统
        └── TRAVEL_BOX_UPDATE.md   # 出行箱功能
```

## 🧠 核心系统详解

### 1. 导航系统 (Navigation System)

#### 1.1 页面类型定义

```typescript
type PageType = 
  // 主Tab页面（showInNav: true）
  | 'home'                    // 今日
  | 'pet-profile-detail'      // 档案
  | 'scenarios'               // 出行箱
  | 'settings'                // 我的
  
  // 子页面（showInNav: false）
  | 'health'                  // 健康记录
  | 'reminder'                // 提醒中心
  | 'life-records'            // 生活记录
  | 'habits-detail'           // 习惯分析
  | 'travel-hub'              // 出行中枢
  | 'travel-box-settings'     // 设备设置
  | 'data-backup'             // 数据备份
  // ... 其他18个子页面
```

#### 1.2 页面栈管理

```typescript
// 页面栈：记录导航历史
const [pageStack, setPageStack] = useState<PageType[]>(['home']);

// 当前页面：栈顶元素
const currentPage = pageStack[pageStack.length - 1];

// 导航逻辑
const navigateTo = (page: PageType) => {
  if (pages[page].showInNav) {
    // 主Tab切换：清空栈，重新开始
    setPageStack([page]);
  } else {
    // 子页面跳转：压入栈顶
    setPageStack([...pageStack, page]);
  }
};

// 返回逻辑
const goBack = () => {
  if (pageStack.length > 1) {
    // 弹出栈顶
    setPageStack(pageStack.slice(0, -1));
  } else {
    // 回到父页面
    const parentPage = pages[currentPage].parentPage;
    if (parentPage) {
      setPageStack([parentPage]);
    }
  }
};
```

#### 1.3 页面配置系统

```typescript
interface PageConfig {
  title: string;           // 页面标题
  subtitle?: string;       // 副标题
  component: React.ComponentType<{ onNavigate: (page: PageType) => void }>;
  showInNav?: boolean;     // 是否显示在底部导航
  parentPage?: PageType;   // 父页面（用于返回）
}

// 配置示例
const pages: Record<PageType, PageConfig> = {
  'home': {
    title: '今日',
    subtitle: '宠物管家',
    component: HomeTemplate,
    showInNav: true        // 显示在底部导航
  },
  'health': {
    title: '健康',
    subtitle: '记录与管理',
    component: HealthTemplate,
    parentPage: 'home'     // 父页面是home
  }
};
```

### 2. 场景系统 (Scenario System)

#### 2.1 场景类型定义

```typescript
export type ScenarioType = 
  | 'travel'   // 出行场景：设备控制、GPS定位
  | 'home'     // 居家场景：日常管理、习惯分析
  | 'medical'  // 医疗场景：健康记录、疫苗提醒
  | 'city';    // 城市场景：社区服务、公共资源
```

#### 2.2 场景上下文

```typescript
export interface ScenarioContextType {
  currentScenario: ScenarioType;
  setCurrentScenario: (scenario: ScenarioType) => void;
}

export const ScenarioContext = createContext<ScenarioContextType>({
  currentScenario: 'travel',
  setCurrentScenario: () => {},
});

// 使用方式
function App() {
  const [currentScenario, setCurrentScenario] = useState<ScenarioType>('travel');
  
  return (
    <ScenarioContext.Provider value={{ currentScenario, setCurrentScenario }}>
      {/* 应用内容 */}
    </ScenarioContext.Provider>
  );
}
```

#### 2.3 场景选择器组件

```typescript
// 在任意页面使用场景切换
import { ScenarioContext } from '../App';

function SomeTemplate() {
  const { currentScenario, setCurrentScenario } = useContext(ScenarioContext);
  
  return (
    <div className="scenario-selector">
      <button onClick={() => setCurrentScenario('travel')}>出行</button>
      <button onClick={() => setCurrentScenario('home')}>居家</button>
      <button onClick={() => setCurrentScenario('medical')}>医疗</button>
      <button onClick={() => setCurrentScenario('city')}>城市</button>
    </div>
  );
}
```

### 3. UI布局系统 (Layout System)

#### 3.1 固定定位层级

```typescript
// Z-index层级（从上到下）
┌─────────────────────────────────┐
│ Phone Home Indicator (z-50)     │  最上层
│ Phone Status Bar (z-50)         │  最上层
│ AI Camera Interface (z-40)      │  覆盖层
│ Bottom Navigation (z-40)        │  固定导航
│ App Header (z-40)               │  固定头部
│ Page Content (无z-index)        │  内容区
└─────────────────────────────────┘
```

#### 3.2 垂直空间分配

```css
/* 状态栏 */
PhoneStatusBar: 
  position: fixed;
  top: 0;
  height: 44px;

/* 应用头部 */
AppHeader:
  position: fixed;
  top: 44px;
  height: 60px;

/* 主内容区 */
Content:
  padding-top: 104px;    /* 44 + 60 */
  padding-bottom: 76px;  /* 底部导航 + Home指示器 */

/* 底部导航 */
BottomNav:
  position: fixed;
  bottom: 0;
  height: 44px;
  padding-bottom: 32px;  /* 为Home指示器留空间 */

/* Home指示器 */
PhoneHomeIndicator:
  position: fixed;
  bottom: 0;
  height: 32px;
```

#### 3.3 响应式容器

```tsx
// 所有固定元素都有最大宽度限制
<div 
  className="fixed top-0 left-0 right-0 z-50" 
  style={{ 
    maxWidth: '390px',  // iPhone 12/13/14 宽度
    margin: '0 auto'    // 居中显示
  }}
>
  <PhoneStatusBar />
</div>
```

### 4. 样式系统 (Style System)

#### 4.1 设计令牌结构

```css
:root {
  /* === 字体系统 === */
  --font-weight-medium: 450;      /* 中等字重 */
  --font-weight-normal: 350;      /* 常规字重 */
  
  --text-display: 32px;           /* 大标题 */
  --line-height-display: 44px;
  
  --text-title: 20px;             /* 标题 */
  --line-height-title: 32px;
  
  --text-body: 15px;              /* 正文 */
  --line-height-body: 26px;
  
  --text-caption: 13px;           /* 说明 */
  --line-height-caption: 20px;
  
  /* === 间距系统 === */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;    /* 基础间距 */
  --space-5: 20px;    /* 页面边距 */
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  
  /* === 圆角系统 === */
  --radius-xs: 2px;
  --radius-sm: 4px;
  --radius-md: 6px;   /* 按钮 */
  --radius-lg: 8px;   /* 卡片 */
  --radius-xl: 12px;
  --radius-full: 9999px;
  
  /* === 阴影系统 === */
  --elevation-1: 0 1px 2px rgba(0, 0, 0, 0.04);  /* 轻微阴影 */
  --elevation-2: 0 1px 3px rgba(0, 0, 0, 0.06);  /* 中等阴影 */
  --elevation-3: 0 2px 6px rgba(0, 0, 0, 0.08);  /* 明显阴影 */
  
  /* === 品牌色彩 === */
  --color-brand-primary: #FFD84D;     /* 亮黄 */
  --color-brand-secondary: #FFFBEA;   /* 极浅黄 */
  --color-brand-accent: #F5C842;      /* 柔和黄 */
  
  /* === 辅助色彩 === */
  --color-accent-primary: #2F5233;    /* 墨绿 */
  --color-accent-secondary: #EDF7ED;  /* 极浅绿 */
  --color-accent-tertiary: #66BB6A;   /* 柔和绿 */
  
  /* === 灰度系统 === */
  --color-gray-50: #FAFAFA;   /* 主背景 */
  --color-gray-100: #F5F5F5;  /* 次级背景 */
  --color-gray-200: #EEEEEE;  /* 分隔线 */
  --color-gray-300: #E0E0E0;  /* 边框 */
  --color-gray-400: #BDBDBD;  /* 图标 */
  --color-gray-500: #9E9E9E;  /* 次要文字 */
  --color-gray-600: #757575;
  --color-gray-700: #616161;
  --color-gray-800: #424242;  /* 主文字 */
  --color-gray-900: #212121;
}
```

#### 4.2 点阵图案系统

```css
/* 点阵背景 */
.dot-grid-bg {
  background-image: radial-gradient(
    circle, 
    currentColor 1px, 
    transparent 1px
  );
  background-size: var(--dot-spacing) var(--dot-spacing);
  opacity: 0.05;
}

/* 点阵分割线 */
.dot-divider {
  border: none;
  height: 1px;
  background-image: linear-gradient(
    to right, 
    currentColor 33%, 
    transparent 0%
  );
  background-size: 6px 1px;
  background-repeat: repeat-x;
  opacity: 0.3;
}

/* 点阵边框 */
.dot-border {
  border: 1px dashed currentColor;
  opacity: 0.2;
}

/* 点阵光晕 */
.dot-halo::before {
  content: '';
  position: absolute;
  inset: -12px;
  border-radius: inherit;
  background-image: radial-gradient(
    circle, 
    currentColor 1.5px, 
    transparent 1.5px
  );
  background-size: 10px 10px;
  opacity: 0.08;
  pointer-events: none;
}
```

#### 4.3 动画系统

```css
/* 淡入上升动画 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 使用示例 */
.animated-element {
  animation: fadeInUp 0.5s ease-out;
}

/* 延迟递增 */
.animated-element:nth-child(1) { animation-delay: 0.1s; }
.animated-element:nth-child(2) { animation-delay: 0.2s; }
.animated-element:nth-child(3) { animation-delay: 0.3s; }
```

### 5. 组件系统 (Component System)

#### 5.1 页面模板结构

```typescript
// 标准页面模板结构
interface TemplateProps {
  onNavigate: (page: PageType) => void;
}

export function ExampleTemplate({ onNavigate }: TemplateProps) {
  return (
    <div className="space-y-5 pb-8">
      {/* Section 1: 顶部信息卡片 */}
      <Card>
        <CardHeader>标题</CardHeader>
        <CardContent>内容</CardContent>
      </Card>
      
      {/* Section 2: 功能模块 */}
      <Card>
        <div className="grid grid-cols-2 gap-3">
          <button onClick={() => onNavigate('sub-page-1')}>
            功能1
          </button>
          <button onClick={() => onNavigate('sub-page-2')}>
            功能2
          </button>
        </div>
      </Card>
      
      {/* Section 3: 数据展示 */}
      <Card>
        <div className="space-y-3">
          {/* 数据列表 */}
        </div>
      </Card>
    </div>
  );
}
```

#### 5.2 Shadcn UI组件清单

```typescript
// 43个可用组件分类

/* === 表单组件 (13个) === */
- button.tsx          // 按钮
- input.tsx           // 输入框
- textarea.tsx        // 文本域
- select.tsx          // 选择器
- checkbox.tsx        // 复选框
- radio-group.tsx     // 单选组
- switch.tsx          // 开关
- slider.tsx          // 滑块
- label.tsx           // 标签
- form.tsx            // 表单容器
- input-otp.tsx       // OTP输入
- calendar.tsx        // 日历
- toggle.tsx          // 切换按钮

/* === 布局组件 (9个) === */
- card.tsx            // 卡片
- separator.tsx       // 分隔符
- aspect-ratio.tsx    // 宽高比
- scroll-area.tsx     // 滚动区域
- resizable.tsx       // 可调整大小
- sidebar.tsx         // 侧边栏
- collapsible.tsx     // 可折叠
- tabs.tsx            // 标签页
- accordion.tsx       // 手风琴

/* === 覆盖层组件 (6个) === */
- dialog.tsx          // 对话框
- sheet.tsx           // 抽屉
- drawer.tsx          // 底部抽屉
- popover.tsx         // 弹出层
- hover-card.tsx      // 悬浮卡片
- context-menu.tsx    // 右键菜单

/* === 导航组件 (5个) === */
- navigation-menu.tsx // 导航菜单
- menubar.tsx         // 菜单栏
- breadcrumb.tsx      // 面包屑
- pagination.tsx      // 分页
- dropdown-menu.tsx   // 下拉菜单

/* === 反馈组件 (5个) === */
- alert.tsx           // 警告框
- alert-dialog.tsx    // 警告对话框
- sonner.tsx          // Toast通知
- progress.tsx        // 进度条
- skeleton.tsx        // 骨架屏

/* === 数据展示 (3个) === */
- table.tsx           // 表格
- chart.tsx           // 图表
- badge.tsx           // 徽章

/* === 其他 (2个) === */
- avatar.tsx          // 头像
- tooltip.tsx         // 提示框
```

## 🎯 核心功能实现

### 1. 宠物身份证系统

#### 数据结构

```typescript
interface PetProfile {
  // 基础信息
  id: string;
  name: string;
  species: string;        // 品种
  gender: 'male' | 'female';
  birthday: Date;
  
  // 身份信息
  chipNumber: string;     // 芯片编号
  certificateNumber: string; // 证件编号
  registrationDate: Date; // 登记日期
  
  // 外观信息
  photo: string;          // 证件照
  color: string;          // 毛色
  weight: number;         // 体重
  
  // 健康信息
  vaccinations: Vaccination[];
  medicalRecords: MedicalRecord[];
  
  // 性格信息
  personality: string[];  // 性格标签
  habits: Habit[];        // 日常习惯
}
```

#### UI组件

```tsx
// 身份证卡片组件
<Card className="relative overflow-hidden">
  {/* 证件背景 */}
  <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] opacity-5" />
  
  {/* 证件头部 */}
  <div className="flex items-center justify-between p-4">
    <div className="flex items-center gap-2">
      <div className="w-2 h-2 bg-[#2F5233] rounded-full" />
      <span className="text-body">宠物身份证</span>
    </div>
    <Badge>已认证</Badge>
  </div>
  
  {/* 证件照区域 */}
  <div className="flex justify-center py-6">
    <div className="relative">
      <Avatar className="w-32 h-32">
        <AvatarImage src={pet.photo} />
      </Avatar>
      {/* 官方印章 */}
      <div className="absolute -bottom-2 -right-2 w-12 h-12 bg-red-500 rounded-full opacity-20" />
    </div>
  </div>
  
  {/* 核心信息 */}
  <div className="grid grid-cols-2 gap-4 p-4">
    <InfoItem label="姓名" value={pet.name} />
    <InfoItem label="品种" value={pet.species} />
    <InfoItem label="性别" value={pet.gender} />
    <InfoItem label="生日" value={formatDate(pet.birthday)} />
    <InfoItem label="芯片编号" value={pet.chipNumber} />
    <InfoItem label="证件号" value={pet.certificateNumber} />
  </div>
  
  {/* 二维码 */}
  <div className="flex justify-center py-4">
    <QRCode value={pet.id} size={80} />
  </div>
</Card>
```

### 2. 性格词云分析

#### 数据生成逻辑

```typescript
// 基于日常行为生成性格标签
interface PersonalityTag {
  text: string;
  size: number;
  isYellow: boolean;
}

function generatePersonalityTags(habits: Habit[]): PersonalityTag[] {
  // 分析行为数据
  const behaviorAnalysis = analyzeBehaviors(habits);
  
  // 生成标签（6个核心词）
  return [
    // 第一行：小词
    { text: "温柔", size: 14, isYellow: false },
    { text: "聪明伶俐", size: 16, isYellow: true },
    { text: "爱玩耍", size: 15, isYellow: false },
    
    // 第二行：最大核心词
    { text: "超级黏人", size: 26, isYellow: true },
    
    // 第三行：中等词
    { text: "小吃货", size: 18, isYellow: false },
    { text: "好奇宝宝", size: 20, isYellow: true }
  ];
}
```

#### 词云渲染

```tsx
// 紧密居中布局，黄灰双色
<div className="py-6">
  {/* 第一行 - 小词 */}
  <div className="flex items-center justify-center gap-3 mb-2">
    {tags.slice(0, 3).map((tag, i) => (
      <span
        key={i}
        style={{
          fontSize: `${tag.size}px`,
          color: tag.isYellow ? '#FFD84D' : '#9E9E9E',
          fontWeight: tag.size >= 20 ? 600 : 500
        }}
      >
        {tag.text}
      </span>
    ))}
  </div>
  
  {/* 第二行 - 核心词 */}
  <div className="flex justify-center mb-2">
    <span
      style={{
        fontSize: '26px',
        color: '#FFD84D',
        fontWeight: 700
      }}
    >
      超级黏人
    </span>
  </div>
  
  {/* 第三行 - 中等词 */}
  <div className="flex items-center justify-center gap-4">
    {tags.slice(4, 6).map((tag, i) => (
      <span
        key={i}
        style={{
          fontSize: `${tag.size}px`,
          color: tag.isYellow ? '#FFD84D' : '#9E9E9E',
          fontWeight: 600
        }}
      >
        {tag.text}
      </span>
    ))}
  </div>
</div>
```

### 3. AI相机系统

#### 识别模式

```typescript
type CameraMode = 
  | 'health'    // 健康检查：眼睛、皮肤、牙齿
  | 'behavior'  // 行为分析：活跃度、情绪
  | 'food'      // 饮食记录：食物识别、份量
  | 'ar';       // AR滤镜：装饰效果

interface CameraResult {
  mode: CameraMode;
  timestamp: Date;
  image: string;
  analysis?: {
    confidence: number;
    tags: string[];
    recommendations: string[];
  };
}
```

#### 相机界面

```tsx
function AICameraInterface({ onClose, onCapture }) {
  const [mode, setMode] = useState<CameraMode>('health');
  
  return (
    <div className="fixed inset-0 bg-black z-50">
      {/* 相机预览 */}
      <video autoPlay playsInline className="w-full h-full object-cover" />
      
      {/* 模式切换 */}
      <div className="absolute top-20 left-0 right-0 flex justify-center gap-4">
        <ModeButton 
          mode="health" 
          active={mode === 'health'}
          onClick={() => setMode('health')}
        />
        <ModeButton 
          mode="behavior" 
          active={mode === 'behavior'}
          onClick={() => setMode('behavior')}
        />
        <ModeButton 
          mode="food" 
          active={mode === 'food'}
          onClick={() => setMode('food')}
        />
        <ModeButton 
          mode="ar" 
          active={mode === 'ar'}
          onClick={() => setMode('ar')}
        />
      </div>
      
      {/* 拍照按钮 */}
      <div className="absolute bottom-20 left-0 right-0 flex justify-center">
        <button
          className="w-20 h-20 rounded-full bg-[#FFD84D] border-4 border-white"
          onClick={() => handleCapture(mode)}
        />
      </div>
      
      {/* 关闭按钮 */}
      <button
        className="absolute top-6 right-6 w-10 h-10 rounded-full bg-black/50"
        onClick={onClose}
      >
        ×
      </button>
    </div>
  );
}
```

### 4. 场景化设备控制

#### 出行箱设备管理

```typescript
interface TravelBox {
  // 基础信息
  id: string;
  name: string;
  model: string;
  battery: number;
  
  // 网络连接
  wifi: {
    enabled: boolean;
    ssid: string;
    signal: number;
  };
  bluetooth: {
    enabled: boolean;
    paired: boolean;
  };
  
  // 环境控制
  temperature: {
    current: number;
    target: number;
    alarm: { min: number; max: number };
  };
  fan: {
    enabled: boolean;
    speed: number;  // 1-3档
  };
  
  // 声音控制
  sound: {
    enabled: boolean;
    volume: number;  // 0-100
    mode: 'music' | 'white-noise' | 'custom';
  };
}
```

#### 设备控制UI

```tsx
// 温度控制页面
function TravelBoxTemperatureTemplate() {
  const [temperature, setTemperature] = useState(22);
  const [alarmRange, setAlarmRange] = useState({ min: 18, max: 26 });
  
  return (
    <div className="space-y-5">
      {/* 当前温度显示 */}
      <Card className="text-center p-8">
        <div className="text-6xl font-bold text-[#424242]">
          {temperature}°C
        </div>
        <p className="text-caption text-[#9E9E9E] mt-2">
          当前温度
        </p>
      </Card>
      
      {/* 温度调节 */}
      <Card className="p-5">
        <h3 className="text-body mb-4">目标温度</h3>
        <Slider
          value={[temperature]}
          onValueChange={([v]) => setTemperature(v)}
          min={15}
          max={30}
          step={0.5}
        />
        <div className="flex justify-between mt-2 text-caption text-[#9E9E9E]">
          <span>15°C</span>
          <span>30°C</span>
        </div>
      </Card>
      
      {/* 温度警报 */}
      <Card className="p-5">
        <h3 className="text-body mb-4">温度警报范围</h3>
        <div className="space-y-4">
          <div>
            <Label>最低温度</Label>
            <Slider
              value={[alarmRange.min]}
              onValueChange={([v]) => setAlarmRange({ ...alarmRange, min: v })}
              min={10}
              max={25}
            />
          </div>
          <div>
            <Label>最高温度</Label>
            <Slider
              value={[alarmRange.max]}
              onValueChange={([v]) => setAlarmRange({ ...alarmRange, max: v })}
              min={20}
              max={35}
            />
          </div>
        </div>
      </Card>
    </div>
  );
}
```

## 📊 数据流向

### 单向数据流

```
用户操作 (User Action)
    ↓
事件处理 (Event Handler)
    ↓
状态更新 (State Update)
    ↓
组件重渲染 (Re-render)
    ↓
UI更新 (UI Update)
```

### 场景切换流程

```
用户点击场景按钮
    ↓
setCurrentScenario('medical')
    ↓
ScenarioContext 更新
    ↓
所有订阅组件重渲染
    ↓
UI显示医疗场景内容
```

### 页面导航流程

```
用户点击页面链接
    ↓
onNavigate('health')
    ↓
navigateTo() 检查页面类型
    ↓
├─ showInNav === true
│   └─ 重置页面栈: ['health']
│
└─ showInNav === false
    └─ 压入页面栈: [...pageStack, 'health']
    ↓
页面栈更新
    ↓
currentPage = pageStack[length - 1]
    ↓
加载对应页面组件
```

## 🎨 设计模式

### 1. 组合模式 (Composition Pattern)

```tsx
// 卡片组件组合
<Card>
  <CardHeader>
    <CardTitle>标题</CardTitle>
    <CardDescription>描述</CardDescription>
  </CardHeader>
  <CardContent>
    内容
  </CardContent>
  <CardFooter>
    底部操作
  </CardFooter>
</Card>
```

### 2. 高阶组件模式 (HOC Pattern)

```tsx
// 页面模板包装器
function withNavigation<P extends object>(
  Component: React.ComponentType<P>
) {
  return function WrappedComponent(props: P) {
    return (
      <div className="space-y-5 pb-8">
        <Component {...props} />
      </div>
    );
  };
}
```

### 3. 渲染属性模式 (Render Props Pattern)

```tsx
// 场景选择器
<ScenarioSelector
  render={({ currentScenario, setScenario }) => (
    <div>
      <button onClick={() => setScenario('travel')}>
        出行 {currentScenario === 'travel' && '✓'}
      </button>
    </div>
  )}
/>
```

### 4. 上下文模式 (Context Pattern)

```tsx
// 场景上下文提供者
<ScenarioContext.Provider value={{ currentScenario, setCurrentScenario }}>
  <App />
</ScenarioContext.Provider>

// 使用上下文
function Component() {
  const { currentScenario } = useContext(ScenarioContext);
  return <div>{currentScenario}</div>;
}
```

## 🚀 性能优化

### 1. 组件懒加载

```typescript
// 页面模板按需加载
const HomeTemplate = lazy(() => import('./components/templates/HomeTemplate'));
const HealthTemplate = lazy(() => import('./components/templates/HealthTemplate'));

// 使用 Suspense
<Suspense fallback={<Skeleton />}>
  <HomeTemplate />
</Suspense>
```

### 2. 记忆化优化

```typescript
// 记忆化页面配置
const pages = useMemo(() => ({
  'home': { title: '今日', component: HomeTemplate },
  // ...
}), []);

// 记忆化导航函数
const navigateTo = useCallback((page: PageType) => {
  // ...
}, [pageStack]);
```

### 3. 虚拟滚动

```tsx
// 长列表优化
import { useVirtualizer } from '@tanstack/react-virtual';

function LongList({ items }) {
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80,
  });
  
  return (
    <div ref={parentRef}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(item => (
          <div key={item.index} style={item.style}>
            {items[item.index]}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## 📱 响应式设计

### 断点系统

```css
/* Tailwind 默认断点 */
sm: 640px   /* 小屏幕 */
md: 768px   /* 中等屏幕 */
lg: 1024px  /* 大屏幕 */
xl: 1280px  /* 超大屏幕 */

/* 本应用固定为移动端 */
max-width: 390px  /* iPhone 12/13/14 */
```

### 固定容器

```tsx
// 所有固定元素统一居中
<div style={{ maxWidth: '390px', margin: '0 auto' }}>
  {/* 内容 */}
</div>
```

## 🔐 数据持久化

### LocalStorage 策略

```typescript
// 存储宠物档案
const savePetProfile = (profile: PetProfile) => {
  localStorage.setItem('pet_profile', JSON.stringify(profile));
};

// 读取宠物档案
const loadPetProfile = (): PetProfile | null => {
  const data = localStorage.getItem('pet_profile');
  return data ? JSON.parse(data) : null;
};

// 存储场景偏好
const saveScenarioPreference = (scenario: ScenarioType) => {
  localStorage.setItem('preferred_scenario', scenario);
};
```

## 🎯 未来扩展

### 1. 多宠物支持

```typescript
interface AppState {
  pets: PetProfile[];
  currentPetId: string;
}

// 宠物切换器
function PetSwitcher() {
  const [currentPetId, setCurrentPetId] = useState('pet-1');
  const pets = usePets();
  
  return (
    <Select value={currentPetId} onValueChange={setCurrentPetId}>
      {pets.map(pet => (
        <SelectItem key={pet.id} value={pet.id}>
          {pet.name}
        </SelectItem>
      ))}
    </Select>
  );
}
```

### 2. 云端同步

```typescript
// Supabase 集成
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// 同步宠物档案
const syncPetProfile = async (profile: PetProfile) => {
  const { data, error } = await supabase
    .from('pet_profiles')
    .upsert(profile);
  
  return { data, error };
};
```

### 3. 社交功能

```typescript
// 宠物社区
interface Community {
  posts: Post[];
  friends: PetProfile[];
  activities: Activity[];
}

// 分享宠物动态
function SharePost({ petId }: { petId: string }) {
  const [content, setContent] = useState('');
  const [images, setImages] = useState<File[]>([]);
  
  const handleShare = async () => {
    await createPost({ petId, content, images });
  };
  
  return (
    <Card>
      <Textarea value={content} onChange={e => setContent(e.target.value)} />
      <Button onClick={handleShare}>分享</Button>
    </Card>
  );
}
```

## 📚 相关文档

- [README.md](./README.md) - 项目总览
- [guidelines/Guidelines.md](./guidelines/Guidelines.md) - 设计规范
- [guidelines/ColorSystem.md](./guidelines/ColorSystem.md) - 配色系统
- [guidelines/AICameraGuide.md](./guidelines/AICameraGuide.md) - AI相机指南
- [CHANGELOG.md](./CHANGELOG.md) - 更新历史

---

**架构版本**: v1.0  
**最后更新**: 2025-10-11  
**维护者**: Felo Team
