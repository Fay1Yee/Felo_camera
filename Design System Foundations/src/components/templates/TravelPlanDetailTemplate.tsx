import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Checkbox } from '../ui/checkbox';
import { 
  MapPin, 
  Calendar, 
  Clock,
  CheckCircle,
  Circle,
  Edit,
  Share2,
  Thermometer,
  Shield,
  FileText,
  Package,
  Heart,
  AlertCircle,
  Plus
} from 'lucide-react';

interface TravelPlanDetailTemplateProps {
  onNavigate: (page: any) => void;
}

export function TravelPlanDetailTemplate({ onNavigate }: TravelPlanDetailTemplateProps) {
  const [checklist, setChecklist] = useState({
    preparation: [
      { id: 1, task: "主人检查了我的出行箱电量", completed: true },
      { id: 2, task: "主人给我准备了食物和水", completed: true },
      { id: 3, task: "主人带上了我的免疫证明", completed: true },
      { id: 4, task: "主人给我准备了玩具", completed: true },
      { id: 5, task: "主人查看了天气预报", completed: true }
    ],
    health: [
      { id: 6, task: "主人确认了我的疫苗接种记录", completed: true },
      { id: 7, task: "主人带上了我的健康证明", completed: true },
      { id: 8, task: "主人要准备我的常用药品", completed: false }
    ],
    documents: [
      { id: 9, task: "带上我的登记证", completed: true },
      { id: 10, task: "带上我的保险单", completed: false }
    ],
    equipment: [
      { id: 11, task: "我的出行箱设置完成啦", completed: true },
      { id: 12, task: "带上我的牵引绳和项圈", completed: true },
      { id: 13, task: "带上我的便携水碗", completed: false }
    ]
  });

  const tripInfo = {
    destination: "杭州",
    startDate: "2025-10-05",
    endDate: "2025-10-07",
    duration: "2天",
    status: "准备中",
    pet: "小白",
    transportation: "自驾"
  };

  const accommodationInfo = {
    hotel: "西湖宠物友好酒店",
    address: "杭州市西湖区",
    checkIn: "2025-10-05 15:00",
    checkOut: "2025-10-07 12:00",
    petPolicy: "允许携带中小型宠物"
  };

  const totalTasks = Object.values(checklist).flat().length;
  const completedTasks = Object.values(checklist).flat().filter(task => task.completed).length;
  const progress = Math.round((completedTasks / totalTasks) * 100);

  const toggleTask = (category: keyof typeof checklist, taskId: number) => {
    setChecklist(prev => ({
      ...prev,
      [category]: prev[category].map(task => 
        task.id === taskId ? { ...task, completed: !task.completed } : task
      )
    }));
  };

  return (
    <div className="space-y-6 pb-8">
      {/* Trip Header */}
      <div className="pt-6">
        <Card className="p-6 border border-gray-100 shadow-none bg-[#FFFBEA] relative overflow-hidden">
          <div className="absolute inset-0 dot-grid-bg text-gray-900" />
          <div className="relative">
            <div className="flex items-start justify-between mb-6">
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full bg-white flex items-center justify-center">
                  <MapPin className="w-7 h-7 text-gray-900" strokeWidth={1.5} />
                </div>
                <div>
                  <h2 className="text-title mb-1">{tripInfo.destination}出行</h2>
                  <p className="text-caption text-gray-500">{tripInfo.pet}</p>
                </div>
              </div>
              <div className="px-4 py-2 rounded-full bg-white text-caption">
                {tripInfo.status}
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-5">
              <div>
                <p className="text-caption text-gray-500 mb-1">出发日期</p>
                <p className="text-body">{tripInfo.startDate}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">返程日期</p>
                <p className="text-body">{tripInfo.endDate}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">出行时长</p>
                <p className="text-body">{tripInfo.duration}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">交通方式</p>
                <p className="text-body">{tripInfo.transportation}</p>
              </div>
            </div>

            {/* Progress */}
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-caption text-gray-500">准备进度</span>
                <span className="text-body">{completedTasks}/{totalTasks} ({progress}%)</span>
              </div>
              <div className="h-3 bg-white rounded-full overflow-hidden">
                <div 
                  className="h-full bg-[#2F5233] transition-all duration-500"
                  style={{ width: `${progress}%` }}
                />
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Button
          variant="outline"
          className="h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
        >
          <Edit className="w-5 h-5 mr-2" strokeWidth={1.5} />
          编辑计划
        </Button>
        <Button
          variant="outline"
          className="h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
        >
          <Share2 className="w-5 h-5 mr-2" strokeWidth={1.5} />
          分享
        </Button>
      </div>

      {/* Accommodation Info */}
      <div>
        <h3 className="text-body mb-4">住宿信息</h3>
        <Card className="p-6 border border-gray-100 shadow-none">
          <div className="space-y-4">
            <div>
              <h4 className="text-body mb-1">{accommodationInfo.hotel}</h4>
              <p className="text-caption text-gray-400">{accommodationInfo.address}</p>
            </div>
            <div className="dot-divider text-gray-300" />
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-caption text-gray-500 mb-1">入住时间</p>
                <p className="text-body">{accommodationInfo.checkIn}</p>
              </div>
              <div>
                <p className="text-caption text-gray-500 mb-1">退房时间</p>
                <p className="text-body">{accommodationInfo.checkOut}</p>
              </div>
            </div>
            <div className="dot-divider text-gray-300" />
            <div className="p-4 bg-[#F5F5F0] rounded-2xl">
              <p className="text-caption text-gray-500 mb-1">宠物政策</p>
              <p className="text-body">{accommodationInfo.petPolicy}</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Checklist - Preparation */}
      <div>
        <h3 className="text-body mb-4">准备清单</h3>
        <Card className="p-6 border border-gray-100 shadow-none">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
              <Package className="w-5 h-5 text-gray-900" strokeWidth={1.5} />
            </div>
            <h4 className="text-body">基本准备</h4>
          </div>
          <div className="space-y-4">
            {checklist.preparation.map((task) => (
              <div key={task.id} className="flex items-center gap-3">
                <Checkbox
                  checked={task.completed}
                  onCheckedChange={() => toggleTask('preparation', task.id)}
                  className="rounded-md"
                />
                <span className={`text-body flex-1 ${task.completed ? 'line-through text-gray-400' : ''}`}>
                  {task.task}
                </span>
                {task.completed && (
                  <CheckCircle className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Checklist - Health */}
      <div>
        <Card className="p-6 border border-gray-100 shadow-none">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
              <Heart className="w-5 h-5 text-gray-900" strokeWidth={1.5} />
            </div>
            <h4 className="text-body">健康准备</h4>
          </div>
          <div className="space-y-4">
            {checklist.health.map((task) => (
              <div key={task.id} className="flex items-center gap-3">
                <Checkbox
                  checked={task.completed}
                  onCheckedChange={() => toggleTask('health', task.id)}
                  className="rounded-md"
                />
                <span className={`text-body flex-1 ${task.completed ? 'line-through text-gray-400' : ''}`}>
                  {task.task}
                </span>
                {task.completed && (
                  <CheckCircle className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Checklist - Documents */}
      <div>
        <Card className="p-6 border border-gray-100 shadow-none">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
              <FileText className="w-5 h-5 text-gray-900" strokeWidth={1.5} />
            </div>
            <h4 className="text-body">证件资料</h4>
          </div>
          <div className="space-y-4">
            {checklist.documents.map((task) => (
              <div key={task.id} className="flex items-center gap-3">
                <Checkbox
                  checked={task.completed}
                  onCheckedChange={() => toggleTask('documents', task.id)}
                  className="rounded-md"
                />
                <span className={`text-body flex-1 ${task.completed ? 'line-through text-gray-400' : ''}`}>
                  {task.task}
                </span>
                {task.completed && (
                  <CheckCircle className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Checklist - Equipment */}
      <div>
        <Card className="p-6 border border-gray-100 shadow-none">
          <div className="flex items-center gap-3 mb-5">
            <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
              <Shield className="w-5 h-5 text-gray-900" strokeWidth={1.5} />
            </div>
            <h4 className="text-body">设备装备</h4>
          </div>
          <div className="space-y-4">
            {checklist.equipment.map((task) => (
              <div key={task.id} className="flex items-center gap-3">
                <Checkbox
                  checked={task.completed}
                  onCheckedChange={() => toggleTask('equipment', task.id)}
                  className="rounded-md"
                />
                <span className={`text-body flex-1 ${task.completed ? 'line-through text-gray-400' : ''}`}>
                  {task.task}
                </span>
                {task.completed && (
                  <CheckCircle className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Add Custom Item */}
      <Button 
        variant="outline"
        className="w-full h-12 rounded-full border-2 border-dashed border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
      >
        <Plus className="w-5 h-5 mr-2" strokeWidth={1.5} />
        添加自定义项目
      </Button>

      {/* Weather Alert */}
      <Card className="p-5 border border-gray-100 shadow-none bg-[#FFFBEA]">
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
            <Thermometer className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <h4 className="text-body mb-1">天气提醒</h4>
            <p className="text-caption text-gray-500 mb-2">
              {tripInfo.destination}预计 {tripInfo.startDate.slice(5)} 多云，气温 18-25°C
            </p>
            <p className="text-caption text-gray-500">
              建议携带宠物外套，注意温度调节
            </p>
          </div>
        </div>
      </Card>

      {/* Important Tips */}
      <Card className="p-5 border border-gray-100 shadow-none bg-[#F5F5F0]">
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
            <AlertCircle className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <h4 className="text-body mb-2">出行建议</h4>
            <ul className="space-y-1 text-caption text-gray-600">
              <li>• 提前检查出行箱电量和设备状态</li>
              <li>• 准备充足的宠物食物和饮用水</li>
              <li>• 携带宠物常用药品和急救用品</li>
              <li>• 确认住宿地的宠物政策</li>
              <li>• 记录当地宠物医院联系方式</li>
            </ul>
          </div>
        </div>
      </Card>

      {/* Complete Button */}
      {progress === 100 ? (
        <Button 
          className="w-full h-14 rounded-full bg-[#2F5233] hover:bg-[#1F3823] text-white border-none"
        >
          <CheckCircle className="w-5 h-5 mr-2" strokeWidth={1.5} />
          准备完成，开始出行
        </Button>
      ) : (
        <Button 
          className="w-full h-14 rounded-full bg-[#FFD84D] hover:bg-[#FFC107] text-gray-900 border-none"
        >
          继续完成准备 ({completedTasks}/{totalTasks})
        </Button>
      )}
    </div>
  );
}