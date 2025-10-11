import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Switch } from '../ui/switch';
import { 
  Bell, 
  Calendar, 
  Activity, 
  Plus, 
  ChevronRight,
  Syringe,
  Battery,
  Heart,
  Clock,
  Settings,
  Check
} from 'lucide-react';

interface ReminderTemplateProps {
  onNavigate: (page: any) => void;
}

export function ReminderTemplate({ onNavigate }: ReminderTemplateProps) {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);

  const todayReminders = [
    {
      id: 1,
      title: "主人，我该打疫苗啦",
      time: "今天 14:00",
      type: "health",
      urgent: true,
      description: "今年的狂犬疫苗到期啦，主人别忘了带我去哦",
      icon: Syringe,
      color: '#66BB6A',
      bgColor: '#EDF7ED'
    },
    {
      id: 2,
      title: "主人，我的出行箱要充电了",
      time: "今天 18:00",
      type: "device",
      urgent: false,
      description: "电量只剩 20% 了，充满电我们才能出去玩呀",
      icon: Battery,
      color: '#FFA726',
      bgColor: '#FFF3E0'
    }
  ];

  const upcomingReminders = [
    {
      id: 3,
      title: "主人，明天该量体重了",
      time: "明天 09:00",
      type: "health",
      icon: Activity,
      color: '#42A5F5',
      bgColor: '#E3F2FD'
    },
    {
      id: 4,
      title: "主人，我要吃驱虫药了",
      time: "3天后",
      type: "health",
      icon: Heart,
      color: '#66BB6A',
      bgColor: '#EDF7ED'
    },
    {
      id: 5,
      title: "主人，该带我去体检啦",
      time: "1周后",
      type: "health",
      icon: Heart,
      color: '#66BB6A',
      bgColor: '#EDF7ED'
    }
  ];

  const completedReminders = [
    {
      id: 6,
      title: "主人，我今天称重啦",
      time: "今天 08:00",
      completed: true
    },
    {
      id: 7,
      title: "主人，我今天吃药啦",
      time: "昨天 18:00",
      completed: true
    }
  ];

  return (
    <div className="pb-6 pt-5 space-y-5">
      {/* Header with Stats */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <div>
            <h2 className="text-title text-[#424242]">消息中心</h2>
            <p className="text-caption text-[#9E9E9E]">
              主人，我有 {todayReminders.filter(r => r.urgent).length} 件重要的事情要告诉你
            </p>
          </div>
          <Button
            onClick={() => onNavigate('notification-settings')}
            variant="ghost"
            size="sm"
            className="w-9 h-9 p-0 rounded-md hover:bg-[#F5F5F5]"
          >
            <Settings className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
          </Button>
        </div>

        {/* Notification Toggle */}
        <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#FFFBEA] flex items-center justify-center">
                <Bell className="w-5 h-5 text-[#FFD84D]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>推送通知</p>
                <p className="text-caption text-[#9E9E9E]">接收提醒和消息</p>
              </div>
            </div>
            <Switch 
              checked={notificationsEnabled}
              onCheckedChange={setNotificationsEnabled}
            />
          </div>
        </Card>
      </div>

      {/* Today's Reminders */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>今日提醒</h3>
        <div className="space-y-3">
          {todayReminders.map((reminder) => (
            <Card 
              key={reminder.id}
              className={`p-4 cursor-pointer transition-all ${
                reminder.urgent 
                  ? 'bg-[#FFFBEA] border border-[#FFD84D]/30' 
                  : 'bg-white border border-[#E0E0E0]'
              }`}
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <div className="flex items-start gap-3">
                <div 
                  className="w-11 h-11 rounded-md flex items-center justify-center flex-shrink-0"
                  style={{ backgroundColor: reminder.bgColor }}
                >
                  <reminder.icon className="w-5 h-5" style={{ color: reminder.color }} strokeWidth={1.5} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-1">
                    <h4 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>
                      {reminder.title}
                    </h4>
                    {reminder.urgent && (
                      <Badge className="px-2 py-0.5 rounded bg-[#FFF3E0] text-[#FFA726] text-[11px] border-none">
                        紧急
                      </Badge>
                    )}
                  </div>
                  <div className="flex items-center gap-2 mb-2">
                    <Clock className="w-3.5 h-3.5 text-[#9E9E9E]" strokeWidth={1.5} />
                    <p className="text-caption text-[#9E9E9E]">{reminder.time}</p>
                  </div>
                  <p className="text-caption text-[#424242] bg-white p-2 rounded-md">
                    {reminder.description}
                  </p>
                  <div className="flex gap-2 mt-3">
                    <Button
                      size="sm"
                      className="h-8 px-3 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
                    >
                      标记完成
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      className="h-8 px-3 rounded-md border-[#E0E0E0] bg-white hover:bg-[#F5F5F5] text-[#9E9E9E]"
                    >
                      稍后提醒
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* Upcoming Reminders */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>即将到来</h3>
        <Card className="divide-y divide-[#F5F5F5] bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          {upcomingReminders.map((reminder) => (
            <div key={reminder.id} className="p-4 flex items-center gap-3 hover:bg-[#FAFAFA] transition-colors cursor-pointer">
              <div 
                className="w-10 h-10 rounded-md flex items-center justify-center flex-shrink-0"
                style={{ backgroundColor: reminder.bgColor }}
              >
                <reminder.icon className="w-5 h-5" style={{ color: reminder.color }} strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{reminder.title}</p>
                <p className="text-caption text-[#9E9E9E]">{reminder.time}</p>
              </div>
              <ChevronRight className="w-5 h-5 text-[#9E9E9E] flex-shrink-0" strokeWidth={1.5} />
            </div>
          ))}
        </Card>
      </div>

      {/* Completed Reminders */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>已完成</h3>
        <Card className="divide-y divide-[#F5F5F5] bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          {completedReminders.map((reminder) => (
            <div key={reminder.id} className="p-4 flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#EDF7ED] flex items-center justify-center flex-shrink-0">
                <Check className="w-5 h-5 text-[#66BB6A]" strokeWidth={1.5} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-body text-[#9E9E9E] line-through">{reminder.title}</p>
                <p className="text-caption text-[#BDBDBD]">{reminder.time}</p>
              </div>
            </div>
          ))}
        </Card>
      </div>

      {/* Add Reminder Button */}
      <Button
        className="w-full h-12 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
        style={{ boxShadow: '0 2px 6px rgba(255, 216, 77, 0.3)' }}
      >
        <Plus className="w-5 h-5 mr-2" strokeWidth={1.5} />
        添加提醒
      </Button>

      {/* Tips Card */}
      <Card className="p-4 bg-[#E3F2FD] border border-[#42A5F5]/20" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-[#42A5F5] flex items-center justify-center flex-shrink-0">
            <Bell className="w-4 h-4 text-white" strokeWidth={1.5} />
          </div>
          <div>
            <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>
              主人，设置提醒让我更健康
            </p>
            <p className="text-caption text-[#546E7A]">
              定期提醒可以帮助你更好地照顾我，让我们一起建立健康的生活习惯吧
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
}
