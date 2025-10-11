import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { 
  Heart,
  Activity,
  Thermometer,
  Wind,
  TrendingUp,
  TrendingDown,
  Calendar,
  Syringe,
  Pill,
  FileText,
  ChevronRight,
  Download,
  Share2
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface PetProfileDetailTemplateProps {
  onNavigate: (page: string) => void;
}

export function PetProfileDetailTemplate({ onNavigate }: PetProfileDetailTemplateProps) {
  const [activeTab, setActiveTab] = useState<'info' | 'health'>('info');

  // 宠物基本信息
  const petInfo = {
    id: 'PET20240915001',
    name: '小白',
    breed: '田园猫',
    gender: '母',
    age: '2岁3个月',
    birthday: '2022年07月15日',
    weight: '6.2kg',
    color: '白色',
    chip: 'CN900012345678',
    status: '已认证',
    avatar: 'https://images.unsplash.com/photo-1684707458757-1d33524680d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHBvcnRyYWl0fGVufDF8fHx8MTc2MDA5NjkyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
  };

  // 生命体征
  const vitalSigns = [
    { 
      label: '体重', 
      value: '6.2', 
      unit: 'kg',
      change: '+0.1',
      trend: 'up',
      icon: Activity,
      color: 'text-[#42A5F5]'
    },
    { 
      label: '体温', 
      value: '38.5', 
      unit: '℃',
      change: '0',
      trend: 'stable',
      icon: Thermometer,
      color: 'text-[#66BB6A]'
    },
    { 
      label: '心率', 
      value: '95', 
      unit: '次/分',
      change: '+2',
      trend: 'up',
      icon: Heart,
      color: 'text-[#EF5350]'
    },
    { 
      label: '呼吸', 
      value: '24', 
      unit: '次/分',
      change: '0',
      trend: 'stable',
      icon: Wind,
      color: 'text-[#FFA726]'
    }
  ];

  // 健康趋势数据
  const healthTrendData = [
    { month: '3月', weight: 5.8 },
    { month: '4月', weight: 5.9 },
    { month: '5月', weight: 6.0 },
    { month: '6月', weight: 6.1 },
    { month: '7月', weight: 6.15 },
    { month: '8月', weight: 6.2 }
  ];

  // 疫苗记录
  const vaccinations = [
    { name: '狂犬疫苗', date: '2024-08-15', nextDate: '2025-08-15', status: '已接种' },
    { name: '猫三联', date: '2024-07-01', nextDate: '2025-07-01', status: '已接种' },
    { name: '驱虫', date: '2024-09-01', nextDate: '2024-12-01', status: '即将到期' }
  ];

  // 医疗建议
  const medicalAdvice = [
    '建议每月定期称重，监测体重变化',
    '保持适量运动，每天至少30分钟活动时间',
    '注意饮食均衡，避免过度喂食零食',
    '定期检查牙齿健康，预防口腔疾病'
  ];

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* 标签切换 */}
      <div className="flex gap-3">
        <button
          onClick={() => setActiveTab('info')}
          className={`flex-1 h-11 px-4 rounded-md transition-all ${
            activeTab === 'info'
              ? 'bg-[#FFD84D] text-[#424242]'
              : 'bg-white text-[#9E9E9E]'
          }`}
          style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
        >
          <span className="text-body" style={{ fontWeight: 600 }}>基本信息</span>
        </button>
        <button
          onClick={() => setActiveTab('health')}
          className={`flex-1 h-11 px-4 rounded-md transition-all ${
            activeTab === 'health'
              ? 'bg-[#FFD84D] text-[#424242]'
              : 'bg-white text-[#9E9E9E]'
          }`}
          style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
        >
          <span className="text-body" style={{ fontWeight: 600 }}>健康档案</span>
        </button>
      </div>

      {/* 基本信息标签 */}
      {activeTab === 'info' && (
        <div className="space-y-4">
          {/* 宠物身份证卡片 */}
          <Card className="p-5 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            {/* 顶部标题 */}
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-body text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>宠物身份证</h3>
                <p className="text-caption text-[#9E9E9E]">Pet ID Card</p>
              </div>
              <Badge className="px-3 py-1 rounded-md bg-[#EDF7ED] text-[#2E7D32] border-none">
                {petInfo.status}
              </Badge>
            </div>

            {/* 头像和基本信息 */}
            <div className="flex gap-4 mb-4">
              {/* 证件照 */}
              <div className="relative">
                <div className="w-24 h-24 rounded-md overflow-hidden bg-[#F5F5F5] border-2 border-[#FFD84D]">
                  <ImageWithFallback
                    src={petInfo.avatar}
                    alt={petInfo.name}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-[#FFD84D] flex items-center justify-center">
                  <span className="text-[10px]">✓</span>
                </div>
              </div>

              {/* 基本信息 */}
              <div className="flex-1">
                <h2 className="text-title text-[#424242] mb-2" style={{ fontWeight: 700 }}>{petInfo.name}</h2>
                <div className="space-y-1.5">
                  <div className="flex items-center gap-2">
                    <span className="text-caption text-[#9E9E9E]">品种</span>
                    <span className="text-caption text-[#424242]">{petInfo.breed}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-caption text-[#9E9E9E]">性别</span>
                    <span className="text-caption text-[#424242]">{petInfo.gender}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-caption text-[#9E9E9E]">年龄</span>
                    <span className="text-caption text-[#424242]">{petInfo.age}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* 详细信息 */}
            <div className="p-3 rounded-md bg-[#F5F5F5] space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">出生日期</span>
                <span className="text-caption text-[#424242]">{petInfo.birthday}</span>
              </div>
              <div className="h-px bg-[#E0E0E0]" />
              
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">体重</span>
                <span className="text-caption text-[#424242]">{petInfo.weight}</span>
              </div>
              <div className="h-px bg-[#E0E0E0]" />
              
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">毛色</span>
                <span className="text-caption text-[#424242]">{petInfo.color}</span>
              </div>
              <div className="h-px bg-[#E0E0E0]" />
              
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">芯片编号</span>
                <span className="text-caption text-[#424242] font-mono">{petInfo.chip}</span>
              </div>
              <div className="h-px bg-[#E0E0E0]" />
              
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">档案编号</span>
                <span className="text-caption text-[#424242] font-mono">{petInfo.id}</span>
              </div>
            </div>
          </Card>

          {/* 生命体征 */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>生命体征</h3>
            
            <div className="grid grid-cols-2 gap-3">
              {vitalSigns.map((sign, index) => (
                <div key={index} className="p-3 rounded-md bg-[#F5F5F5]">
                  <div className="flex items-center gap-2 mb-2">
                    <sign.icon className={`w-4 h-4 ${sign.color}`} strokeWidth={1.5} />
                    <span className="text-caption text-[#9E9E9E]">{sign.label}</span>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{sign.value}</span>
                    <span className="text-caption text-[#9E9E9E]">{sign.unit}</span>
                  </div>
                  {sign.change !== '0' && (
                    <div className={`flex items-center gap-1 mt-1 ${
                      sign.trend === 'up' ? 'text-[#66BB6A]' : 'text-[#EF5350]'
                    }`}>
                      {sign.trend === 'up' ? (
                        <TrendingUp className="w-3 h-3" strokeWidth={2} />
                      ) : (
                        <TrendingDown className="w-3 h-3" strokeWidth={2} />
                      )}
                      <span className="text-caption">{sign.change}</span>
                    </div>
                  )}
                </div>
              ))}
            </div>

            <p className="text-caption text-[#9E9E9E] mt-3">
              最后更新：2024年10月10日 14:30
            </p>
          </Card>

          {/* 快捷操作 */}
          <div className="grid grid-cols-2 gap-3">
            <Card 
              className="p-4 bg-white cursor-pointer transition-all hover:bg-[#F5F5F5]" 
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
              onClick={() => onNavigate('habits-detail')}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md bg-[#E3F2FD] flex items-center justify-center">
                  <Activity className="w-5 h-5 text-[#42A5F5]" strokeWidth={1.5} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>日常习惯</p>
                  <p className="text-caption text-[#9E9E9E]">行为分析</p>
                </div>
              </div>
            </Card>

            <Card 
              className="p-4 bg-white cursor-pointer transition-all hover:bg-[#F5F5F5]" 
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
              onClick={() => onNavigate('life-records')}
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md bg-[#FFFBEA] flex items-center justify-center">
                  <FileText className="w-5 h-5 text-[#FFD84D]" strokeWidth={1.5} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>生活记录</p>
                  <p className="text-caption text-[#9E9E9E]">照片日记</p>
                </div>
              </div>
            </Card>
          </div>

          {/* 温馨提示 */}
          <Card className="p-4 bg-[#FFFBEA]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-2">
              <div className="w-5 h-5 rounded-full bg-[#FFD84D] flex items-center justify-center flex-shrink-0 mt-0.5">
                <span className="text-[10px]">💡</span>
              </div>
              <div>
                <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>宠物提示</p>
                <p className="text-caption text-[#9E9E9E]">
                  主人，我的狂犬疫苗还有10个月到期哦，记得提前预约接种！
                </p>
              </div>
            </div>
          </Card>
        </div>
      )}

      {/* 健康档案标签 */}
      {activeTab === 'health' && (
        <div className="space-y-4">
          {/* 健康趋势 */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between mb-3">
              <div>
                <h3 className="text-body text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>体重趋势</h3>
                <p className="text-caption text-[#9E9E9E]">过去6个月</p>
              </div>
              <div className="flex items-center gap-1">
                <TrendingUp className="w-4 h-4 text-[#66BB6A]" strokeWidth={1.5} />
                <span className="text-caption text-[#66BB6A]">+6.9%</span>
              </div>
            </div>

            <div className="h-40">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={healthTrendData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#F5F5F5" />
                  <XAxis 
                    dataKey="month" 
                    tick={{ fontSize: 11, fill: '#9E9E9E' }}
                    stroke="#E0E0E0"
                  />
                  <YAxis 
                    tick={{ fontSize: 11, fill: '#9E9E9E' }}
                    stroke="#E0E0E0"
                    domain={[5.5, 6.5]}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      background: '#fff', 
                      border: 'none',
                      borderRadius: '6px',
                      boxShadow: '0 2px 6px rgba(0, 0, 0, 0.08)',
                      fontSize: '12px'
                    }}
                  />
                  <Line 
                    type="monotone" 
                    dataKey="weight" 
                    stroke="#FFD84D" 
                    strokeWidth={2}
                    dot={{ fill: '#FFD84D', r: 4 }}
                    activeDot={{ r: 6 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>

            <div className="grid grid-cols-3 gap-2 mt-3 p-3 rounded-md bg-[#F5F5F5]">
              <div className="text-center">
                <p className="text-caption text-[#9E9E9E] mb-0.5">最低</p>
                <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>5.8 kg</p>
              </div>
              <div className="text-center">
                <p className="text-caption text-[#9E9E9E] mb-0.5">平均</p>
                <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>6.0 kg</p>
              </div>
              <div className="text-center">
                <p className="text-caption text-[#9E9E9E] mb-0.5">最高</p>
                <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>6.2 kg</p>
              </div>
            </div>
          </Card>

          {/* 疫苗接种记录 */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>疫苗接种</h3>
            
            <div className="space-y-2">
              {vaccinations.map((vac, index) => (
                <div key={index} className="p-3 rounded-md bg-[#F5F5F5]">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <Syringe className="w-4 h-4 text-[#42A5F5]" strokeWidth={1.5} />
                      <span className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>
                        {vac.name}
                      </span>
                    </div>
                    <Badge className={`px-2 py-0.5 rounded text-[11px] border-none ${
                      vac.status === '已接种' 
                        ? 'bg-[#EDF7ED] text-[#2E7D32]' 
                        : 'bg-[#FFF9E6] text-[#F57C00]'
                    }`}>
                      {vac.status}
                    </Badge>
                  </div>
                  <div className="flex items-center justify-between text-caption text-[#9E9E9E]">
                    <span>接种日期：{vac.date}</span>
                    <span>下次：{vac.nextDate}</span>
                  </div>
                </div>
              ))}
            </div>

            <Button
              className="w-full h-10 mt-3 rounded-md bg-[#F5F5F5] hover:bg-[#EEEEEE] text-[#424242] border-none"
            >
              查看完整接种记录
            </Button>
          </Card>

          {/* 医疗建议 */}
          <Card className="p-4 bg-[#EDF7ED]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-md bg-[#66BB6A] flex items-center justify-center flex-shrink-0">
                <Pill className="w-5 h-5 text-white" strokeWidth={1.5} />
              </div>
              <div>
                <h3 className="text-body text-[#424242] mb-1" style={{ fontWeight: 600 }}>健康建议</h3>
                <p className="text-caption text-[#9E9E9E]">AI智能分析</p>
              </div>
            </div>

            <ul className="space-y-2">
              {medicalAdvice.map((advice, index) => (
                <li key={index} className="text-caption text-[#424242] flex items-start gap-2">
                  <span className="text-[#66BB6A] flex-shrink-0 mt-0.5">•</span>
                  <span>{advice}</span>
                </li>
              ))}
            </ul>
          </Card>

          {/* 健康报告 */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>健康报告</h3>
            
            <button className="w-full flex items-center justify-between p-3 rounded-md bg-[#F5F5F5] hover:bg-[#EEEEEE] transition-all">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md bg-white flex items-center justify-center">
                  <FileText className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                </div>
                <div className="text-left">
                  <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>2024年度健康报告</p>
                  <p className="text-caption text-[#9E9E9E]">生成于 2024-10-01</p>
                </div>
              </div>
              <Download className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
            </button>
          </Card>

          {/* 操作按钮 */}
          <div className="grid grid-cols-2 gap-3">
            <Button
              className="h-12 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242] border-none"
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <Share2 className="w-4 h-4 mr-2" strokeWidth={1.5} />
              分享档案
            </Button>
            
            <Button
              className="h-12 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <Download className="w-4 h-4 mr-2" strokeWidth={1.5} />
              导出PDF
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
