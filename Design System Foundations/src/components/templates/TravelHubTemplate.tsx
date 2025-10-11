import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { Thermometer, Battery, Wifi, Lock, FileText, QrCode, ChevronRight, Download, Share2, MapPin, Calendar } from 'lucide-react';

interface TravelHubTemplateProps {
  onNavigate: (page: any) => void;
}

export function TravelHubTemplate({ onNavigate }: TravelHubTemplateProps) {
  const [activeTab, setActiveTab] = useState('device');

  // Device Status
  const deviceStatus = {
    connected: true,
    temperature: 23,
    humidity: 65,
    battery: 85,
    locked: true,
    lastUpdate: "2分钟前"
  };

  // Travel Documents
  const documents = [
    {
      id: 1,
      name: "免疫证明",
      type: "疫苗接种",
      issueDate: "2025-01-10",
      validUntil: "2026-01-10",
      status: "有效",
      qrCode: true
    },
    {
      id: 2,
      name: "健康证明",
      type: "体检报告",
      issueDate: "2024-11-20",
      validUntil: "2025-11-20",
      status: "有效",
      qrCode: true
    },
    {
      id: 3,
      name: "犬类登记证",
      type: "官方证件",
      issueDate: "2022-03-15",
      validUntil: "2027-03-15",
      status: "有效",
      qrCode: false
    }
  ];

  // Travel Plans
  const upcomingTrips = [
    {
      id: 1,
      destination: "杭州",
      date: "本周末",
      duration: "2天",
      status: "准备中",
      checklist: {
        total: 8,
        completed: 5
      }
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      {/* Header */}
      <div className="pt-6">
        <h1 className="text-display mb-1">出行工具</h1>
        <p className="text-caption text-gray-400">设备监控 · 证件资料</p>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3 bg-transparent border border-gray-100 rounded-full p-1 h-auto">
          <TabsTrigger 
            value="device" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            出行箱
          </TabsTrigger>
          <TabsTrigger 
            value="documents" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            资料包
          </TabsTrigger>
          <TabsTrigger 
            value="plans" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            出行计划
          </TabsTrigger>
        </TabsList>

        {/* Device Tab */}
        <TabsContent value="device" className="space-y-6 mt-6">
          {/* Connection Status */}
          <Card className="p-6 border border-gray-100 shadow-none bg-[#FFFBEA] relative overflow-hidden">
            <div className="absolute inset-0 dot-grid-bg text-gray-900" />
            <div className="relative">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className={`w-3 h-3 rounded-full ${deviceStatus.connected ? 'bg-[#FFD84D]' : 'bg-gray-300'}`} />
                  <h3 className="text-body">
                    {deviceStatus.connected ? '设备在线' : '设备离线'}
                  </h3>
                </div>
                <Wifi className="w-5 h-5 text-gray-900" strokeWidth={1.5} />
              </div>
              <p className="text-caption text-gray-500">更新于 {deviceStatus.lastUpdate}</p>
            </div>
          </Card>

          {/* Device Metrics */}
          <div className="grid grid-cols-2 gap-4">
            <Card className="p-6 border border-gray-100 shadow-none relative overflow-hidden">
              <div className="absolute inset-0 dot-grid-bg text-gray-900" />
              <div className="relative">
                <div className="flex items-center gap-2 mb-4">
                  <Thermometer className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                  <span className="text-caption text-gray-400">温度</span>
                </div>
                <div className="text-[28px] mb-1">{deviceStatus.temperature}°C</div>
                <div className="text-caption text-gray-400">适宜</div>
              </div>
            </Card>

            <Card className="p-6 border border-gray-100 shadow-none relative overflow-hidden">
              <div className="absolute inset-0 dot-grid-bg text-gray-900" />
              <div className="relative">
                <div className="flex items-center gap-2 mb-4">
                  <Battery className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                  <span className="text-caption text-gray-400">电量</span>
                </div>
                <div className="text-[28px] mb-1">{deviceStatus.battery}%</div>
                <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                  <div 
                    className="h-full bg-[#FFD84D] transition-all"
                    style={{ width: `${deviceStatus.battery}%` }}
                  />
                </div>
              </div>
            </Card>
          </div>

          {/* Quick Control */}
          <Card className="p-6 border border-gray-100 shadow-none">
            <h3 className="text-body mb-4">快捷控制</h3>
            <div className="flex items-center justify-between p-5 bg-[#FFFBEA] rounded-3xl">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-full bg-white flex items-center justify-center">
                  <Lock className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <span className="text-body block mb-1">门锁</span>
                  <span className="text-caption text-gray-500">
                    {deviceStatus.locked ? "已锁定" : "已解锁"}
                  </span>
                </div>
              </div>
              <Switch checked={deviceStatus.locked} />
            </div>
          </Card>

          {/* Settings Link */}
          <Button 
            onClick={() => onNavigate('travel-box-settings')}
            variant="outline"
            className="w-full h-14 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] flex items-center justify-center gap-2"
          >
            更多设备设置
            <ChevronRight className="w-5 h-5" strokeWidth={1.5} />
          </Button>
        </TabsContent>

        {/* Documents Tab */}
        <TabsContent value="documents" className="space-y-6 mt-6">
          <div className="space-y-3">
            {documents.map((doc) => (
              <Card 
                key={doc.id}
                className="p-6 border border-gray-100 shadow-none hover:border-[#FFD84D] transition-all cursor-pointer"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-start gap-4 flex-1">
                    <div className="w-12 h-12 rounded-full border-2 border-dashed border-gray-200 flex items-center justify-center flex-shrink-0">
                      <FileText className="w-6 h-6 text-gray-700" strokeWidth={1.5} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-2">
                        <h4 className="text-body">{doc.name}</h4>
                        <div className={`px-3 py-1 rounded-full text-[13px] ${
                          doc.status === '有效' ? 'bg-[#FFFBEA]' : 'bg-gray-100'
                        }`}>
                          {doc.status}
                        </div>
                      </div>
                      <p className="text-caption text-gray-400 mb-3">{doc.type}</p>
                      <div className="flex flex-wrap gap-x-4 gap-y-1 text-caption text-gray-400">
                        <span>签发 {doc.issueDate}</span>
                        <span>有效至 {doc.validUntil}</span>
                      </div>
                    </div>
                  </div>
                  {doc.qrCode && (
                    <Button 
                      variant="ghost" 
                      size="sm"
                      className="w-10 h-10 p-0 rounded-full flex-shrink-0"
                    >
                      <QrCode className="w-5 h-5" strokeWidth={1.5} />
                    </Button>
                  )}
                </div>
                
                <div className="flex gap-2">
                  <Button 
                    variant="outline"
                    size="sm"
                    className="flex-1 h-10 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] text-caption"
                  >
                    <Download className="w-4 h-4 mr-2" strokeWidth={1.5} />
                    下载
                  </Button>
                  <Button 
                    variant="outline"
                    size="sm"
                    className="flex-1 h-10 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] text-caption"
                  >
                    <Share2 className="w-4 h-4 mr-2" strokeWidth={1.5} />
                    分享
                  </Button>
                </div>
              </Card>
            ))}
          </div>

          <Button 
            variant="outline"
            className="w-full h-14 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] flex items-center justify-center gap-2"
          >
            添加新证件
            <ChevronRight className="w-5 h-5" strokeWidth={1.5} />
          </Button>

          {/* Quick Export */}
          <Card className="p-5 border border-gray-100 shadow-none bg-[#FFFBEA]">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                <span className="text-lg">📦</span>
              </div>
              <div className="flex-1">
                <h4 className="text-body mb-1">导出资料包</h4>
                <p className="text-caption text-gray-500 mb-3">一键生成完整出行资料包，包含所有证件和健康记录</p>
                <Button 
                  size="sm"
                  className="h-9 px-4 rounded-full bg-white hover:bg-gray-50 text-gray-900 border-none"
                >
                  立即导出
                </Button>
              </div>
            </div>
          </Card>
        </TabsContent>

        {/* Plans Tab */}
        <TabsContent value="plans" className="space-y-6 mt-6">
          {upcomingTrips.length > 0 ? (
            <div className="space-y-3">
              {upcomingTrips.map((trip) => (
                <Card 
                  key={trip.id}
                  className="p-6 border border-gray-100 shadow-none hover:border-[#FFD84D] transition-all cursor-pointer"
                >
                  <div className="flex items-start gap-4 mb-5">
                    <div className="w-12 h-12 rounded-full bg-[#FFFBEA] flex items-center justify-center flex-shrink-0">
                      <MapPin className="w-6 h-6 text-gray-900" strokeWidth={1.5} />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <h4 className="text-body">{trip.destination}</h4>
                        <div className="px-3 py-1 rounded-full bg-[#FFFBEA] text-[13px]">
                          {trip.status}
                        </div>
                      </div>
                      <div className="flex gap-4 text-caption text-gray-400">
                        <span className="flex items-center gap-1">
                          <Calendar className="w-3.5 h-3.5" strokeWidth={1.5} />
                          {trip.date}
                        </span>
                        <span>{trip.duration}</span>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-3">
                    <div className="flex items-center justify-between">
                      <span className="text-caption text-gray-400">准备进度</span>
                      <span className="text-caption text-gray-900">{trip.checklist.completed}/{trip.checklist.total}</span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div 
                        className="h-full bg-[#FFD84D] transition-all"
                        style={{ width: `${(trip.checklist.completed / trip.checklist.total) * 100}%` }}
                      />
                    </div>
                  </div>

                  <Button 
                    onClick={(e) => {
                      e.stopPropagation();
                      onNavigate('travel-plan-detail');
                    }}
                    variant="ghost"
                    className="w-full mt-4 h-10 rounded-full hover:bg-[#FFFBEA]"
                  >
                    查看清单
                    <ChevronRight className="w-4 h-4 ml-1" strokeWidth={1.5} />
                  </Button>
                </Card>
              ))}
            </div>
          ) : (
            <Card className="p-12 border border-gray-100 shadow-none text-center">
              <div className="w-16 h-16 rounded-full bg-[#FFFBEA] flex items-center justify-center mx-auto mb-4">
                <MapPin className="w-8 h-8 text-gray-900" strokeWidth={1.5} />
              </div>
              <h3 className="text-body mb-2">暂无出行计划</h3>
              <p className="text-caption text-gray-400 mb-6">创建出行计划，自动生成准备清单</p>
              <Button 
                className="h-12 px-6 rounded-full bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none"
              >
                创建计划
              </Button>
            </Card>
          )}

          {upcomingTrips.length > 0 && (
            <Button 
              variant="outline"
              className="w-full h-14 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] flex items-center justify-center gap-2"
            >
              创建新计划
              <ChevronRight className="w-5 h-5" strokeWidth={1.5} />
            </Button>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}