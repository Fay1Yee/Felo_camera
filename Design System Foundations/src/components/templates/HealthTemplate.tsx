import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { 
  Heart, 
  Activity, 
  Plus, 
  ChevronRight, 
  Calendar, 
  TrendingUp, 
  Droplet, 
  Moon, 
  Footprints,
  Syringe,
  Pill,
  Weight
} from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface HealthTemplateProps {
  onNavigate: (page: any) => void;
}

export function HealthTemplate({ onNavigate }: HealthTemplateProps) {
  const [activeTab, setActiveTab] = useState<'vaccine' | 'checkup' | 'daily'>('vaccine');

  // 体重趋势数据
  const weightData = [
    { date: '11/01', weight: 6.0 },
    { date: '11/08', weight: 6.1 },
    { date: '11/15', weight: 6.1 },
    { date: '11/22', weight: 6.2 },
    { date: '11/29', weight: 6.2 },
    { date: '今天', weight: 6.2 }
  ];

  const vaccineRecords = [
    { 
      name: "狂犬疫苗", 
      date: "2025-01-10", 
      nextDate: "2026-01-10",
      status: "已接种",
      clinic: "宠物中心医院",
      urgent: false
    },
    { 
      name: "五联疫苗", 
      date: "2024-12-15", 
      nextDate: "2025-12-15",
      status: "已接种",
      clinic: "宠物中心医院",
      urgent: false
    },
    { 
      name: "猫三联", 
      date: "2024-11-20", 
      nextDate: "2025-11-20",
      status: "即将到期",
      clinic: "待预约",
      urgent: true
    }
  ];

  const checkupRecords = [
    {
      type: "年度体检",
      date: "2024-11-20",
      result: "健康",
      hospital: "宠物中心医院",
      notes: "主人，医生说我很健康，各项指标都正常哦"
    },
    {
      type: "血液检查",
      date: "2024-09-15",
      result: "正常",
      hospital: "宠物中心医院",
      notes: "主人，我的血常规和生化指标都很正常呢"
    }
  ];

  const dailyStats = {
    today: {
      weight: "6.2kg",
      water: "350ml",
      sleep: "12h",
      exercise: "45min",
      appetite: "正常",
      mood: "活跃"
    },
    trend: {
      weight: "+0.1kg",
      water: "-30ml",
      sleep: "+1h",
      exercise: "+15min"
    }
  };

  const tabs = [
    { id: 'vaccine' as const, label: '疫苗记录', icon: Syringe },
    { id: 'checkup' as const, label: '体检记录', icon: Heart },
    { id: 'daily' as const, label: '日常数据', icon: Activity }
  ];

  return (
    <div className="pb-6 pt-5 space-y-5">
      {/* Health Overview Card */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>主人，我的健康状况</h3>
          <Badge className="px-2 py-1 rounded-md bg-[#EDF7ED] text-[#2E7D32] border-none">
            良好
          </Badge>
        </div>

        {/* Today's Stats Grid */}
        <div className="grid grid-cols-3 gap-2 mb-4">
          <div className="p-3 rounded-md bg-[#F5F5F5]">
            <div className="flex items-center gap-1.5 mb-1">
              <Weight className="w-3.5 h-3.5 text-[#9E9E9E]" strokeWidth={1.5} />
              <span className="text-caption text-[#9E9E9E]">体重</span>
            </div>
            <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.weight}</p>
            <span className="text-caption text-[#66BB6A]">{dailyStats.trend.weight}</span>
          </div>

          <div className="p-3 rounded-md bg-[#F5F5F5]">
            <div className="flex items-center gap-1.5 mb-1">
              <Droplet className="w-3.5 h-3.5 text-[#9E9E9E]" strokeWidth={1.5} />
              <span className="text-caption text-[#9E9E9E]">饮水</span>
            </div>
            <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.water}</p>
            <span className="text-caption text-[#9E9E9E]">{dailyStats.trend.water}</span>
          </div>

          <div className="p-3 rounded-md bg-[#F5F5F5]">
            <div className="flex items-center gap-1.5 mb-1">
              <Footprints className="w-3.5 h-3.5 text-[#9E9E9E]" strokeWidth={1.5} />
              <span className="text-caption text-[#9E9E9E]">运动</span>
            </div>
            <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.exercise}</p>
            <span className="text-caption text-[#66BB6A]">{dailyStats.trend.exercise}</span>
          </div>
        </div>

        {/* Weight Trend Chart */}
        <div className="h-32">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={weightData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F5F5F5" />
              <XAxis dataKey="date" tick={{ fontSize: 11, fill: '#9E9E9E' }} />
              <YAxis domain={[5.8, 6.4]} tick={{ fontSize: 11, fill: '#9E9E9E' }} />
              <Tooltip 
                contentStyle={{ 
                  background: '#FFFFFF', 
                  border: '1px solid #E0E0E0', 
                  borderRadius: '6px',
                  fontSize: '13px'
                }} 
              />
              <Line 
                type="monotone" 
                dataKey="weight" 
                stroke="#FFD84D" 
                strokeWidth={2}
                dot={{ fill: '#FFD84D', r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </Card>

      {/* Tab Selector */}
      <div className="flex gap-2 overflow-x-auto pb-2 -mx-1 px-1">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex-shrink-0 h-9 px-4 rounded-full transition-all flex items-center gap-2 ${ 
              activeTab === tab.id
                ? 'bg-[#FFD84D] text-[#424242]'
                : 'bg-white text-[#9E9E9E] border border-[#E0E0E0]'
            }`}
            style={{ boxShadow: activeTab === tab.id ? '0 1px 2px rgba(0, 0, 0, 0.04)' : 'none' }}
          >
            <tab.icon className="w-4 h-4" strokeWidth={1.5} />
            <span className="text-caption" style={{ fontWeight: activeTab === tab.id ? 600 : 400 }}>
              {tab.label}
            </span>
          </button>
        ))}
      </div>

      {/* Vaccine Records Tab */}
      {activeTab === 'vaccine' && (
        <div className="space-y-3">
          {vaccineRecords.map((record, index) => (
            <Card 
              key={index}
              onClick={() => onNavigate('health-detail')}
              className={`p-4 cursor-pointer transition-all ${
                record.urgent 
                  ? 'bg-[#FFFBEA] border border-[#FFD84D]/30' 
                  : 'bg-white border border-[#E0E0E0]'
              }`}
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3 flex-1">
                  <div className={`w-10 h-10 rounded-md flex items-center justify-center ${
                    record.urgent ? 'bg-white' : 'bg-[#F5F5F5]'
                  }`}>
                    <Syringe className={`w-5 h-5 ${
                      record.urgent ? 'text-[#FFA726]' : 'text-[#9E9E9E]'
                    }`} strokeWidth={1.5} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>
                        {record.name}
                      </h4>
                      {record.urgent && (
                        <Badge className="px-2 py-0.5 rounded bg-[#FFF3E0] text-[#FFA726] text-[11px] border-none">
                          提醒
                        </Badge>
                      )}
                    </div>
                    <div className="space-y-0.5">
                      <p className="text-caption text-[#9E9E9E]">接种日期：{record.date}</p>
                      <p className="text-caption text-[#9E9E9E]">下次接种：{record.nextDate}</p>
                      <p className="text-caption text-[#9E9E9E]">医院：{record.clinic}</p>
                    </div>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-[#9E9E9E] flex-shrink-0" strokeWidth={1.5} />
              </div>
            </Card>
          ))}

          <Button
            onClick={() => onNavigate('health-detail')}
            className="w-full h-12 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242] border border-[#E0E0E0]"
          >
            <Plus className="w-4 h-4 mr-2" strokeWidth={1.5} />
            添加疫苗记录
          </Button>
        </div>
      )}

      {/* Checkup Records Tab */}
      {activeTab === 'checkup' && (
        <div className="space-y-3">
          {checkupRecords.map((record, index) => (
            <Card 
              key={index}
              onClick={() => onNavigate('health-detail')}
              className="p-4 bg-white border border-[#E0E0E0] cursor-pointer transition-all hover:border-[#FFD84D]"
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3 flex-1">
                  <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
                    <Heart className="w-5 h-5 text-[#66BB6A]" strokeWidth={1.5} />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>
                        {record.type}
                      </h4>
                      <Badge className="px-2 py-0.5 rounded bg-[#EDF7ED] text-[#2E7D32] text-[11px] border-none">
                        {record.result}
                      </Badge>
                    </div>
                    <p className="text-caption text-[#9E9E9E] mb-2">{record.date} · {record.hospital}</p>
                    <p className="text-caption text-[#424242] bg-[#F5F5F5] p-2 rounded-md">
                      {record.notes}
                    </p>
                  </div>
                </div>
                <ChevronRight className="w-5 h-5 text-[#9E9E9E] flex-shrink-0" strokeWidth={1.5} />
              </div>
            </Card>
          ))}

          <Button
            onClick={() => onNavigate('health-detail')}
            className="w-full h-12 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242] border border-[#E0E0E0]"
          >
            <Plus className="w-4 h-4 mr-2" strokeWidth={1.5} />
            添加体检记录
          </Button>
        </div>
      )}

      {/* Daily Data Tab */}
      {activeTab === 'daily' && (
        <div className="space-y-3">
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h4 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>
              主人，我今天的状态
            </h4>
            
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 rounded-md border border-[#E0E0E0]">
                <div className="flex items-center gap-2 mb-2">
                  <Activity className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">活跃度</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.mood}</p>
              </div>

              <div className="p-3 rounded-md border border-[#E0E0E0]">
                <div className="flex items-center gap-2 mb-2">
                  <Pill className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">食欲</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.appetite}</p>
              </div>

              <div className="p-3 rounded-md border border-[#E0E0E0]">
                <div className="flex items-center gap-2 mb-2">
                  <Moon className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">睡眠</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.sleep}</p>
                <span className="text-caption text-[#66BB6A]">{dailyStats.trend.sleep}</span>
              </div>

              <div className="p-3 rounded-md border border-[#E0E0E0]">
                <div className="flex items-center gap-2 mb-2">
                  <Droplet className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">饮水</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{dailyStats.today.water}</p>
                <span className="text-caption text-[#9E9E9E]">{dailyStats.trend.water}</span>
              </div>
            </div>
          </Card>

          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-[#FFD84D] flex items-center justify-center flex-shrink-0">
                <TrendingUp className="w-4 h-4 text-[#424242]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>
                  主人，我的体重在稳步增长哦
                </p>
                <p className="text-caption text-[#9E9E9E]">
                  本月增长0.2kg，营养均衡，继续保持！
                </p>
              </div>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
