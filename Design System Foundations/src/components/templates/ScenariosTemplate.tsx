import { useState, useContext } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Switch } from '../ui/switch';
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from '../ui/sheet';
import { 
  Wifi, 
  Battery, 
  Thermometer, 
  Volume2, 
  Sun,
  Smartphone,
  ChevronRight,
  Droplets,
  Lock,
  Box,
  FileText,
  MapPin,
  Calendar,
  Download,
  Share2,
  CheckCircle2,
  Plane,
  Layers,
  Home as HomeIcon,
  Heart,
  Building2
} from 'lucide-react';
import { ScenarioContext } from '../../App';

interface ScenariosTemplateProps {
  onNavigate: (page: string) => void;
}

export function ScenariosTemplate({ onNavigate }: ScenariosTemplateProps) {
  const [activeTab, setActiveTab] = useState<'travel-box' | 'documents' | 'plans'>('travel-box');
  const [showScenarioSelector, setShowScenarioSelector] = useState(false);
  const { currentScenario, setCurrentScenario } = useContext(ScenarioContext);
  const [doorLocked, setDoorLocked] = useState(true);

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

  const deviceInfo = {
    name: "出行箱 Pro",
    model: "TB-2024",
    serialNumber: "SN20240915001",
    firmwareVersion: "v2.1.3",
    battery: 85,
    connected: true,
    temperature: 23,
    humidity: 85,
    petName: "小白"
  };

  // 证件数据
  const documents = [
    {
      id: 1,
      type: '免疫证明',
      status: '有效',
      issueDate: '2025-01-10',
      validUntil: '2026-01-10'
    },
    {
      id: 2,
      type: '健康证明',
      status: '有效',
      issueDate: '2024-11-20',
      validUntil: '2025-11-20'
    },
    {
      id: 3,
      type: '猫类数证证',
      status: '有效',
      issueDate: '2022-03-15',
      validUntil: '2027-03-15'
    }
  ];

  // 出行计划数据
  const travelPlan = {
    destination: '杭州出行',
    location: '小白',
    departureDate: '2025-10-05',
    returnDate: '2025-10-07',
    duration: '2天',
    transportation: '自驾',
    status: '准备中',
    hotel: {
      name: '西湖宠物友好酒店',
      address: '杭州市西湖区',
      checkIn: '2025-10-05 15:00',
      checkOut: '2025-10-07 12:00'
    },
    weather: {
      description: '杭州10-05 多云，气温 18-26°C',
      tip: '建议携带宠物外套，注意温度调节'
    },
    checklist: [
      { item: '检查出行箱电量', checked: true },
      { item: '准备宠物食物和水', checked: true },
      { item: '携带宠物玩具', checked: false },
      { item: '准备宠物药品', checked: false },
      { item: '检查天气预报', checked: true }
    ]
  };

  const tabs = [
    { id: 'travel-box' as const, label: '出行箱' },
    { id: 'documents' as const, label: '资料包' },
    { id: 'plans' as const, label: '出行计划' }
  ];

  return (
    <div className="pb-6 pt-5">
      {/* Current Scenario Status */}
      <Card 
        className="p-4 bg-white relative overflow-hidden mb-5"
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
            onClick={() => setShowScenarioSelector(true)}
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

      {/* Tab Selector */}
      <div className="flex gap-2 mb-5 overflow-x-auto pb-2 -mx-1 px-1">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex-shrink-0 h-9 px-4 rounded-full transition-all ${ 
              activeTab === tab.id
                ? 'bg-[#FFD84D] text-[#424242]'
                : 'bg-white text-[#9E9E9E] border border-[#E0E0E0]'
            }`}
            style={{ boxShadow: activeTab === tab.id ? '0 1px 2px rgba(0, 0, 0, 0.04)' : 'none' }}
          >
            <span className="text-caption" style={{ fontWeight: activeTab === tab.id ? 600 : 400 }}>{tab.label}</span>
          </button>
        ))}
      </div>

      {/* Travel Box Tab */}
      {activeTab === 'travel-box' && (
        <div className="space-y-4">
          {/* Device Online Status */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-[#66BB6A]" />
                <span className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>设备在线</span>
              </div>
              <span className="text-caption text-[#9E9E9E]">更新于 2 分钟前</span>
            </div>
          </Card>

          {/* Quick Control - Temperature & Humidity */}
          <div className="grid grid-cols-2 gap-3">
            <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
              <div className="flex items-center gap-2 mb-1">
                <Thermometer className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                <span className="text-caption text-[#9E9E9E]">温度</span>
              </div>
              <p className="text-[24px] text-[#424242] mb-1" style={{ fontWeight: 600, lineHeight: '32px' }}>{deviceInfo.temperature}°C</p>
              <span className="text-caption text-[#9E9E9E]">适宜</span>
            </Card>

            <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
              <div className="flex items-center gap-2 mb-1">
                <Droplets className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                <span className="text-caption text-[#9E9E9E]">电量</span>
              </div>
              <p className="text-[24px] text-[#424242] mb-1" style={{ fontWeight: 600, lineHeight: '32px' }}>{deviceInfo.battery}%</p>
              {/* Battery Progress */}
              <div className="w-full h-1 bg-[#F5F5F5] rounded-full overflow-hidden">
                <div 
                  className="h-full bg-[#FFD84D] rounded-full transition-all"
                  style={{ width: `${deviceInfo.battery}%` }}
                />
              </div>
            </Card>
          </div>

          {/* Quick Control - Door Lock */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md bg-white flex items-center justify-center">
                  <Lock className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>门锁</p>
                  <p className="text-caption text-[#9E9E9E]">{doorLocked ? '已锁定' : '已解锁'}</p>
                </div>
              </div>
              <Switch 
                checked={doorLocked}
                onCheckedChange={setDoorLocked}
              />
            </div>
          </Card>

          {/* More Settings Button */}
          <Button
            onClick={() => onNavigate('travel-box-settings')}
            className="w-full h-12 rounded-md bg-[#F5C842] hover:bg-[#E6B930] text-[#424242] border-none"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            更多设备设置
          </Button>
        </div>
      )}

      {/* Documents Tab */}
      {activeTab === 'documents' && (
        <div className="space-y-4">
          {/* Documents List */}
          <Card className="divide-y divide-[#F5F5F5] bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            {documents.map((doc) => (
              <div key={doc.id} className="p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
                    <FileText className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                  </div>
                  <div>
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>{doc.type}</p>
                    <p className="text-caption text-[#9E9E9E]">签发：{doc.issueDate}</p>
                    <p className="text-caption text-[#9E9E9E]">有效至：{doc.validUntil}</p>
                  </div>
                </div>
                <Badge className="px-2 py-1 rounded-md bg-[#EDF7ED] text-[#2E7D32] border-none">
                  {doc.status}
                </Badge>
              </div>
            ))}
          </Card>

          {/* Action Buttons */}
          <div className="grid grid-cols-2 gap-3">
            <Button
              variant="outline"
              className="h-11 rounded-md border-[#E0E0E0] bg-white hover:bg-[#F5F5F5] text-[#424242]"
            >
              <Download className="w-4 h-4 mr-2" strokeWidth={1.5} />
              下载
            </Button>
            <Button
              variant="outline"
              className="h-11 rounded-md border-[#E0E0E0] bg-white hover:bg-[#F5F5F5] text-[#424242]"
            >
              <Share2 className="w-4 h-4 mr-2" strokeWidth={1.5} />
              分享
            </Button>
          </div>

          {/* Export Package Tip */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-[#F5C842] flex items-center justify-center flex-shrink-0">
                <FileText className="w-4 h-4 text-[#424242]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>导出资料包</p>
                <p className="text-caption text-[#9E9E9E] mb-3">
                  一键生成完整资料包，包含所有有效证件，便于跨境旅行时随时查看
                </p>
                <Button
                  variant="link"
                  className="h-auto p-0 text-caption text-[#2F5233]"
                  style={{ fontWeight: 600 }}
                >
                  立即导出
                </Button>
              </div>
            </div>
          </Card>
        </div>
      )}

      {/* Travel Plans Tab */}
      {activeTab === 'plans' && (
        <div className="space-y-4">
          {/* Travel Plan Card */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <MapPin className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{travelPlan.destination}</h3>
              </div>
              <Badge className="px-2 py-1 rounded-md bg-[#FFFBEA] text-[#9E9E9E] border border-[#FFD84D]/30">
                {travelPlan.status}
              </Badge>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">出发日期</span>
                <span className="text-caption text-[#424242]">{travelPlan.departureDate}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">返程日期</span>
                <span className="text-caption text-[#424242]">{travelPlan.returnDate}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">出行时长</span>
                <span className="text-caption text-[#424242]">{travelPlan.duration}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-caption text-[#9E9E9E]">交通方式</span>
                <span className="text-caption text-[#424242]">{travelPlan.transportation}</span>
              </div>
            </div>
          </Card>

          {/* Device Status */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-[#66BB6A]" />
                <span className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>设备在线</span>
              </div>
              <span className="text-caption text-[#9E9E9E]">更新于 2 分钟前</span>
            </div>

            {/* Quick Control */}
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 rounded-md bg-[#F5F5F5]">
                <div className="flex items-center gap-2 mb-1">
                  <Thermometer className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">温度</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{deviceInfo.temperature}°C</p>
              </div>

              <div className="p-3 rounded-md bg-[#F5F5F5]">
                <div className="flex items-center gap-2 mb-1">
                  <Droplets className="w-4 h-4 text-[#9E9E9E]" strokeWidth={1.5} />
                  <span className="text-caption text-[#9E9E9E]">电量</span>
                </div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{deviceInfo.battery}%</p>
              </div>
            </div>
          </Card>

          {/* Quick Control - Door Lock */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-md bg-white flex items-center justify-center">
                  <Lock className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>门锁</p>
                  <p className="text-caption text-[#9E9E9E]">{doorLocked ? '已锁定' : '已解锁'}</p>
                </div>
              </div>
              <Switch 
                checked={doorLocked}
                onCheckedChange={setDoorLocked}
              />
            </div>
          </Card>

          {/* More Settings */}
          <Button
            onClick={() => onNavigate('travel-box-settings')}
            className="w-full h-12 rounded-md bg-[#F5C842] hover:bg-[#E6B930] text-[#424242] border-none"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            更多设备设置
          </Button>

          {/* Hotel Information */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-caption text-[#424242] mb-3" style={{ fontWeight: 600 }}>住宿信息</h3>
            <div className="space-y-2">
              <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>{travelPlan.hotel.name}</p>
              <p className="text-caption text-[#9E9E9E]">{travelPlan.hotel.address}</p>
              <div className="flex items-center justify-between pt-2">
                <div>
                  <p className="text-caption text-[#9E9E9E]">入住时间</p>
                  <p className="text-caption text-[#424242]">{travelPlan.hotel.checkIn}</p>
                </div>
                <div>
                  <p className="text-caption text-[#9E9E9E]">退房时间</p>
                  <p className="text-caption text-[#424242]">{travelPlan.hotel.checkOut}</p>
                </div>
              </div>
            </div>
          </Card>

          {/* Weather Reminder */}
          <Card className="p-4 bg-[#E3F2FD] border border-[#42A5F5]/20" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-3">
              <Sun className="w-5 h-5 text-[#42A5F5] flex-shrink-0 mt-0.5" strokeWidth={1.5} />
              <div>
                <h3 className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>天气提醒</h3>
                <p className="text-caption text-[#424242] mb-1">{travelPlan.weather.description}</p>
                <p className="text-caption text-[#9E9E9E]">{travelPlan.weather.tip}</p>
              </div>
            </div>
          </Card>

          {/* Preparation Checklist */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-caption text-[#424242] mb-3" style={{ fontWeight: 600 }}>准备清单</h3>
            <div className="space-y-0">
              <div className="p-3 rounded-md bg-[#F5F5F5] mb-2">
                <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>基本准备</p>
              </div>
              {travelPlan.checklist.map((item, index) => (
                <div key={index} className="flex items-center justify-between py-2">
                  <div className="flex items-center gap-2">
                    {item.checked ? (
                      <CheckCircle2 className="w-4 h-4 text-[#66BB6A]" strokeWidth={1.5} />
                    ) : (
                      <div className="w-4 h-4 rounded-full border-2 border-[#E0E0E0]" />
                    )}
                    <span className={`text-caption ${item.checked ? 'text-[#9E9E9E] line-through' : 'text-[#424242]'}`}>
                      {item.item}
                    </span>
                  </div>
                  {item.checked && (
                    <CheckCircle2 className="w-4 h-4 text-[#66BB6A]" strokeWidth={1.5} />
                  )}
                </div>
              ))}
            </div>
          </Card>

          {/* Export Package Tip */}
          <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-[#F5C842] flex items-center justify-center flex-shrink-0">
                <FileText className="w-4 h-4 text-[#424242]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>导出资料包</p>
                <p className="text-caption text-[#9E9E9E] mb-3">
                  一键生成完整资料包，包含所有有效证件，便于跨境旅行时随时查看
                </p>
                <Button
                  variant="link"
                  className="h-auto p-0 text-caption text-[#2F5233]"
                  style={{ fontWeight: 600 }}
                >
                  立即导出
                </Button>
              </div>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}
