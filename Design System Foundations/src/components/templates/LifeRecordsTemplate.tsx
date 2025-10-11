import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Dialog, DialogContent, DialogTitle, DialogDescription } from '../ui/dialog';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { 
  ArrowLeft,
  Camera, 
  Activity, 
  Calendar, 
  Clock,
  Footprints,
  Utensils,
  Droplet,
  Moon,
  Heart,
  TrendingUp,
  Image as ImageIcon,
  X,
  ChevronRight,
  Sun,
  Star,
  BarChart3
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';

interface LifeRecord {
  id: string;
  type: 'photo' | 'activity' | 'health' | 'meal' | 'sleep';
  timestamp: Date;
  petName: string;
  // Photo specific
  photoUrl?: string;
  aiMode?: string;
  aiTags?: string[];
  // Activity specific
  activityType?: string;
  duration?: number;
  distance?: number;
  // Health specific
  healthMetric?: string;
  value?: string | number;
  // Meal specific
  mealType?: string;
  foodAmount?: number;
  // Sleep specific
  sleepQuality?: string;
  sleepDuration?: number;
}

// Mock data combining photos and activities
const mockLifeRecords: LifeRecord[] = [
  {
    id: '1',
    type: 'photo',
    timestamp: new Date('2025-09-30T10:30:00'),
    petName: '小白',
    photoUrl: 'https://images.unsplash.com/photo-1684707458757-1d33524680d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHBvcnRyYWl0fGVufDF8fHx8MTc2MDA5NjkyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    aiMode: '健康检测',
    aiTags: ['我的眼睛清澈', '我的毛发有光泽', '我精神很好']
  },
  {
    id: '2',
    type: 'activity',
    timestamp: new Date('2025-09-30T09:15:00'),
    petName: '小白',
    activityType: '晨间散步',
    duration: 45,
    distance: 2.3
  },
  {
    id: '3',
    type: 'photo',
    timestamp: new Date('2025-09-30T08:45:00'),
    petName: '小白',
    photoUrl: 'https://images.unsplash.com/photo-1638826597213-6a9e0d892348?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHBsYXlmdWx8ZW58MXx8fHwxNzYwMDk3MDg3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    aiMode: '行为记录',
    aiTags: ['我在玩耍', '我很活跃', '主人陪我玩球']
  },
  {
    id: '4',
    type: 'meal',
    timestamp: new Date('2025-09-30T08:00:00'),
    petName: '小白',
    mealType: '早餐',
    foodAmount: 150
  },
  {
    id: '5',
    type: 'photo',
    timestamp: new Date('2025-09-29T18:20:00'),
    petName: '小白',
    photoUrl: 'https://images.unsplash.com/photo-1705558874782-4159efcc814c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMGVhdGluZ3xlbnwxfHx8fDE3NjAwOTcwODd8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    aiMode: '饮食识别',
    aiTags: ['我在正常吃饭', '我食欲很好']
  },
  {
    id: '6',
    type: 'activity',
    timestamp: new Date('2025-09-29T17:00:00'),
    petName: '小白',
    activityType: '傍晚散步',
    duration: 35,
    distance: 1.8
  },
  {
    id: '7',
    type: 'sleep',
    timestamp: new Date('2025-09-29T14:00:00'),
    petName: '小白',
    sleepQuality: '良好',
    sleepDuration: 180
  },
  {
    id: '8',
    type: 'health',
    timestamp: new Date('2025-09-29T10:00:00'),
    petName: '小白',
    healthMetric: '饮水量',
    value: 350
  },
  {
    id: '9',
    type: 'photo',
    timestamp: new Date('2025-09-28T16:30:00'),
    petName: '小白',
    photoUrl: 'https://images.unsplash.com/photo-1628652761343-2e8035e6e533?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHNsZWVwaW5nfGVufDF8fHx8MTc2MDA5NzA4N3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
    aiMode: '行为记录',
    aiTags: ['我在休息', '我很舒适', '在主人给我买的新窝里']
  }
];

interface LifeRecordsTemplateProps {
  onNavigate: (page: string) => void;
}

export function LifeRecordsTemplate({ onNavigate }: LifeRecordsTemplateProps) {
  const [activeView, setActiveView] = useState<'timeline' | 'photos' | 'stats'>('timeline');
  const [selectedRecord, setSelectedRecord] = useState<LifeRecord | null>(null);
  const [filterType, setFilterType] = useState<string | null>(null);

  // Group records by date
  const groupedRecords = mockLifeRecords.reduce((acc, record) => {
    const dateKey = record.timestamp.toLocaleDateString('zh-CN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
    if (!acc[dateKey]) {
      acc[dateKey] = [];
    }
    acc[dateKey].push(record);
    return acc;
  }, {} as Record<string, LifeRecord[]>);

  // Filter records
  const filteredRecords = filterType
    ? Object.entries(groupedRecords).reduce((acc, [date, records]) => {
        const filtered = records.filter(r => r.type === filterType);
        if (filtered.length > 0) {
          acc[date] = filtered;
        }
        return acc;
      }, {} as Record<string, LifeRecord[]>)
    : groupedRecords;

  // Statistics for overview
  const todayStats = {
    photos: mockLifeRecords.filter(r => r.type === 'photo' && 
      r.timestamp.toDateString() === new Date().toDateString()).length,
    activities: mockLifeRecords.filter(r => r.type === 'activity' && 
      r.timestamp.toDateString() === new Date().toDateString()).length,
    totalExercise: 80, // minutes
    waterIntake: 350, // ml
    moodScore: 5
  };

  // Weekly trend data
  const weeklyData = [
    { day: '一', value1: 5, value2: 8 },
    { day: '二', value1: 7, value2: 6 },
    { day: '三', value1: 4, value2: 7 },
    { day: '四', value1: 6, value2: 9 },
    { day: '五', value1: 8, value2: 7 },
    { day: '六', value1: 10, value2: 10 },
    { day: '日', value1: 6, value2: 8 }
  ];

  // Activity distribution
  const activityDistribution = [
    { name: '运动', value: 35, color: '#FFD84D' },
    { name: '饮食', value: 25, color: '#4CAF50' },
    { name: '睡眠', value: 25, color: '#42A5F5' },
    { name: '其他', value: 15, color: '#FFC107' }
  ];

  const getRecordIcon = (type: string) => {
    switch (type) {
      case 'photo': return Camera;
      case 'activity': return Footprints;
      case 'health': return Heart;
      case 'meal': return Utensils;
      case 'sleep': return Moon;
      default: return Activity;
    }
  };

  const getRecordTitle = (record: LifeRecord) => {
    switch (record.type) {
      case 'photo':
        return record.aiMode || '照片';
      case 'activity':
        return record.activityType || '活动';
      case 'health':
        return record.healthMetric || '健康记录';
      case 'meal':
        return record.mealType || '用餐';
      case 'sleep':
        return '睡眠';
      default:
        return '记录';
    }
  };

  const getRecordDetails = (record: LifeRecord) => {
    switch (record.type) {
      case 'photo':
        return record.aiTags?.join(' · ') || '';
      case 'activity':
        return `${record.duration}分钟 · ${record.distance}km`;
      case 'health':
        return `${record.value}${record.healthMetric === '饮水量' ? 'ml' : ''}`;
      case 'meal':
        return `${record.foodAmount}g`;
      case 'sleep':
        return `${Math.floor((record.sleepDuration || 0) / 60)}小时 · ${record.sleepQuality}`;
      default:
        return '';
    }
  };

  return (
    <div className="pb-6">
      {/* Custom Header */}
      <div className="pt-6 mb-6">
        <h1 className="text-[28px] mb-1" style={{ fontWeight: 700, lineHeight: '32px' }}>Felo</h1>
        <h2 className="text-title text-[#37474F]">活动记录</h2>
      </div>

      {/* Summary Card */}
      <Card className="p-6 mb-6 border border-gray-200 shadow-sm bg-white">
        <div>
          <h3 className="text-body mb-1 text-[#37474F]">主人，这是我今天的表现</h3>
          <p className="text-caption text-[#78909C] mb-5">实时行为报告</p>

          {/* Today's Stats Grid */}
          <div className="grid grid-cols-4 gap-3 mb-5">
            <div className="flex flex-col items-center p-3 rounded-2xl bg-[#F5F5F0]">
              <Footprints className="w-5 h-5 text-[#2F5233] mb-2" strokeWidth={1.5} />
              <span className="text-caption text-[#78909C] mb-1">运动</span>
              <span className="text-caption text-[#37474F]">45分</span>
            </div>
            <div className="flex flex-col items-center p-3 rounded-2xl bg-[#F5F5F0]">
              <Droplet className="w-5 h-5 text-[#42A5F5] mb-2" strokeWidth={1.5} />
              <span className="text-caption text-[#78909C] mb-1">饮水</span>
              <span className="text-caption text-[#37474F]">350ml</span>
            </div>
            <div className="flex flex-col items-center p-3 rounded-2xl bg-[#F5F5F0]">
              <Moon className="w-5 h-5 text-[#78909C] mb-2" strokeWidth={1.5} />
              <span className="text-caption text-[#78909C] mb-1">睡眠</span>
              <span className="text-caption text-[#37474F]">12小时</span>
            </div>
            <div className="flex flex-col items-center p-3 rounded-2xl bg-[#E8F5E9]">
              <Activity className="w-5 h-5 text-[#2F5233] mb-2" strokeWidth={1.5} />
              <span className="text-caption text-[#78909C] mb-1">活跃</span>
              <span className="text-caption text-[#2F5233]">良好</span>
            </div>
          </div>

          {/* Today's Mood */}
          <div className="p-4 rounded-2xl bg-[#FFFBEA] border border-[#FFD84D]/30">
            <p className="text-caption text-[#78909C] mb-1">今日心情</p>
            <p className="text-body text-[#37474F]">主人，我今天超开心！</p>
          </div>
        </div>
      </Card>

      {/* View Tabs */}
      <div className="flex gap-2 mb-6 overflow-x-auto pb-2 -mx-1 px-1">
        <Button
          onClick={() => setActiveView('timeline')}
          variant={activeView === 'timeline' ? 'default' : 'outline'}
          className={`flex-shrink-0 h-10 px-4 rounded-full ${
            activeView === 'timeline'
              ? 'bg-[#FFD84D] hover:bg-[#FFC107] text-[#37474F] border-none'
              : 'border-gray-200 hover:bg-[#F5F5F0] text-[#78909C]'
          }`}
        >
          <Clock className="w-4 h-4 mr-2" strokeWidth={1.5} />
          时间轴
        </Button>
        <Button
          onClick={() => setActiveView('photos')}
          variant={activeView === 'photos' ? 'default' : 'outline'}
          className={`flex-shrink-0 h-10 px-4 rounded-full ${
            activeView === 'photos'
              ? 'bg-[#FFD84D] hover:bg-[#FFC107] text-[#37474F] border-none'
              : 'border-gray-200 hover:bg-[#F5F5F0] text-[#78909C]'
          }`}
        >
          <ImageIcon className="w-4 h-4 mr-2" strokeWidth={1.5} />
          相册
        </Button>
        <Button
          onClick={() => setActiveView('stats')}
          variant={activeView === 'stats' ? 'default' : 'outline'}
          className={`flex-shrink-0 h-10 px-4 rounded-full ${
            activeView === 'stats'
              ? 'bg-[#FFD84D] hover:bg-[#FFC107] text-[#37474F] border-none'
              : 'border-gray-200 hover:bg-[#F5F5F0] text-[#78909C]'
          }`}
        >
          <BarChart3 className="w-4 h-4 mr-2" strokeWidth={1.5} />
          统计
        </Button>
      </div>

      {/* Timeline View */}
      {activeView === 'timeline' && (
        <div className="space-y-6">
          {/* Filter Buttons */}
          <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1">
            <Badge
              variant="outline"
              className={`cursor-pointer rounded-full px-4 py-1.5 whitespace-nowrap border ${
                filterType === null
                  ? 'bg-[#FFD84D] border-[#FFD84D] text-[#37474F]'
                  : 'border-gray-200 bg-white hover:bg-[#F5F5F0] text-[#78909C]'
              }`}
              onClick={() => setFilterType(null)}
            >
              全部记录
            </Badge>
            <Badge
              variant="outline"
              className={`cursor-pointer rounded-full px-4 py-1.5 whitespace-nowrap border ${
                filterType === 'photo'
                  ? 'bg-[#FFD84D] border-[#FFD84D] text-[#37474F]'
                  : 'border-gray-200 bg-white hover:bg-[#F5F5F0] text-[#78909C]'
              }`}
              onClick={() => setFilterType(filterType === 'photo' ? null : 'photo')}
            >
              照片
            </Badge>
            <Badge
              variant="outline"
              className={`cursor-pointer rounded-full px-4 py-1.5 whitespace-nowrap border ${
                filterType === 'activity'
                  ? 'bg-[#FFD84D] border-[#FFD84D] text-[#37474F]'
                  : 'border-gray-200 bg-white hover:bg-[#F5F5F0] text-[#78909C]'
              }`}
              onClick={() => setFilterType(filterType === 'activity' ? null : 'activity')}
            >
              运动
            </Badge>
            <Badge
              variant="outline"
              className={`cursor-pointer rounded-full px-4 py-1.5 whitespace-nowrap border ${
                filterType === 'meal'
                  ? 'bg-[#FFD84D] border-[#FFD84D] text-[#37474F]'
                  : 'border-gray-200 bg-white hover:bg-[#F5F5F0] text-[#78909C]'
              }`}
              onClick={() => setFilterType(filterType === 'meal' ? null : 'meal')}
            >
              饮食
            </Badge>
          </div>

          {/* Timeline */}
          <div className="space-y-6">
            {Object.entries(filteredRecords).map(([date, records]) => (
              <div key={date}>
                {/* Date Header */}
                <div className="flex items-center gap-2 mb-4">
                  <Calendar className="w-4 h-4 text-[#90A4AE]" strokeWidth={1.5} />
                  <h3 className="text-caption text-[#78909C]">{date}</h3>
                </div>

                {/* Records */}
                <div className="space-y-3 relative pl-8 before:absolute before:left-2 before:top-3 before:bottom-3 before:w-px before:bg-gray-200">
                  {records.map((record, index) => {
                    const Icon = getRecordIcon(record.type);
                    const isPhoto = record.type === 'photo';

                    return (
                      <div key={record.id} className="relative">
                        {/* Timeline Dot */}
                        <div className="absolute -left-8 top-3 w-5 h-5 rounded-full bg-[#FFD84D] flex items-center justify-center">
                          <div className="w-2 h-2 rounded-full bg-[#37474F]" />
                        </div>

                        {/* Record Card */}
                        <Card
                          onClick={() => setSelectedRecord(record)}
                          className={`p-4 border shadow-none cursor-pointer transition-all hover:scale-[1.01] ${
                            isPhoto ? 'border-[#FFD84D] bg-[#FFFBEA]' : 'border-gray-200 bg-white hover:border-[#FFD84D]'
                          }`}
                        >
                          <div className="flex items-start gap-3">
                            {/* Icon or Photo */}
                            {isPhoto && record.photoUrl ? (
                              <div className="w-12 h-12 rounded-xl overflow-hidden flex-shrink-0 border border-gray-200">
                                <ImageWithFallback
                                  src={record.photoUrl}
                                  alt={record.aiMode || '照片'}
                                  className="w-full h-full object-cover"
                                />
                              </div>
                            ) : (
                              <div className="w-12 h-12 rounded-xl bg-[#F5F5F0] flex items-center justify-center flex-shrink-0">
                                <Icon className="w-6 h-6 text-[#78909C]" strokeWidth={1.5} />
                              </div>
                            )}

                            {/* Content */}
                            <div className="flex-1 min-w-0">
                              <div className="flex items-start justify-between mb-1">
                                <h4 className="text-body text-[#37474F]">{getRecordTitle(record)}</h4>
                                <span className="text-caption text-[#90A4AE] flex-shrink-0 ml-2">
                                  {record.timestamp.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })}
                                </span>
                              </div>

                              {record.type === 'photo' && record.aiTags && (
                                <div className="flex flex-wrap gap-1.5 mt-2">
                                  {record.aiTags.map((tag, i) => (
                                    <Badge
                                      key={i}
                                      variant="outline"
                                      className="text-caption px-2 py-0.5 rounded-full bg-white border-[#FFD84D]/30 text-[#78909C]"
                                    >
                                      {tag}
                                    </Badge>
                                  ))}
                                </div>
                              )}

                              {record.type !== 'photo' && getRecordDetails(record) && (
                                <p className="text-caption text-[#78909C] mt-1">{getRecordDetails(record)}</p>
                              )}
                            </div>
                          </div>
                        </Card>
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Photos Grid View */}
      {activeView === 'photos' && (
        <div className="grid grid-cols-2 gap-3">
          {mockLifeRecords
            .filter(r => r.type === 'photo' && r.photoUrl)
            .map(record => (
              <button
                key={record.id}
                onClick={() => setSelectedRecord(record)}
                className="aspect-square rounded-2xl overflow-hidden relative group border border-gray-200"
              >
                <ImageWithFallback
                  src={record.photoUrl!}
                  alt={record.aiMode || '照片'}
                  className="w-full h-full object-cover transition-transform group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
                  <div className="absolute bottom-3 left-3 right-3">
                    <div className="text-caption text-white">
                      {record.timestamp.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </div>
                </div>
                <div className="absolute top-3 right-3">
                  <div className="w-7 h-7 rounded-full bg-[#FFD84D] flex items-center justify-center">
                    <Camera className="w-4 h-4 text-[#37474F]" strokeWidth={1.5} />
                  </div>
                </div>
              </button>
            ))}
        </div>
      )}

      {/* Statistics View */}
      {activeView === 'stats' && (
        <div className="space-y-6">
          {/* Weekly Trend */}
          <Card className="p-6 border border-gray-200 shadow-sm bg-white">
            <div className="flex items-center gap-2 mb-4">
              <TrendingUp className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              <h3 className="text-body text-[#37474F]">本周记录趋势</h3>
            </div>
            <div className="h-48">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={weeklyData}>
                  <XAxis 
                    dataKey="day" 
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: '#78909C', fontSize: 12 }}
                  />
                  <YAxis 
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: '#78909C', fontSize: 12 }}
                  />
                  <Line 
                    type="monotone" 
                    dataKey="value1" 
                    stroke="#FFD84D" 
                    strokeWidth={2}
                    dot={{ fill: '#FFD84D', r: 4 }}
                  />
                  <Line 
                    type="monotone" 
                    dataKey="value2" 
                    stroke="#4CAF50" 
                    strokeWidth={2}
                    dot={{ fill: '#4CAF50', r: 4 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
            <div className="flex justify-center gap-6 mt-4">
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-[#FFD84D]" />
                <span className="text-caption text-[#78909C]">照片记录</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-3 rounded-full bg-[#4CAF50]" />
                <span className="text-caption text-[#78909C]">活动记录</span>
              </div>
            </div>
          </Card>

          {/* Activity Distribution */}
          <Card className="p-6 border border-gray-200 shadow-sm bg-white">
            <div className="flex items-center gap-2 mb-4">
              <Activity className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              <h3 className="text-body text-[#37474F]">活动分布</h3>
            </div>
            <div className="h-48">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={activityDistribution}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={70}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {activityDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-2 gap-3 mt-4">
              {activityDistribution.map((item, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                    <span className="text-caption text-[#78909C]">{item.name}</span>
                  </div>
                  <span className="text-caption text-[#37474F]">{item.value}%</span>
                </div>
              ))}
            </div>
          </Card>

          {/* Summary Stats */}
          <Card className="p-6 border border-gray-200 shadow-sm bg-[#FFFBEA]">
            <div className="flex items-center gap-2 mb-4">
              <Star className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              <h3 className="text-body text-[#37474F]">本周总结</h3>
            </div>
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Footprints className="w-4 h-4 text-[#2F5233]" strokeWidth={1.5} />
                  <span className="text-caption text-[#78909C]">主人带我散步</span>
                </div>
                <span className="text-body text-[#37474F]">46 次跑步</span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Utensils className="w-4 h-4 text-[#2F5233]" strokeWidth={1.5} />
                  <span className="text-caption text-[#78909C]">主人喂我吃饭</span>
                </div>
                <span className="text-body text-[#37474F]">1a 次</span>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <Heart className="w-4 h-4 text-[#EF5350]" strokeWidth={1.5} />
                  <span className="text-caption text-[#78909C]">我开心的日子</span>
                </div>
                <span className="text-body text-[#2F5233]">7 天</span>
              </div>
            </div>
          </Card>
        </div>
      )}

      {/* Record Detail Dialog */}
      {selectedRecord && (
        <Dialog open={!!selectedRecord} onOpenChange={() => setSelectedRecord(null)}>
          <DialogContent className="max-w-[350px] rounded-3xl p-0 gap-0 overflow-hidden">
            <DialogTitle className="sr-only">记录详情</DialogTitle>
            <DialogDescription className="sr-only">
              查看{getRecordTitle(selectedRecord)}的详细信息
            </DialogDescription>
            
            {selectedRecord.type === 'photo' && selectedRecord.photoUrl && (
              <div className="aspect-square relative">
                <ImageWithFallback
                  src={selectedRecord.photoUrl}
                  alt={selectedRecord.aiMode || '照片'}
                  className="w-full h-full object-cover"
                />
              </div>
            )}

            <div className="p-6 space-y-4">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <h3 className="text-body text-[#37474F]">{getRecordTitle(selectedRecord)}</h3>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setSelectedRecord(null)}
                    className="w-8 h-8 p-0 rounded-full"
                  >
                    <X className="w-4 h-4" strokeWidth={1.5} />
                  </Button>
                </div>
                <p className="text-caption text-[#78909C]">
                  {selectedRecord.timestamp.toLocaleString('zh-CN')}
                </p>
              </div>

              {selectedRecord.type === 'photo' && selectedRecord.aiTags && (
                <div>
                  <h4 className="text-caption text-[#78909C] mb-2">AI 识别标签</h4>
                  <div className="flex flex-wrap gap-2">
                    {selectedRecord.aiTags.map((tag, i) => (
                      <Badge
                        key={i}
                        className="px-3 py-1.5 rounded-full bg-[#FFF8E1] border border-[#FFD84D]/30 text-[#37474F]"
                      >
                        {tag}
                      </Badge>
                    ))}
                  </div>
                </div>
              )}

              {selectedRecord.type === 'activity' && (
                <div className="grid grid-cols-2 gap-3">
                  <div className="p-3 rounded-xl bg-[#F5F5F0]">
                    <div className="text-caption text-[#78909C] mb-1">活动时长</div>
                    <div className="text-body text-[#37474F]">{selectedRecord.duration} 分钟</div>
                  </div>
                  {selectedRecord.distance && (
                    <div className="p-3 rounded-xl bg-[#F5F5F0]">
                      <div className="text-caption text-[#78909C] mb-1">活动距离</div>
                      <div className="text-body text-[#37474F]">{selectedRecord.distance} km</div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}