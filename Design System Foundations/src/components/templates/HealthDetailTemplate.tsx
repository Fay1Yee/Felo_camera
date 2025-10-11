import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { FileText, Download, Share2, Calendar, MapPin, User, Pill, Activity, TrendingUp, AlertCircle, Edit, ArrowUp, ArrowDown, Minus } from 'lucide-react';
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface HealthDetailTemplateProps {
  onNavigate: (page: any) => void;
}

export function HealthDetailTemplate({ onNavigate }: HealthDetailTemplateProps) {
  const [activeTab, setActiveTab] = useState('overview');

  // Mock data for health record detail
  const recordDetail = {
    type: "年度体检",
    date: "2024-11-20",
    hospital: "宠物中心医院",
    doctor: "张医生",
    petName: "小白",
    result: "健康",
    nextCheckup: "2025-11-20",
    files: 2
  };

  const examinationItems = [
    {
      category: "血液检查",
      items: [
        { name: "白细胞", value: "7.2", unit: "10^9/L", range: "6.0-17.0", status: "normal" },
        { name: "红细胞", value: "6.8", unit: "10^12/L", range: "5.5-8.5", status: "normal" },
        { name: "血小板", value: "285", unit: "10^9/L", range: "200-500", status: "normal" },
        { name: "血红蛋白", value: "145", unit: "g/L", range: "120-180", status: "normal" }
      ]
    },
    {
      category: "生化指标",
      items: [
        { name: "总蛋白", value: "68", unit: "g/L", range: "54-78", status: "normal" },
        { name: "白蛋白", value: "32", unit: "g/L", range: "26-40", status: "normal" },
        { name: "尿素氮", value: "6.5", unit: "mmol/L", range: "3.5-9.2", status: "normal" },
        { name: "肌酐", value: "85", unit: "μmol/L", range: "44-141", status: "normal" }
      ]
    },
    {
      category: "器官检查",
      items: [
        { name: "心脏", value: "正常", unit: "", range: "", status: "normal" },
        { name: "肺部", value: "正常", unit: "", range: "", status: "normal" },
        { name: "肝脏", value: "正常", unit: "", range: "", status: "normal" },
        { name: "肾脏", value: "正常", unit: "", range: "", status: "normal" }
      ]
    }
  ];

  const vitalSigns = [
    { label: "体重", value: "6.2", unit: "kg", trend: "up", change: "+0.1", previous: "6.1" },
    { label: "体温", value: "38.5", unit: "°C", trend: "stable", change: "0", previous: "38.5" },
    { label: "心率", value: "95", unit: "次/分", trend: "down", change: "-2", previous: "97" },
    { label: "呼吸", value: "24", unit: "次/分", trend: "stable", change: "0", previous: "24" }
  ];

  // Historical weight data for trend chart
  const weightHistory = [
    { date: '6个月前', weight: 5.8 },
    { date: '5个月前', weight: 5.9 },
    { date: '4个月前', weight: 6.0 },
    { date: '3个月前', weight: 6.0 },
    { date: '2个月前', weight: 6.1 },
    { date: '1个月前', weight: 6.1 },
    { date: '本次', weight: 6.2 },
  ];

  const doctorNotes = [
    "主人，医生说我很健康，各项指标都正常哦",
    "主人，医生建议继续保持现在的饮食和运动习惯",
    "主人，下次体检在一年后就可以啦",
    "主人，如果我有不舒服，要记得及时带我看医生"
  ];

  const prescriptions = [
    {
      name: "复合维生素片",
      dosage: "1片/天",
      duration: "30天",
      notes: "饭后服用"
    }
  ];

  return (
    <div className="space-y-6 pb-8">
      {/* Record Header */}
      <div className="pt-6">
        <Card className="p-6 border border-gray-100 shadow-none bg-[#FFFBEA] relative overflow-hidden">
          <div className="absolute inset-0 dot-grid-bg text-gray-900" />
          <div className="relative">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center">
                  <FileText className="w-6 h-6 text-gray-900" strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="text-title mb-1">{recordDetail.type}</h2>
                  <p className="text-caption text-gray-500">{recordDetail.petName}</p>
                </div>
              </div>
              <div className={`px-4 py-2 rounded-full text-caption ${
                recordDetail.result === '健康' ? 'bg-white' : 'bg-gray-100'
              }`}>
                {recordDetail.result}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-5">
              <div>
                <p className="text-caption text-gray-500 mb-1">检查日期</p>
                <p className="text-body">{recordDetail.date}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">下次体检</p>
                <p className="text-body">{recordDetail.nextCheckup}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">医院</p>
                <p className="text-body">{recordDetail.hospital}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">医生</p>
                <p className="text-body">{recordDetail.doctor}</p>
              </div>
            </div>

            <div className="flex gap-2">
              <Button 
                variant="outline"
                size="sm"
                className="flex-1 h-10 rounded-full bg-white border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <Download className="w-4 h-4 mr-2" strokeWidth={1.5} />
                下载报告
              </Button>
              <Button 
                variant="outline"
                size="sm"
                className="flex-1 h-10 rounded-full bg-white border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <Share2 className="w-4 h-4 mr-2" strokeWidth={1.5} />
                分享
              </Button>
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
            概览
          </TabsTrigger>
          <TabsTrigger 
            value="details" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            检查详情
          </TabsTrigger>
          <TabsTrigger 
            value="prescription" 
            className="rounded-full data-[state=active]:bg-[#FFD84D] data-[state=active]:text-gray-900"
          >
            处方
          </TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview" className="space-y-6 mt-6">
          {/* Vital Signs - Compact Grid */}
          <div>
            <h3 className="text-body mb-4">生命体征</h3>
            <div className="grid grid-cols-2 gap-3">
              {vitalSigns.map((vital, index) => (
                <Card 
                  key={index}
                  className="p-4 border border-gray-100 shadow-none relative overflow-hidden"
                >
                  <div className="absolute inset-0 dot-grid-bg text-gray-900" />
                  <div className="relative">
                    <p className="text-caption text-gray-500 mb-1">{vital.label}</p>
                    <div className="flex items-baseline gap-1 mb-1">
                      <span className="text-[22px]">{vital.value}</span>
                      <span className="text-caption text-gray-500">{vital.unit}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-caption text-gray-400">上次: {vital.previous}{vital.unit}</span>
                      <div className={`flex items-center gap-0.5 text-caption ${
                        vital.trend === 'up' ? 'text-[#2F5233]' :
                        vital.trend === 'down' ? 'text-[#FFB300]' :
                        'text-gray-400'
                      }`}>
                        {vital.trend === 'up' && <ArrowUp className="w-3 h-3" strokeWidth={2} />}
                        {vital.trend === 'down' && <ArrowDown className="w-3 h-3" strokeWidth={2} />}
                        {vital.trend === 'stable' && <Minus className="w-3 h-3" strokeWidth={2} />}
                        {vital.change}
                      </div>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* Weight Trend Chart */}
          <div>
            <h3 className="text-body mb-4 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
              体重趋势
            </h3>
            <Card className="p-5 border border-gray-100 shadow-none bg-white">
              <ResponsiveContainer width="100%" height={180}>
                <AreaChart data={weightHistory}>
                  <defs>
                    <linearGradient id="weightGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#FFD84D" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#FFD84D" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#ECEFF1" />
                  <XAxis 
                    dataKey="date" 
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <YAxis 
                    domain={[5.5, 6.5]}
                    tick={{ fontSize: 11, fill: '#90A4AE' }}
                    tickLine={false}
                    axisLine={{ stroke: '#ECEFF1' }}
                  />
                  <Tooltip 
                    contentStyle={{ 
                      borderRadius: '12px', 
                      border: '1px solid #ECEFF1',
                      fontSize: '13px'
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="weight" 
                    stroke="#FFD84D" 
                    strokeWidth={2}
                    fill="url(#weightGradient)" 
                  />
                </AreaChart>
              </ResponsiveContainer>
              <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full bg-[#2F5233]" />
                  <span className="text-caption text-gray-500">健康增长趋势</span>
                </div>
                <span className="text-caption text-[#2F5233]">+6.9% (6个月)</span>
              </div>
            </Card>
          </div>

          {/* Doctor's Notes */}
          <div>
            <h3 className="text-body mb-4">医嘱建议</h3>
            <Card className="p-6 border border-gray-100 shadow-none bg-[#F5F5F0]">
              <div className="space-y-3">
                {doctorNotes.map((note, index) => (
                  <div key={index} className="flex gap-3">
                    <div className="w-2 h-2 rounded-full bg-[#FFD84D] flex-shrink-0 mt-2" />
                    <p className="text-body text-gray-700 flex-1">{note}</p>
                  </div>
                ))}
              </div>
            </Card>
          </div>

          {/* Quick Summary */}
          <Card className="p-5 border border-gray-100 shadow-none bg-white">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-[#FFFBEA] flex items-center justify-center flex-shrink-0">
                <span className="text-lg">✅</span>
              </div>
              <div className="flex-1">
                <h4 className="text-body mb-1">检查总结</h4>
                <p className="text-caption text-gray-500">
                  本次体检共检查 {examinationItems.reduce((sum, cat) => sum + cat.items.length, 0)} 项指标，
                  所有指标均在正常范围内，整体健康状况良好。
                </p>
              </div>
            </div>
          </Card>
        </TabsContent>

        {/* Details Tab */}
        <TabsContent value="details" className="space-y-6 mt-6">
          {examinationItems.map((category, catIndex) => (
            <div key={catIndex}>
              <h3 className="text-body mb-3">{category.category}</h3>
              <Card className="p-4 border border-gray-100 shadow-none">
                <div className="space-y-3">
                  {category.items.map((item, itemIndex) => (
                    <div key={itemIndex}>
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-0.5">
                            <span className="text-body">{item.name}</span>
                            {item.status === 'normal' && (
                              <div className="w-5 h-5 rounded-full bg-[#E8F5E9] flex items-center justify-center flex-shrink-0">
                                <div className="w-1.5 h-1.5 rounded-full bg-[#2F5233]" />
                              </div>
                            )}
                          </div>
                          {item.range && (
                            <p className="text-caption text-gray-400">范围: {item.range}</p>
                          )}
                        </div>
                        
                        <div className="flex items-baseline gap-1 flex-shrink-0">
                          <span className="text-[18px]">{item.value}</span>
                          {item.unit && (
                            <span className="text-caption text-gray-500">{item.unit}</span>
                          )}
                        </div>
                      </div>
                      
                      {itemIndex < category.items.length - 1 && (
                        <div className="dot-divider text-gray-300 mt-3" />
                      )}
                    </div>
                  ))}
                </div>
              </Card>
            </div>
          ))}

          {/* Attached Files */}
          <div>
            <h3 className="text-body mb-4">附件文件</h3>
            <Card className="p-5 border border-gray-100 shadow-none hover:border-[#FFD84D] transition-all cursor-pointer">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full border-2 border-dashed border-gray-200 flex items-center justify-center">
                    <FileText className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                  </div>
                  <div>
                    <p className="text-body">体检报告.pdf</p>
                    <p className="text-caption text-gray-400">2.3 MB</p>
                  </div>
                </div>
                <Button variant="ghost" size="sm" className="h-9 w-9 p-0 rounded-full">
                  <Download className="w-4 h-4" strokeWidth={1.5} />
                </Button>
              </div>
            </Card>
          </div>
        </TabsContent>

        {/* Prescription Tab */}
        <TabsContent value="prescription" className="space-y-6 mt-6">
          {prescriptions.length > 0 ? (
            <div className="space-y-3">
              {prescriptions.map((prescription, index) => (
                <Card 
                  key={index}
                  className="p-6 border border-gray-100 shadow-none hover:border-[#FFD84D] transition-all"
                >
                  <div className="flex items-start gap-4 mb-4">
                    <div className="w-12 h-12 rounded-full bg-[#FFFBEA] flex items-center justify-center flex-shrink-0">
                      <Pill className="w-6 h-6 text-gray-900" strokeWidth={1.5} />
                    </div>
                    <div className="flex-1">
                      <h4 className="text-body mb-1">{prescription.name}</h4>
                      <p className="text-caption text-gray-500">{prescription.notes}</p>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4 p-4 bg-[#F5F5F0] rounded-2xl">
                    <div>
                      <p className="text-caption text-gray-500 mb-1">用量</p>
                      <p className="text-body">{prescription.dosage}</p>
                    </div>
                    <div>
                      <p className="text-caption text-gray-500 mb-1">疗程</p>
                      <p className="text-body">{prescription.duration}</p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          ) : (
            <Card className="p-12 border border-gray-100 shadow-none text-center">
              <div className="w-16 h-16 rounded-full bg-[#F5F5F0] flex items-center justify-center mx-auto mb-4">
                <Pill className="w-8 h-8 text-gray-400" strokeWidth={1.5} />
              </div>
              <h3 className="text-body mb-2 text-gray-500">暂无处方</h3>
              <p className="text-caption text-gray-400">本次检查未开具处方</p>
            </Card>
          )}

          {/* Medication Reminder */}
          {prescriptions.length > 0 && (
            <Card className="p-5 border border-gray-100 shadow-none bg-[#FFFBEA]">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
                  <AlertCircle className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div className="flex-1">
                  <h4 className="text-body mb-1">用药提醒</h4>
                  <p className="text-caption text-gray-500 mb-3">
                    可以为宠物设置用药提醒，确保按时服药
                  </p>
                  <Button 
                    size="sm"
                    className="h-9 px-4 rounded-full bg-white hover:bg-gray-50 text-gray-900 border-none"
                  >
                    设置提醒
                  </Button>
                </div>
              </div>
            </Card>
          )}
        </TabsContent>
      </Tabs>

      {/* Edit Button */}
      <Button 
        variant="outline"
        className="w-full h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
      >
        <Edit className="w-5 h-5 mr-2" strokeWidth={1.5} />
        编辑记录
      </Button>
    </div>
  );
}