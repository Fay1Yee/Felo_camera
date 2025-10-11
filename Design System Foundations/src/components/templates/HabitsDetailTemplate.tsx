import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { 
  Clock, 
  Utensils, 
  Activity, 
  Moon, 
  Sun,
  Droplet,
  Heart,
  TrendingUp,
  Star,
  Plus,
  Edit,
  Smile,
  AlertCircle,
  Check,
  X
} from 'lucide-react';
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

interface HabitsDetailTemplateProps {
  onNavigate: (page: any) => void;
}

export function HabitsDetailTemplate({ onNavigate }: HabitsDetailTemplateProps) {
  const [activeTab, setActiveTab] = useState('overview');

  // Weekly habit tracking data
  const weeklyHabits = [
    { day: '周一', feeding: 3, water: 380, exercise: 45, sleep: 12, mood: 5 },
    { day: '周二', feeding: 3, water: 350, exercise: 50, sleep: 11, mood: 5 },
    { day: '周三', feeding: 2, water: 320, exercise: 30, sleep: 13, mood: 4 },
    { day: '周四', feeding: 3, water: 340, exercise: 40, sleep: 12, mood: 5 },
    { day: '周五', feeding: 3, water: 360, exercise: 35, sleep: 13, mood: 4 },
    { day: '周六', feeding: 3, water: 400, exercise: 55, sleep: 10, mood: 5 },
    { day: '周日', feeding: 3, water: 350, exercise: 45, sleep: 12, mood: 5 },
  ];

  // Eating habits breakdown
  const eatingHabits = [
    { name: '主食', value: 65, color: '#FFD84D' },
    { name: '零食', value: 20, color: '#FFC107' },
    { name: '营养补充', value: 15, color: '#FFE082' },
  ];

  // Daily schedule adherence
  const scheduleAdherence = [
    { activity: '早餐', scheduled: '08:00', actual: '08:05', status: 'ontime' },
    { activity: '晨间散步', scheduled: '08:30', actual: '08:35', status: 'ontime' },
    { activity: '午餐', scheduled: '12:00', actual: '12:20', status: 'late' },
    { activity: '午睡', scheduled: '14:00', actual: '14:00', status: 'ontime' },
    { activity: '傍晚散步', scheduled: '17:00', actual: '17:10', status: 'late' },
    { activity: '晚餐', scheduled: '19:00', actual: '18:55', status: 'early' },
    { activity: '睡眠', scheduled: '22:00', actual: '22:05', status: 'ontime' },
  ];

  // Behavior patterns
  const behaviorPatterns = [
    {
      pattern: '我早上最有精神啦',
      description: '主人，我每天早上6-9点最有活力，这时候最适合和我玩游戏或者教我新技能哦',
      frequency: '每天',
      icon: Sun
    },
    {
      pattern: '我喜欢午睡',
      description: '主人，我吃完午饭后就想睡个觉，通常要睡2-3个小时呢',
      frequency: '每天',
      icon: Moon
    },
    {
      pattern: '饭点到啦我就兴奋',
      description: '主人，每次快到吃饭时间前15-20分钟，我就会特别期待，会一直盯着你看',
      frequency: '每天',
      icon: Utensils
    },
    {
      pattern: '我喜欢熟悉的散步路线',
      description: '主人，我更喜欢走我们常去的那几条路，新路线我需要时间适应才会放松',
      frequency: '大部分时候',
      icon: Activity
    }
  ];

  // Health habits checklist
  const healthChecklist = [
    { task: '我今天称重啦', completed: true, streak: 7 },
    { task: '我今天喝了好多水', completed: true, streak: 7 },
    { task: '我今天运动啦', completed: true, streak: 5 },
    { task: '我今天心情很好', completed: false, streak: 3 },
    { task: '我今天便便正常', completed: true, streak: 7 },
    { task: '主人给我梳毛啦', completed: true, streak: 2 },
  ];

  // Recommendations based on habits
  const recommendations = [
    {
      type: '我想多喝点水',
      message: '主人，我最近中午喝水有点少，能不能在午饭时间多给我一些水呀',
      priority: 'medium'
    },
    {
      type: '我想多运动',
      message: '主人，周末和你一起运动好开心！工作日也能多带我出去玩玩吗',
      priority: 'low'
    },
    {
      type: '我想按时吃饭',
      message: '主人，我的午餐时间有点不固定，能不能每天都在12:00-12:30之间喂我呢',
      priority: 'high'
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      {/* Header Summary */}
      <div className="pt-6">
        <Card className="p-6 border border-gray-100 shadow-none bg-[#FFFBEA] relative overflow-hidden">
          <div className="absolute inset-0 dot-grid-bg text-gray-900" />
          <div className="relative">
            <div className="flex items-center justify-between mb-5">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center">
                  <Heart className="w-6 h-6 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="text-title">习惯养成概况</h2>
                  <p className="text-caption text-gray-500">本周表现优秀</p>
                </div>
              </div>
              <Button
                onClick={() => onNavigate('life-records')}
                variant="ghost"
                size="sm"
                className="h-8 px-3 rounded-full hover:bg-white text-caption"
              >
                查看记录
              </Button>
            </div>

            <div className="grid grid-cols-3 gap-4">
              <div className="text-center">
                <p className="text-caption text-gray-500 mb-1">规律性</p>
                <p className="text-[20px] mb-1">92%</p>
                <div className="flex items-center justify-center gap-1 text-caption text-[#2F5233]">
                  <TrendingUp className="w-3 h-3" strokeWidth={2} />
                  +5%
                </div>
              </div>
              <div className="text-center">
                <p className="text-caption text-gray-500 mb-1">健康指数</p>
                <p className="text-[20px] mb-1">88</p>
                <div className="flex items-center justify-center gap-1 text-caption text-[#2F5233]">
                  <Star className="w-3 h-3 fill-[#FFD84D]" strokeWidth={1.5} />
                  优秀
                </div>
              </div>
              <div className="text-center">
                <p className="text-caption text-gray-500 mb-1">打卡天数</p>
                <p className="text-[20px] mb-1">7天</p>
                <div className="flex items-center justify-center gap-1 text-caption text-gray-500">
                  <Check className="w-3 h-3" strokeWidth={2} />
                  连续
                </div>
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3 bg-transparent border border-gray-100 rounded-full p-1 h-auto">
          <TabsTrigger 
            value="overview" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            总览
          </TabsTrigger>
          <TabsTrigger 
            value="schedule" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            作息表
          </TabsTrigger>
          <TabsTrigger 
            value="patterns" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            行为模式
          </TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-6 mt-6">
          {/* Weekly Exercise Trend */}
          <div>
            <h3 className="text-body mb-4 flex items-center gap-2">
              <Activity className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              每周运动趋势
            </h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <ResponsiveContainer width="100%" height={180}>
                <LineChart data={weeklyHabits}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#ECEFF1" />
                  <XAxis 
                    dataKey="day" 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <YAxis 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      borderRadius: '12px', 
                      border: '1px solid #ECEFF1',
                      fontSize: '12px'
                    }}
                  />
                  <Line 
                    type="monotone" 
                    dataKey="exercise" 
                    stroke="#FFD84D" 
                    strokeWidth={2}
                    dot={{ fill: '#FFD84D', r: 4 }}
                  />
                </LineChart>
              </ResponsiveContainer>
              <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                <span className="text-caption text-gray-500">平均运动时长</span>
                <span className="text-body text-[#2F5233]">42.9 分钟</span>
              </div>
            </Card>
          </div>

          {/* Eating Habits Distribution */}
          <div>
            <h3 className="text-body mb-4 flex items-center gap-2">
              <Utensils className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              饮食结构分析
            </h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <ResponsiveContainer width="100%" height={180}>
                <PieChart>
                  <Pie
                    data={eatingHabits}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={70}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {eatingHabits.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
              <div className="mt-3 space-y-2">
                {eatingHabits.map((item, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                      <span className="text-caption text-gray-600">{item.name}</span>
                    </div>
                    <span className="text-caption">{item.value}%</span>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Health Checklist */}
          <div>
            <h3 className="text-body mb-4">今日打卡</h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <div className="space-y-3">
                {healthChecklist.map((item, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className={`w-6 h-6 rounded-full flex items-center justify-center ${
                        item.completed ? 'bg-[#E8F5E9]' : 'bg-gray-100'
                      }`}>
                        {item.completed ? (
                          <Check className="w-4 h-4 text-[#2F5233]" strokeWidth={2} />
                        ) : (
                          <X className="w-4 h-4 text-gray-400" strokeWidth={2} />
                        )}
                      </div>
                      <span className="text-body">{item.task}</span>
                    </div>
                    <div className="flex items-center gap-1 text-caption text-gray-500">
                      <Star className="w-3 h-3" strokeWidth={1.5} />
                      {item.streak}天
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Recommendations */}
          <div>
            <h3 className="text-body mb-4">智能建议</h3>
            <div className="space-y-2">
              {recommendations.map((rec, index) => (
                <Card 
                  key={index}
                  className={`p-4 border shadow-none ${
                    rec.priority === 'high' ? 'border-[#FFD84D] bg-[#FFFBEA]' :
                    rec.priority === 'medium' ? 'border-gray-200 bg-white' :
                    'border-gray-100 bg-gray-50'
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 ${
                      rec.priority === 'high' ? 'bg-white' :
                      rec.priority === 'medium' ? 'bg-[#FFFBEA]' :
                      'bg-white'
                    }`}>
                      <AlertCircle className={`w-5 h-5 ${
                        rec.priority === 'high' ? 'text-[#2F5233]' :
                        'text-gray-700'
                      }`} strokeWidth={1.5} />
                    </div>
                    <div className="flex-1">
                      <h4 className="text-body mb-1">{rec.type}</h4>
                      <p className="text-caption text-gray-600">{rec.message}</p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </TabsContent>

        {/* Schedule Tab */}
        <TabsContent value="schedule" className="space-y-6 mt-6">
          <div>
            <h3 className="text-body mb-4">今日作息执行情况</h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <div className="space-y-3">
                {scheduleAdherence.map((item, index) => (
                  <div key={index}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-body">{item.activity}</span>
                      <div className={`px-2.5 py-0.5 rounded-full text-[11px] ${
                        item.status === 'ontime' ? 'bg-[#E8F5E9] text-[#2F5233]' :
                        item.status === 'early' ? 'bg-[#FFFBEA] text-gray-900' :
                        'bg-gray-100 text-gray-700'
                      }`}>
                        {item.status === 'ontime' ? '准时' :
                         item.status === 'early' ? '提前' : '延迟'}
                      </div>
                    </div>
                    <div className="flex items-center gap-3 text-caption text-gray-500">
                      <span>计划: {item.scheduled}</span>
                      <span>•</span>
                      <span>实际: {item.actual}</span>
                    </div>
                    {index < scheduleAdherence.length - 1 && (
                      <div className="dot-divider text-gray-300 mt-3" />
                    )}
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Weekly Water Intake */}
          <div>
            <h3 className="text-body mb-4 flex items-center gap-2">
              <Droplet className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              每周饮水统计
            </h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <ResponsiveContainer width="100%" height={160}>
                <BarChart data={weeklyHabits}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#ECEFF1" vertical={false} />
                  <XAxis 
                    dataKey="day" 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <YAxis 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      borderRadius: '12px', 
                      border: '1px solid #ECEFF1',
                      fontSize: '12px'
                    }}
                  />
                  <Bar dataKey="water" fill="#42A5F5" radius={[8, 8, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
              <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                <span className="text-caption text-gray-500">日均饮水量</span>
                <span className="text-body text-[#2F5233]">357 ml</span>
              </div>
            </Card>
          </div>

          {/* Add Schedule Button */}
          <Button 
            variant="outline"
            className="w-full h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
          >
            <Plus className="w-5 h-5 mr-2" strokeWidth={1.5} />
            添加作息安排
          </Button>
        </TabsContent>

        {/* Patterns Tab */}
        <TabsContent value="patterns" className="space-y-6 mt-6">
          <div>
            <h3 className="text-body mb-4">发现的行为模式</h3>
            <div className="space-y-3">
              {behaviorPatterns.map((pattern, index) => {
                const Icon = pattern.icon;
                return (
                  <Card key={index} className="p-5 border border-gray-100 shadow-none hover:border-[#FFD84D] transition-all">
                    <div className="flex items-start gap-4">
                      <div className="w-12 h-12 rounded-full bg-[#FFFBEA] flex items-center justify-center flex-shrink-0">
                        <Icon className="w-6 h-6 text-gray-900" strokeWidth={1.5} />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between mb-2">
                          <h4 className="text-body">{pattern.pattern}</h4>
                          <div className="px-2.5 py-0.5 rounded-full bg-[#E8F5E9] text-[#2F5233] text-[11px]">
                            {pattern.frequency}
                          </div>
                        </div>
                        <p className="text-caption text-gray-600">{pattern.description}</p>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </div>

          {/* Mood Tracking */}
          <div>
            <h3 className="text-body mb-4 flex items-center gap-2">
              <Smile className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              情绪状态趋势
            </h3>
            <Card className="p-5 border border-gray-100 shadow-none">
              <ResponsiveContainer width="100%" height={150}>
                <LineChart data={weeklyHabits}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#ECEFF1" />
                  <XAxis 
                    dataKey="day" 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <YAxis 
                    domain={[0, 5]}
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      borderRadius: '12px', 
                      border: '1px solid #ECEFF1',
                      fontSize: '12px'
                    }}
                  />
                  <Line 
                    type="monotone" 
                    dataKey="mood" 
                    stroke="#2F5233" 
                    strokeWidth={2}
                    dot={{ fill: '#2F5233', r: 4 }}
                  />
                </LineChart>
              </ResponsiveContainer>
              <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                <span className="text-caption text-gray-500">本周平均情绪评分</span>
                <span className="text-body text-[#2F5233]">4.7 / 5.0</span>
              </div>
            </Card>
          </div>

          {/* Pattern Insights */}
          <Card className="p-5 border border-gray-100 shadow-none bg-[#FFFBEA]">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                <TrendingUp className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              </div>
              <div className="flex-1">
                <h4 className="text-body mb-1">行为洞察</h4>
                <p className="text-caption text-gray-600">
                  宠物的行为模式已建立稳定，建议继续保持当前的作息安排。周末可适当增加社交活动时间。
                </p>
              </div>
            </div>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Edit Button */}
      <Button 
        variant="outline"
        className="w-full h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
      >
        <Edit className="w-5 h-5 mr-2" strokeWidth={1.5} />
        编辑习惯记录
      </Button>
    </div>
  );
}