import { useState, useContext } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from '../ui/sheet';
import { 
  Heart, 
  Activity, 
  Calendar, 
  ChevronRight, 
  Clock, 
  Droplet, 
  Moon, 
  Footprints, 
  Sun,
  Home as HomeIcon,
  Plane,
  Shield,
  Building2,
  Layers,
  Camera
} from 'lucide-react';
import { ScenarioContext } from '../../App';

interface HomeTemplateProps {
  onNavigate: (page: string) => void;
}

export function HomeTemplate({ onNavigate }: HomeTemplateProps) {
  const [showScenarioSelector, setShowScenarioSelector] = useState(false);
  const { currentScenario, setCurrentScenario } = useContext(ScenarioContext);

  const scenarios = [
    {
      id: 'travel',
      name: '出行模式',
      icon: Plane,
      color: '#42A5F5',
      bgColor: '#E3F2FD',
      description: '设备在线 · 证件齐全',
      status: '活跃'
    },
    {
      id: 'home',
      name: '居家模式',
      icon: HomeIcon,
      color: '#FFA726',
      bgColor: '#FFF3E0',
      description: '环境舒适 · 日常照护',
      status: '待启用'
    },
    {
      id: 'medical',
      name: '医疗模式',
      icon: Heart,
      color: '#66BB6A',
      bgColor: '#E8F5E9',
      description: '健康监测 · 用药提醒',
      status: '待启用'
    },
    {
      id: 'city',
      name: '城市管理',
      icon: Building2,
      color: '#AB47BC',
      bgColor: '#F3E5F5',
      description: '登记信息 · 社区服务',
      status: '待启用'
    }
  ];

  const activeScenario = scenarios.find(s => s.id === currentScenario) || scenarios[0];

  const petProfile = {
    name: "小白",
    breed: "田园猫",
    avatar: "https://images.unsplash.com/photo-1684707458757-1d33524680d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHBvcnRyYWl0fGVufDF8fHx8MTc2MDA5NjkyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    tags: ["活泼", "健康"]
  };

  // 宠物性格词云 - 可爱形容词（基于日常习惯分析）
  // 紧密居中布局，黄灰双色系统，最大的词在中间
  const personalityTags = [
    // 第一行：小词
    { text: "温柔", size: 14, isYellow: false },
    { text: "聪明伶俐", size: 16, isYellow: true },
    { text: "爱玩耍", size: 15, isYellow: false },
    // 第二行：最大的核心词在中间
    { text: "超级黏人", size: 26, isYellow: true },
    // 第三行：中等词
    { text: "小吃货", size: 18, isYellow: false },
    { text: "好奇宝宝", size: 20, isYellow: true }
  ];

  const todayStats = {
    exercise: { value: "45分", label: "运动", icon: Footprints },
    water: { value: "350ml", label: "饮水", icon: Droplet },
    sleep: { value: "12小时", label: "睡眠", icon: Moon },
    mood: { value: "良好", label: "活跃", icon: Activity }
  };

  const todayReminders = [
    { 
      id: 1, 
      title: "主人，我今天要去打疫苗啦", 
      time: "今天 14:00",
      type: "urgent"
    },
    { 
      id: 2, 
      title: "主人，我今天又重了一点啦", 
      time: "2小时前",
      type: "info"
    }
  ];

  // Get current time greeting
  const hour = new Date().getHours();
  const greeting = hour < 12 ? '早上好' : hour < 18 ? '下午好' : '晚上好';
  
  // Format current date
  const now = new Date();
  const dateStr = now.toLocaleDateString('zh-CN', { 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric',
    weekday: 'long'
  });

  return (
    <div className="pb-6">
      <div className="pt-5 space-y-5">
        {/* Greeting Section */}
        <div>
          <h2 className="text-title mb-0.5 text-[#424242]">{greeting}</h2>
          <p className="text-caption text-[#9E9E9E]">{dateStr}</p>
        </div>

      {/* Current Scenario Status - 新极简主义 */}
      <Card 
        onClick={() => onNavigate('scenarios')}
        className="p-4 bg-white relative overflow-hidden cursor-pointer transition-all"
        style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
      >
        <div className="absolute top-0 right-0 w-32 h-32 dot-grid-bg" style={{ color: activeScenario.color }} />
        <div className="relative flex items-center gap-3">
          <div className="w-11 h-11 rounded-md flex items-center justify-center flex-shrink-0" style={{ backgroundColor: activeScenario.bgColor }}>
            <activeScenario.icon className="w-5 h-5" style={{ color: activeScenario.color }} strokeWidth={1.5} />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-0.5">
              <h3 className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>当前场景：{activeScenario.name}</h3>
              <Badge className="px-2 py-0.5 rounded bg-[#EDF7ED] text-[#2E7D32] text-[11px] border-none">
                {activeScenario.status}
              </Badge>
            </div>
            <p className="text-caption text-[#9E9E9E]">{activeScenario.description}</p>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={(e) => {
              e.stopPropagation();
              setShowScenarioSelector(true);
            }}
            className="w-9 h-9 p-0 rounded-md hover:bg-[#F5F5F5] flex-shrink-0"
          >
            <Layers className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
          </Button>
        </div>
      </Card>

      {/* Scenario Selector Sheet */}
      <Sheet open={showScenarioSelector} onOpenChange={setShowScenarioSelector}>
        <SheetContent side="bottom" className="bg-white rounded-t-2xl border-none p-0">
          <div className="px-5 pt-5 pb-8">
            <SheetHeader className="mb-5">
              <div className="flex items-center justify-between">
                <SheetTitle className="text-title text-[#424242]">切换场景模式</SheetTitle>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setShowScenarioSelector(false)}
                  className="h-8 w-8 p-0 rounded-md hover:bg-[#F5F5F5]"
                >
                  ✕
                </Button>
              </div>
              <SheetDescription className="text-caption text-[#9E9E9E] text-left">
                选择适合当前情境的场景模式，系统会自动调整功能和提醒
              </SheetDescription>
            </SheetHeader>

            <div className="grid grid-cols-2 gap-3">
              {scenarios.map((scenario) => {
                const isActive = currentScenario === scenario.id;
                return (
                  <button
                    key={scenario.id}
                    onClick={() => {
                      setCurrentScenario(scenario.id);
                      setTimeout(() => setShowScenarioSelector(false), 300);
                    }}
                    className={`p-4 rounded-lg border-2 transition-all text-left ${
                      isActive
                        ? 'border-[#FFD84D] bg-[#FFFBEA]'
                        : 'border-[#E0E0E0] bg-white hover:border-[#FFD84D]/50'
                    }`}
                  >
                    <div className="flex items-center gap-3 mb-3">
                      <div
                        className="w-11 h-11 rounded-md flex items-center justify-center flex-shrink-0"
                        style={{ backgroundColor: scenario.bgColor }}
                      >
                        <scenario.icon className="w-5 h-5" style={{ color: scenario.color }} strokeWidth={1.5} />
                      </div>
                      {isActive && (
                        <Badge className="px-2 py-0.5 rounded bg-[#EDF7ED] text-[#2E7D32] text-[11px] border-none">
                          当前
                        </Badge>
                      )}
                    </div>
                    <h4 className="text-body text-[#424242] mb-1" style={{ fontWeight: 600 }}>
                      {scenario.name}
                    </h4>
                    <p className="text-caption text-[#9E9E9E]">
                      {scenario.description}
                    </p>
                  </button>
                );
              })}
            </div>
          </div>
        </SheetContent>
      </Sheet>

      {/* Pet Profile Card - ID Card Style - 新极简主义 */}
      <Card 
        onClick={() => onNavigate('profile')}
        className="p-0 bg-white relative overflow-hidden cursor-pointer transition-all"
        style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
      >
        {/* ID Card Header */}
        <div className="bg-gradient-to-r from-[#FFD84D] to-[#F5C842] px-4 py-2.5 relative">
          <div className="absolute inset-0 dot-grid-bg text-white opacity-10" />
          <div className="relative flex items-center justify-between">
            <div>
              <p className="text-caption text-[#424242] mb-0" style={{ fontWeight: 600 }}>宠物身份证</p>
              <p className="text-[11px] text-[#424242]/80">Pet ID Card</p>
            </div>
            <div className="w-7 h-7 rounded-md bg-white/90 flex items-center justify-center">
              <HomeIcon className="w-4 h-4 text-[#FFD84D]" strokeWidth={2} />
            </div>
          </div>
        </div>

        {/* ID Card Content */}
        <div className="p-4">
          <div className="flex items-start gap-3">
            {/* Avatar - Official Photo Frame */}
            <div className="relative flex-shrink-0">
              <div 
                className="w-18 h-22 rounded-md overflow-hidden bg-[#F5F5F5] p-0.5"
                style={{ boxShadow: '0 0 0 1px #FFD84D' }}
              >
                <div className="w-full h-full rounded-sm overflow-hidden">
                  <ImageWithFallback
                    src={petProfile.avatar}
                    alt={petProfile.name}
                    className="w-full h-full object-cover"
                  />
                </div>
              </div>
            </div>

            {/* Pet Info */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1.5">
                <h3 className="text-title text-[#424242]">{petProfile.name}</h3>
                <Badge
                  variant="outline"
                  className="px-1.5 py-0.5 rounded bg-[#EDF7ED] border-none text-[11px] text-[#2E7D32]"
                >
                  已认证
                </Badge>
              </div>
              
              <div className="space-y-1 mb-2">
                <div className="flex items-start">
                  <span className="text-caption text-[#BDBDBD] w-12">品种</span>
                  <span className="text-caption text-[#424242]">{petProfile.breed}</span>
                </div>
                <div className="flex items-start">
                  <span className="text-caption text-[#BDBDBD] w-12">状态</span>
                  <div className="flex gap-1.5">
                    {petProfile.tags.map((tag, index) => (
                      <span key={index} className="text-caption text-[#424242]">{tag}</span>
                    ))}
                  </div>
                </div>
              </div>

              {/* View Detail Button */}
              <Button
                variant="ghost"
                size="sm"
                className="h-7 px-2 -ml-2 rounded-md hover:bg-[#F5F5F5] text-caption text-[#9E9E9E] hover:text-[#424242]"
              >
                查看完整档案
                <ChevronRight className="w-4 h-4 ml-0.5" strokeWidth={1.5} />
              </Button>
            </div>
          </div>

          {/* ID Number Bar */}
          <div className="mt-3 p-2 rounded-md bg-[#F5F5F5]">
            <div className="flex items-center justify-between">
              <span className="text-[11px] text-[#BDBDBD]">登记编号</span>
              <span className="text-mono text-[#424242]" style={{ fontSize: '10px', fontWeight: 600 }}>
                CN-BJ-2023-001234
              </span>
            </div>
          </div>
        </div>

        {/* Official Seal - Decorative */}
        <div className="absolute top-2 right-2 w-11 h-11 rounded-full border border-[#EF5350] opacity-20 flex items-center justify-center">
          <div className="text-[8px] text-[#EF5350] text-center leading-tight" style={{ fontWeight: 700 }}>
            官方<br/>认证
          </div>
        </div>
      </Card>

      {/* Personality Word Cloud - 性格词云 */}
      <Card className="p-4 bg-white relative overflow-hidden" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        {/* Background Pattern */}
        <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] opacity-5" />
        
        <div className="relative">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <span className="text-body text-[#424242]" style={{ fontWeight: 600 }}>性格分析</span>
              <span className="text-caption text-[#9E9E9E]">· 基于日常习惯</span>
            </div>
            <button 
              onClick={() => onNavigate('habits-detail')}
              className="text-caption text-[#9E9E9E] hover:text-[#424242] transition-colors"
            >
              编辑
            </button>
          </div>

          {/* Word Cloud Container - 紧密居中布局 */}
          <div className="py-6">
            {/* 第一行 - 小词 */}
            <div className="flex items-center justify-center gap-3 mb-2">
              {personalityTags.slice(0, 3).map((tag, index) => (
                <div
                  key={index}
                  className="cursor-default transition-all duration-200 hover:scale-110"
                  style={{ 
                    fontSize: `${tag.size}px`,
                    fontWeight: tag.size >= 20 ? 600 : tag.size >= 16 ? 500 : 400,
                    color: tag.isYellow ? '#FFD84D' : '#9E9E9E',
                    animation: `fadeInUp 0.5s ease-out ${index * 0.1}s both`,
                    lineHeight: '1.2'
                  }}
                >
                  {tag.text}
                </div>
              ))}
            </div>

            {/* 第二行 - 最大的核心词 */}
            <div className="flex items-center justify-center mb-2">
              {personalityTags.slice(3, 4).map((tag, index) => (
                <div
                  key={index + 3}
                  className="cursor-default transition-all duration-200 hover:scale-110"
                  style={{ 
                    fontSize: `${tag.size}px`,
                    fontWeight: 700,
                    color: tag.isYellow ? '#FFD84D' : '#9E9E9E',
                    animation: `fadeInUp 0.5s ease-out ${(index + 3) * 0.1}s both`,
                    lineHeight: '1.2'
                  }}
                >
                  {tag.text}
                </div>
              ))}
            </div>

            {/* 第三行 - 中等词 */}
            <div className="flex items-center justify-center gap-4">
              {personalityTags.slice(4, 6).map((tag, index) => (
                <div
                  key={index + 4}
                  className="cursor-default transition-all duration-200 hover:scale-110"
                  style={{ 
                    fontSize: `${tag.size}px`,
                    fontWeight: tag.size >= 20 ? 600 : tag.size >= 16 ? 500 : 400,
                    color: tag.isYellow ? '#FFD84D' : '#9E9E9E',
                    animation: `fadeInUp 0.5s ease-out ${(index + 4) * 0.1}s both`,
                    lineHeight: '1.2'
                  }}
                >
                  {tag.text}
                </div>
              ))}
            </div>
          </div>

          {/* Cute Footer */}
          <div className="mt-2 pt-3 border-t border-[#F5F5F5]">
            <p className="text-caption text-[#BDBDBD] text-center">
              📊 基于 326 天行为数据自动生成
            </p>
          </div>
        </div>
      </Card>

      {/* Quick Actions - Core Features - 新极简主义 */}
      <div>
        <h3 className="text-body mb-3 text-[#424242]">核心功能</h3>
        <div className="grid grid-cols-2 gap-3">
          <Card
            onClick={() => onNavigate('health')}
            className="p-4 bg-white cursor-pointer transition-all"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            <div className="flex items-center gap-2.5 mb-2.5">
              <div className="w-10 h-10 rounded-md bg-[#FFEBEE] flex items-center justify-center">
                <Activity className="w-5 h-5 text-[#EF5350]" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>健康管理</h4>
                <p className="text-caption text-[#BDBDBD]">疫苗·体检</p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-caption text-[#9E9E9E]">3项待办</span>
              <ChevronRight className="w-4 h-4 text-[#E0E0E0]" strokeWidth={1.5} />
            </div>
          </Card>

          <Card
            onClick={() => onNavigate('optimized-life-records')}
            className="p-4 bg-white cursor-pointer transition-all"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            <div className="flex items-center gap-2.5 mb-2.5">
              <div className="w-10 h-10 rounded-md bg-[#E3F2FD] flex items-center justify-center">
                <Camera className="w-5 h-5 text-[#42A5F5]" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>生活记录</h4>
                <p className="text-caption text-[#BDBDBD]">文件上传·管理</p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-caption text-[#9E9E9E]">支持文件上传</span>
              <ChevronRight className="w-4 h-4 text-[#E0E0E0]" strokeWidth={1.5} />
            </div>
          </Card>

          <Card
            onClick={() => onNavigate('habits-detail')}
            className="p-4 bg-white cursor-pointer transition-all"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            <div className="flex items-center gap-2.5 mb-2.5">
              <div className="w-10 h-10 rounded-md bg-[#FFFBEA] flex items-center justify-center">
                <Sun className="w-5 h-5 text-[#FFA726]" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>日常习惯</h4>
                <p className="text-caption text-[#BDBDBD]">作息·饮食</p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-caption text-[#9E9E9E]">今日已打卡</span>
              <ChevronRight className="w-4 h-4 text-[#E0E0E0]" strokeWidth={1.5} />
            </div>
          </Card>

          <Card
            onClick={() => onNavigate('reminder')}
            className="p-4 bg-white cursor-pointer transition-all"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            <div className="flex items-center gap-2.5 mb-2.5">
              <div className="w-10 h-10 rounded-md bg-[#EDF7ED] flex items-center justify-center">
                <Calendar className="w-5 h-5 text-[#66BB6A]" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <h4 className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>提醒事项</h4>
                <p className="text-caption text-[#BDBDBD]">日程·通知</p>
              </div>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-caption text-[#9E9E9E]">2项待办</span>
              <ChevronRight className="w-4 h-4 text-[#E0E0E0]" strokeWidth={1.5} />
            </div>
          </Card>
        </div>
      </div>

      {/* Activity Record Card - 新极简主义 */}
      <div>
        <h3 className="text-body mb-3 text-[#424242]">活动记录</h3>
        <Card className="p-5 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          {/* Title and Link */}
          <div className="flex items-start justify-between mb-4">
            <div>
              <h4 className="text-body mb-0.5 text-[#424242]">主人，这是我今天的表现</h4>
              <p className="text-caption text-[#9E9E9E]">实时行为报告</p>
            </div>
            <Button
              onClick={() => onNavigate('life-records')}
              variant="ghost"
              size="sm"
              className="h-7 px-2 rounded-md hover:bg-[#F5F5F5] text-caption text-[#9E9E9E] hover:text-[#424242] -mr-2"
            >
              查看我的活动
              <ChevronRight className="w-4 h-4 ml-0.5" strokeWidth={1.5} />
            </Button>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-4 gap-2.5 mb-4">
            {Object.values(todayStats).map((stat, index) => {
              const IconComponent = stat.icon;
              const isActive = index === 3; // Last one is active/good
              return (
                <div 
                  key={index}
                  className={`flex flex-col items-center p-2.5 rounded-md ${ isActive ? 'bg-[#EDF7ED]' : 'bg-[#F5F5F5]'
                  }`}
                >
                  <IconComponent 
                    className={`w-5 h-5 mb-1.5 ${
                      index === 0 ? 'text-[#2F5233]' :
                      index === 1 ? 'text-[#42A5F5]' :
                      index === 2 ? 'text-[#9E9E9E]' :
                      'text-[#2F5233]'
                    }`} 
                    strokeWidth={1.5} 
                  />
                  <span className="text-caption text-[#9E9E9E] mb-0.5">{stat.label}</span>
                  <span className={`text-caption ${isActive ? 'text-[#2F5233]' : 'text-[#424242]'}`}>
                    {stat.value}
                  </span>
                </div>
              );
            })}
          </div>

          {/* Today's Mood */}
          <div className="p-3 rounded-md bg-[#FFFBEA]">
            <p className="text-caption text-[#9E9E9E] mb-0.5">今日心情</p>
            <p className="text-body text-[#424242]">主人，我今天开心的！</p>
          </div>
        </Card>
      </div>

      {/* Messages/Reminders - 新极简主义 */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-body text-[#424242]">消息</h3>
          <Button
            onClick={() => onNavigate('reminder')}
            variant="ghost"
            size="sm"
            className="h-7 px-2 rounded-md hover:bg-[#F5F5F5] text-caption text-[#9E9E9E] hover:text-[#424242]"
          >
            {todayReminders.length}项
            <ChevronRight className="w-4 h-4 ml-0.5" strokeWidth={1.5} />
          </Button>
        </div>

        <div className="space-y-2.5">
          {todayReminders.map((reminder) => (
            <Card
              key={reminder.id}
              onClick={() => onNavigate('reminder')}
              className={`p-4 cursor-pointer transition-all ${
                reminder.type === 'urgent'
                  ? 'bg-[#FFFBEA]'
                  : 'bg-white'
              }`}
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <div className="flex items-start justify-between">
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    {reminder.type === 'urgent' && (
                      <div className="w-1.5 h-1.5 rounded-full bg-[#FFD84D] flex-shrink-0" />
                    )}
                    <p className="text-body text-[#424242]">{reminder.title}</p>
                  </div>
                  <p className="text-caption text-[#9E9E9E]">{reminder.time}</p>
                </div>
                <ChevronRight className="w-5 h-5 text-[#E0E0E0] flex-shrink-0 ml-2" strokeWidth={1.5} />
              </div>
            </Card>
          ))}
        </div>
      </div>
      </div>
    </div>
  );
}
