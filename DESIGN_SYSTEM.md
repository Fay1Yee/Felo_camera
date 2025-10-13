# Felo 设计系统规范

> Nothing OS 风格的极简宠物管理应用设计系统

## 📐 设计理念

### 核心原则

**1. 极简主义 (Minimalism)**
- 去除冗余装饰，保留核心功能
- 方正的几何形状，轻微的圆角
- 低对比度的配色，柔和的视觉体验

**2. 功能优先 (Function First)**
- 清晰的信息层级
- 高效的操作流程
- 直观的交互反馈

**3. 温暖友好 (Warm & Friendly)**
- 宠物视角的可爱文案
- 亮黄色的活力点缀
- 轻松愉悦的使用体验

**4. 专业可信 (Professional & Trustworthy)**
- 官方证件样式设计
- 精确的数据展示
- 可靠的健康管理

## 🎨 色彩系统 - 三色调设计

> **核心理念**：严格限制为白色、黄色、灰色三种主色调，营造极简、纯净、专业的视觉体验

### 品牌主色 (Brand Colors) - 黄色系

```css
/* 黄色系 - 品牌核心色，唯一彩色 */
--color-brand-primary: #FFD84D;    /* 主黄色：按钮、强调、活跃状态 */
--color-brand-secondary: #FFFBEA;  /* 浅黄色：卡片背景、选中背景 */
--color-brand-accent: #F5C842;     /* 深黄色：Hover 状态、按压反馈 */
--color-brand-light: #FFF9E6;      /* 极浅黄：背景装饰、微妙强调 */
```

**使用场景：**
- ✅ 主要操作按钮（AI相机、确认按钮）
- ✅ 强调信息和重要提示
- ✅ Tab 激活状态背景
- ✅ 输入框焦点边框
- ✅ 进度条和加载指示器
- ✅ 品牌标识和Logo

**禁止场景：**
- ❌ 大面积背景色
- ❌ 长文本颜色
- ❌ 过度使用导致视觉疲劳

### 中性色系 (Neutral Colors) - 白色与灰色

```css
/* 白色系 - 纯净背景 */
--color-white: #FFFFFF;            /* 纯白：卡片、按钮背景 */
--color-white-soft: #FEFEFE;       /* 柔和白：主背景微调 */

/* 灰色系 - 从浅到深的完整灰度 */
--color-gray-50: #FAFAFA;          /* 主背景 */
--color-gray-100: #F5F5F5;         /* 次级背景、禁用背景 */
--color-gray-200: #EEEEEE;         /* 分隔线、边框 */
--color-gray-300: #E0E0E0;         /* 边框、输入框边框 */
--color-gray-400: #BDBDBD;         /* 图标未激活、占位文字 */
--color-gray-500: #9E9E9E;         /* 次要文字、说明文字 */
--color-gray-600: #757575;         /* 辅助文字 */
--color-gray-700: #616161;         /* 深灰文字 */
--color-gray-800: #424242;         /* 主文字、标题 */
--color-gray-900: #212121;         /* 强调文字、最深灰 */
```

### 语义色彩 (Semantic Colors) - 三色调版本

```css
/* 状态反馈色 - 仅使用三色调 */
--color-success: #757575;          /* 成功：中灰色 */
--color-warning: #F5C842;          /* 警告：深黄色 */
--color-error: #616161;            /* 错误：深灰色 */
--color-info: #9E9E9E;             /* 信息：浅灰色 */
```

**三色调语义规范：**

| 状态 | 颜色 | 使用场景 | 示例 |
|------|------|---------|------|
| 成功 | `#757575` (中灰) | 操作成功、健康正常、完成状态 | "✅ 保存成功" |
| 警告 | `#F5C842` (深黄) | 需要注意、即将到期、重要提醒 | "⚠️ 疫苗即将到期" |
| 错误 | `#616161` (深灰) | 操作失败、异常状态、必填项 | "❌ 保存失败" |
| 信息 | `#9E9E9E` (浅灰) | 提示说明、辅助信息 | "ℹ️ 点击查看详情" |

### 灰度色阶 (Gray Scale)

```css
/* 中性灰度 - 从浅到深 */
--color-gray-50: #FAFAFA;    /* 主背景 */
--color-gray-100: #F5F5F5;   /* 次级背景、禁用背景 */
--color-gray-200: #EEEEEE;   /* 分隔线、边框 */
--color-gray-300: #E0E0E0;   /* 边框、输入框边框 */
--color-gray-400: #BDBDBD;   /* 图标未激活、占位文字 */
--color-gray-500: #9E9E9E;   /* 次要文字、说明文字 */
--color-gray-600: #757575;   /* 辅助文字 */
--color-gray-700: #616161;   /* 深灰文字 */
--color-gray-800: #424242;   /* 主文字、标题 */
--color-gray-900: #212121;   /* 强调文字 */
```

**文字颜色使用：**
```css
/* 文字层级 - 三色调版本 */
--color-text-primary: #424242;     /* 主文字：标题、正文 */
--color-text-secondary: #9E9E9E;   /* 次要文字：说明、时间 */
--color-text-tertiary: #BDBDBD;    /* 辅助文字：占位符、禁用 */
--color-text-inverse: #FFFFFF;     /* 反色文字：深色背景上 */
--color-text-accent: #F5C842;      /* 强调文字：深黄高亮 */
```

**背景颜色使用：**
```css
/* 背景层级 - 三色调版本 */
--color-background: #FAFAFA;         /* 主背景：页面底色 */
--color-surface: #FFFFFF;            /* 卡片背景：纯白 */
--color-surface-secondary: #FFFBEA;  /* 特殊卡片：浅黄 */
--color-surface-tertiary: #F5F5F5;   /* 次级背景：浅灰 */
--color-surface-accent: #FFF9E6;     /* 强调背景：极浅黄 */
```

### 三色调配色最佳实践

**1. 对比度要求**
```
AAA 级（7:1）  - 主文字 #424242 on #FAFAFA ✅
AA 级（4.5:1） - 次要文字 #9E9E9E on #FFFFFF ✅
最低要求（3:1）- 图标 #BDBDBD on #FFFFFF ✅
```

**2. 三色调配色组合**
```css
/* 推荐组合 - 仅使用白、黄、灰 */
.recommended-combos {
  /* 黄+白 - 主要按钮 */
  background: #FFD84D;
  color: #424242;
  
  /* 白+灰 - 次要信息 */
  background: #FFFFFF;
  color: #9E9E9E;
  
  /* 浅黄+深灰 - 强调卡片 */
  background: #FFFBEA;
  color: #424242;
  
  /* 浅灰+深灰 - 禁用状态 */
  background: #F5F5F5;
  color: #BDBDBD;
}
```

**3. 严格禁止的颜色**
```css
/* ❌ 完全禁止使用的颜色 */
.forbidden-colors {
  /* 任何绿色 */
  color: #66BB6A; /* ❌ */
  color: #2F5233; /* ❌ */
  color: #EDF7ED; /* ❌ */
  
  /* 任何蓝色 */
  color: #42A5F5; /* ❌ */
  color: #1976D2; /* ❌ */
  
  /* 任何红色 */
  color: #EF5350; /* ❌ */
  color: #D32F2F; /* ❌ */
  
  /* 任何橙色 */
  color: #FFA726; /* ❌ */
  color: #F57C00; /* ❌ */
  
  /* 任何紫色、粉色等其他彩色 */
  color: #9C27B0; /* ❌ */
  color: #E91E63; /* ❌ */
}
```

**4. 颜色使用原则**
- ✅ **主导色**：白色 - 占据界面70%以上面积
- ✅ **强调色**：黄色 - 仅用于关键操作和品牌元素，占比不超过10%
- ✅ **支撑色**：灰色 - 用于文字、边框、图标，占比20%左右
- ❌ **禁止**：任何其他颜色，包括绿、蓝、红、橙等

## 📏 间距系统

### 间距标尺 (Spacing Scale)

```css
/* 紧凑且高效的间距系统 */
--space-1: 4px;    /* 最小间距：图标与文字 */
--space-2: 8px;    /* 超小间距：标签间距 */
--space-3: 12px;   /* 小间距：按钮内边距 */
--space-4: 16px;   /* 基础间距：卡片内边距 */
--space-5: 20px;   /* 标准间距：页面边距 */
--space-6: 24px;   /* 中等间距：区块间距 */
--space-8: 32px;   /* 大间距：章节间距 */
--space-10: 40px;  /* 超大间距：页面分隔 */
```

### 间距应用规范

**1. 页面级间距**
```tsx
// 页面左右边距 - 统一使用 20px
<div className="px-5">  {/* px-5 = 20px */}
  页面内容
</div>

// 页面底部安全距离
<div className="pb-8">  {/* pb-8 = 32px */}
  底部内容
</div>
```

**2. 组件级间距**
```tsx
// 卡片内边距 - 16px
<Card className="p-4">
  卡片内容
</Card>

// 卡片之间间距 - 20px
<div className="space-y-5">
  <Card />
  <Card />
</div>
```

**3. 元素级间距**
```tsx
// 图标与文字 - 8px
<div className="flex items-center gap-2">
  <Icon />
  <span>文字</span>
</div>

// 按钮内边距 - 12px 垂直 16px 水平
<Button className="px-4 py-3">
  按钮文字
</Button>
```

### 间距决策树

```
选择间距：
├─ 同一元素内部 → space-1 (4px) / space-2 (8px)
├─ 相关元素之间 → space-3 (12px) / space-4 (16px)
├─ 组件之间     → space-5 (20px) / space-6 (24px)
└─ 章节之间     → space-8 (32px) / space-10 (40px)
```

## 🔘 圆角系统

### 圆角标尺 (Border Radius)

```css
/* 轻微且一致的圆角 */
--radius-xs: 2px;      /* 极小圆角：分隔线、细边框 */
--radius-sm: 4px;      /* 小圆角：输入框、标签 */
--radius-md: 6px;      /* 中圆角：按钮（默认） */
--radius-lg: 8px;      /* 大圆角：卡片（默认） */
--radius-xl: 12px;     /* 超大圆角：特殊元素 */
--radius-full: 9999px; /* 完全圆形：头像、圆形按钮 */
```

### 圆角应用规范

| 元素类型 | 圆角值 | Tailwind 类 | 示例 |
|---------|--------|------------|------|
| 分隔线、边框 | `2px` | `rounded-sm` | 点阵分隔线 |
| 输入框、标签 | `4px` | `rounded` | Input、Badge |
| 按钮 | `6px` | `rounded-md` | Button |
| 卡片 | `8px` | `rounded-lg` | Card |
| 图片、弹窗 | `12px` | `rounded-xl` | Dialog |
| 头像、圆形按钮 | `9999px` | `rounded-full` | Avatar、AI Camera |

### 特殊规则

**1. 嵌套圆角**
```tsx
// 外层卡片 8px，内层元素 4px
<Card className="rounded-lg p-4">
  <div className="rounded bg-gray-100 p-3">
    内容
  </div>
</Card>
```

**2. 宠物身份证**
```tsx
// 证件照片框 - 轻微圆角保持官方感
<div className="rounded-sm border-2 border-[#FFD84D]">
  <img className="rounded-sm" />
</div>
```

**3. AI 相机按钮**
```tsx
// 完全圆形 - 视觉焦点
<button className="w-14 h-14 rounded-full bg-[#FFD84D]">
  <Camera />
</button>
```

## 🎭 阴影系统

### 阴影标尺 (Elevation)

```css
/* 极轻微的阴影 - Nothing OS 风格 */
--elevation-1: 0 1px 2px rgba(0, 0, 0, 0.04);  /* 轻微浮起 */
--elevation-2: 0 1px 3px rgba(0, 0, 0, 0.06);  /* 中等浮起 */
--elevation-3: 0 2px 6px rgba(0, 0, 0, 0.08);  /* 明显浮起 */
```

### 阴影应用规范

**1. 层级关系**
```
无阴影 (flat)     - 主背景、文字
elevation-1       - 卡片、输入框
elevation-2       - 悬浮卡片、下拉菜单
elevation-3       - 弹窗、浮动按钮
```

**2. 使用示例**
```tsx
// 卡片 - 轻微阴影
<Card style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
  内容
</Card>

// AI 相机按钮 - 中等阴影
<button style={{ boxShadow: '0 2px 6px rgba(0, 0, 0, 0.08)' }}>
  <Camera />
</button>

// 弹窗 - 明显阴影（少用）
<Dialog style={{ boxShadow: '0 2px 6px rgba(0, 0, 0, 0.08)' }}>
  内容
</Dialog>
```

**3. 禁止使用**
```css
/* ❌ 避免 */
.avoid-shadows {
  /* 过重的阴影 */
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  
  /* 彩色阴影 */
  box-shadow: 0 4px 8px rgba(255, 216, 77, 0.3);
  
  /* 内阴影 */
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
}
```

## ✍️ 字体系统

### 字体家族 (Font Family)

```css
/* 主字体 - 系统默认 */
font-family: -apple-system, BlinkMacSystemFont, 
             'SF Pro Display', 'Segoe UI', 'Roboto', 
             'Helvetica Neue', Arial, sans-serif;

/* 等宽字体 - 代码、数据 */
font-family: 'SF Mono', Monaco, 'Cascadia Code', 
             'Roboto Mono', Consolas, 'Courier New', monospace;
```

### 字号标尺 (Font Size)

```css
/* 字号 / 行高 */
--text-display: 32px / 44px;   /* 大标题 */
--text-title: 20px / 32px;     /* 标题 */
--text-body: 15px / 26px;      /* 正文（默认） */
--text-caption: 13px / 20px;   /* 说明文字 */
--text-mono: 13px / 20px;      /* 等宽字体 */
```

### 字重系统 (Font Weight)

```css
/* 轻量化字重 - Nothing OS 特色 */
--font-weight-normal: 350;     /* 常规 - 正文 */
--font-weight-medium: 450;     /* 中等 - 标题、按钮 */

/* 特殊场景 */
font-weight: 400;              /* 标准正文 */
font-weight: 500;              /* 次要强调 */
font-weight: 600;              /* 重要强调 */
font-weight: 700;              /* 超级强调（性格词云） */
```

### 字体应用规范

**1. HTML 标签默认样式**
```css
h1 { font-size: 32px; font-weight: 450; line-height: 44px; }  /* Display */
h2 { font-size: 20px; font-weight: 450; line-height: 32px; }  /* Title */
h3, h4, p { font-size: 15px; font-weight: 350; line-height: 26px; } /* Body */
small { font-size: 13px; font-weight: 350; line-height: 20px; }  /* Caption */
```

**2. 自定义文字样式类**
```tsx
// Display - 页面主标题
<h1 className="text-display">Felo</h1>

// Title - 卡片标题
<h2 className="text-title">宠物档案</h2>

// Body - 正文（默认，通常不需要类名）
<p>这是正文内容</p>

// Caption - 说明文字
<small className="text-caption">2023年10月12日</small>

// Mono - 代码、芯片编号
<code className="text-mono">CN900012345678</code>
```

**3. 字号限制**
```
⚠️ 重要：不要在代码中使用 Tailwind 的字号类
❌ 禁止：text-xl, text-2xl, text-lg, text-sm
✅ 使用：text-display, text-title, text-body, text-caption
或者不加类名使用 HTML 语义标签（h1, h2, p, small）
```

### 行高规范

```css
/* 行高比例 */
Display:  44/32 = 1.375  /* 标题：较松散 */
Title:    32/20 = 1.6    /* 小标题：标准 */
Body:     26/15 = 1.733  /* 正文：舒适阅读 */
Caption:  20/13 = 1.538  /* 说明：紧凑 */
```

### 字体优化

```css
/* 字体渲染优化 */
-webkit-font-smoothing: antialiased;      /* macOS/iOS 抗锯齿 */
-moz-osx-font-smoothing: grayscale;       /* Firefox 抗锯齿 */
text-rendering: optimizeLegibility;       /* 优化可读性 */
```

## 🎨 点阵装饰系统

### 点阵图案类型

```css
/* 1. 点阵背景 - 装饰性背景 */
.dot-grid-bg {
  background-image: radial-gradient(
    circle, 
    currentColor 1px, 
    transparent 1px
  );
  background-size: 8px 8px;
  opacity: 0.05;
}

/* 2. 点阵分割线 - 虚线效果 */
.dot-divider {
  height: 1px;
  background-image: linear-gradient(
    to right, 
    currentColor 33%, 
    transparent 0%
  );
  background-size: 6px 1px;
  opacity: 0.3;
}

/* 3. 点阵边框 - 虚线边框 */
.dot-border {
  border: 1px dashed currentColor;
  opacity: 0.2;
}

/* 4. 点阵光晕 - 强调装饰 */
.dot-halo::before {
  content: '';
  position: absolute;
  inset: -12px;
  background-image: radial-gradient(
    circle, 
    currentColor 1.5px, 
    transparent 1.5px
  );
  background-size: 10px 10px;
  opacity: 0.08;
}
```

### 点阵应用场景

**1. 卡片背景装饰**
```tsx
<Card className="relative">
  <div className="absolute inset-0 dot-grid-bg text-[#FFD84D]" />
  <div className="relative">
    内容
  </div>
</Card>
```

**2. 身份证背景**
```tsx
<div className="relative bg-white">
  <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] opacity-5" />
  <div className="relative p-4">
    身份证内容
  </div>
</div>
```

**3. 分隔线**
```tsx
<hr className="dot-divider text-[#BDBDBD]" />
```

**4. AI 相机按钮光晕**
```tsx
<div className="relative">
  <div className="absolute inset-0 dot-grid-bg text-[#2F5233] rounded-full scale-150 opacity-10" />
  <button className="relative w-14 h-14 rounded-full bg-[#FFD84D]">
    <Camera />
  </button>
</div>
```

## 📱 布局系统

### 屏幕规格

```
移动端尺寸: 390px × 844px (iPhone 12/13/14)
设计稿尺寸: 390px × 844px @2x
最大宽度: 390px (居中显示)
```

### 固定区域高度

```css
/* 顶部固定区域 */
状态栏:       44px    (top: 0, z-50)
应用头部:     60px    (top: 44px, z-40)
总高度:       104px   (内容区 padding-top)

/* 底部固定区域 */
底部导航:     44px    (bottom: 32px, z-40)
Home指示器:   32px    (bottom: 0, z-50)
总高度:       76px    (内容区 padding-bottom)
```

### 安全区域

```tsx
// 主内容区域
<div className="flex-1 overflow-y-auto px-5" 
     style={{ 
       paddingTop: '104px',    // 顶部固定区域
       paddingBottom: '76px'   // 底部固定区域
     }}>
  页面内容
</div>
```

### 栅格系统

```tsx
// 2列布局 - 常用于功能按钮
<div className="grid grid-cols-2 gap-3">
  <Button />
  <Button />
</div>

// 3列布局 - 常用于数据展示
<div className="grid grid-cols-3 gap-4">
  <Card />
  <Card />
  <Card />
</div>

// 4列布局 - 少用
<div className="grid grid-cols-4 gap-2">
  <Icon />
  <Icon />
  <Icon />
  <Icon />
</div>
```

### 响应式断点

```css
/* 固定移动端，不使用响应式断点 */
max-width: 390px;
margin: 0 auto;

/* 如需扩展，使用 Tailwind 默认断点 */
sm: 640px   /* 小屏 - 暂不使用 */
md: 768px   /* 中屏 - 暂不使用 */
lg: 1024px  /* 大屏 - 暂不使用 */
```

## 🎯 交互规范

### 按钮状态

```tsx
// 默认状态
<Button className="bg-[#FFD84D] text-[#424242]">
  按钮文字
</Button>

// Hover 状态
<Button className="bg-[#FFD84D] hover:bg-[#F5C842]">
  按钮文字
</Button>

// 激活状态
<Button className="bg-[#F5C842] text-[#424242]">
  按钮文字
</Button>

// 禁用状态
<Button disabled className="bg-[#F5F5F5] text-[#BDBDBD]">
  按钮文字
</Button>
```

### 过渡动画

```css
/* 标准过渡 - 200ms */
transition: all 0.2s ease;

/* 快速过渡 - 150ms */
transition: all 0.15s ease;

/* 慢速过渡 - 300ms */
transition: all 0.3s ease;
```

### 点击区域

```
最小点击区域: 44px × 44px
推荐点击区域: 48px × 48px
图标按钮: 40px × 40px (最小)
```

### 反馈机制

```tsx
// Hover 反馈
hover:bg-[#F5F5F5]       // 浅灰背景
hover:bg-[#F5C842]       // 黄色深化
hover:scale-105          // 轻微放大

// 按压反馈
active:scale-95          // 轻微缩小
active:bg-[#F5C842]      // 颜色加深

// 禁用状态
disabled:opacity-50      // 半透明
disabled:cursor-not-allowed  // 禁用光标
```

## 📐 组件规范

### Card 卡片

```tsx
// 标准卡片
<Card className="p-4 bg-white" 
      style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
  内容
</Card>

// 浅黄卡片 - 强调
<Card className="p-4 bg-[#FFFBEA]">
  重要内容
</Card>

// 带点阵背景的卡片
<Card className="p-4 relative">
  <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] opacity-5" />
  <div className="relative">
    内容
  </div>
</Card>
```

### Button 按钮

```tsx
// 主按钮 - 黄色
<Button className="bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242]">
  确定
</Button>

// 次要按钮 - 灰色
<Button variant="ghost" className="hover:bg-[#F5F5F5]">
  取消
</Button>

// 圆形图标按钮
<Button className="w-10 h-10 p-0 rounded-full bg-[#FFD84D]">
  <Icon />
</Button>
```

### Badge 徽章

```tsx
// 成功徽章 - 绿色
<Badge className="bg-[#EDF7ED] text-[#2F5233]">
  已认证
</Badge>

// 警告徽章 - 橙色
<Badge className="bg-[#FFF3E0] text-[#F57C00]">
  即将到期
</Badge>

// 信息徽章 - 灰色
<Badge className="bg-[#F5F5F5] text-[#9E9E9E]">
  进行中
</Badge>
```

### Input 输入框

```tsx
// 标准输入框
<Input 
  className="rounded-md border-[#E0E0E0] focus:border-[#FFD84D]"
  placeholder="请输入..."
/>

// 禁用输入框
<Input 
  disabled
  className="bg-[#F5F5F5] text-[#BDBDBD]"
/>
```

### 数据可视化 - 三色调版本

```typescript
// 严格限制为三色调的图表配色
const chartColors = {
  primary: '#FFD84D',      // 主数据 - 黄色
  secondary: '#757575',    // 次要数据 - 中灰
  tertiary: '#BDBDBD',     // 第三数据 - 浅灰
  quaternary: '#F5C842',   // 第四数据 - 深黄
  quinary: '#424242'       // 第五数据 - 深灰
};

// 渐变色彩（仅使用三色调）
const gradientColors = {
  yellowToGray: ['#FFD84D', '#757575'],    // 黄到灰
  lightToDeep: ['#F5F5F5', '#424242'],     // 浅灰到深灰
  yellowShades: ['#FFFBEA', '#F5C842']     // 浅黄到深黄
};
```

### 图表样式 - 三色调版本

```typescript
// 折线图 - 使用黄色主线
<Line 
  stroke="#FFD84D"
  strokeWidth={2.5}
  dot={{ r: 4, fill: '#FFD84D' }}
/>

// 柱状图 - 黄色主色，灰色对比
<Bar 
  fill="#FFD84D"
  radius={[4, 4, 0, 0]}  // 顶部圆角
/>

// 饼图 - 三色调分段
<Pie 
  dataKey="value"
  nameKey="name"
  colors={['#FFD84D', '#757575', '#BDBDBD']}
/>

// 面积图 - 黄色渐变
<Area 
  fill="url(#yellowGradient)"
  stroke="#FFD84D"
/>

// 渐变定义
<defs>
  <linearGradient id="yellowGradient" x1="0" y1="0" x2="0" y2="1">
    <stop offset="5%" stopColor="#FFD84D" stopOpacity={0.8}/>
    <stop offset="95%" stopColor="#FFD84D" stopOpacity={0.1}/>
  </linearGradient>
</defs>
```

## 🎭 动画系统

### 过渡动画

```css
/* 淡入上升 */
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

/* 使用 */
animation: fadeInUp 0.5s ease-out;
```

### 交互动画

```tsx
// Hover 放大
<div className="transition-transform hover:scale-105">
  内容
</div>

// 点击缩小
<button className="transition-transform active:scale-95">
  按钮
</button>

// 淡入淡出
<div className="transition-opacity hover:opacity-80">
  内容
</div>
```

## ✅ 使用检查清单

### 色彩检查 - 三色调版本
- [ ] 主色调使用 #FFD84D（亮黄）- 唯一彩色
- [ ] 背景色使用 #FAFAFA（米白）和 #FFFFFF（纯白）
- [ ] 文字主色使用 #424242（深灰）
- [ ] 文字次色使用 #9E9E9E（中灰）
- [ ] 严格禁止使用绿色、蓝色、红色、橙色等其他彩色
- [ ] 对比度符合 WCAG AA 标准
- [ ] 黄色使用比例不超过界面的10%
- [ ] 白色占据界面70%以上面积

### 间距检查
- [ ] 页面边距使用 20px (px-5)
- [ ] 卡片内边距使用 16px (p-4)
- [ ] 卡片间距使用 20px (space-y-5)
- [ ] 元素间距使用 8-12px (gap-2/gap-3)

### 圆角检查
- [ ] 按钮使用 6px (rounded-md)
- [ ] 卡片使用 8px (rounded-lg)
- [ ] 输入框使用 4px (rounded)
- [ ] 头像使用 9999px (rounded-full)

### 字体检查
- [ ] 不使用 Tailwind 字号类（text-xl 等）
- [ ] 使用语义化标签（h1, h2, p, small）
- [ ] 或使用预设类（text-display, text-title 等）
- [ ] 字重使用 350/450

### 阴影检查
- [ ] 卡片使用轻微阴影（elevation-1）
- [ ] 避免过重阴影
- [ ] 避免彩色阴影

### 交互检查
- [ ] 过渡动画使用 0.2s
- [ ] Hover 状态有视觉反馈
- [ ] 禁用状态明显区分
- [ ] 最小点击区域 44px

## 📚 参考资源

- [Nothing OS 设计语言](https://www.nothing.tech/)
- [Material Design 指南](https://material.io/design)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/)
- [WCAG 无障碍标准](https://www.w3.org/WAI/WCAG21/quickref/)

---

**设计系统版本**: v1.0  
**最后更新**: 2025-10-12  
**维护者**: Felo Design Team
