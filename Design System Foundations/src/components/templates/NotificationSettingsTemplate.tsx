import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { 
  Bell, 
  Mail, 
  Smartphone, 
  Volume2, 
  Moon,
  Clock,
  Heart,
  Calendar,
  Siren,
  MessageSquare,
  Shield,
  Info,
  ChevronRight
} from 'lucide-react';

interface NotificationSettingsTemplateProps {
  onNavigate: (page: any) => void;
}

export function NotificationSettingsTemplate({ onNavigate }: NotificationSettingsTemplateProps) {
  const [notificationChannels, setNotificationChannels] = useState({
    push: true,
    email: true,
    sms: false
  });

  const [notificationTypes, setNotificationTypes] = useState({
    health: true,
    schedule: true,
    device: true,
    emergency: true,
    social: false,
    marketing: false
  });

  const [preferences, setPreferences] = useState({
    sound: true,
    vibration: true,
    doNotDisturb: false,
    groupNotifications: true,
    showPreview: true
  });

  const toggleChannel = (key: keyof typeof notificationChannels) => {
    setNotificationChannels(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const toggleType = (key: keyof typeof notificationTypes) => {
    setNotificationTypes(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const togglePreference = (key: keyof typeof preferences) => {
    setPreferences(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  return (
    <div className="space-y-6 pb-8">
      {/* Header */}
      <div className="pt-6">
        <Card className="p-6 border border-gray-100 shadow-none bg-[#FFFBEA] relative overflow-hidden">
          <div className="absolute inset-0 dot-grid-bg text-gray-900" />
          <div className="relative">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center">
                <Bell className="w-6 h-6 text-gray-900" strokeWidth={1.5} />
              </div>
              <div>
                <h2 className="text-title">通知设置</h2>
              </div>
            </div>
            <p className="text-body text-gray-700">
              管理您收到的通知类型和方式
            </p>
          </div>
        </Card>
      </div>

      {/* Notification Channels */}
      <div>
        <h3 className="text-body mb-4">通知渠道</h3>
        <Card className="p-5 border border-gray-100 shadow-none">
          <div className="space-y-5">
            {/* Push Notifications */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Smartphone className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">推送通知</p>
                  <p className="text-caption text-gray-400">应用内消息推送</p>
                </div>
              </div>
              <Switch 
                checked={notificationChannels.push}
                onCheckedChange={() => toggleChannel('push')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Email */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Mail className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">邮件通知</p>
                  <p className="text-caption text-gray-400">发送到 user@example.com</p>
                </div>
              </div>
              <Switch 
                checked={notificationChannels.email}
                onCheckedChange={() => toggleChannel('email')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* SMS */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <MessageSquare className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">短信通知</p>
                  <p className="text-caption text-gray-400">紧急事项短信提醒</p>
                </div>
              </div>
              <Switch 
                checked={notificationChannels.sms}
                onCheckedChange={() => toggleChannel('sms')}
              />
            </div>
          </div>
        </Card>
      </div>

      {/* Notification Types */}
      <div>
        <h3 className="text-body mb-4">通知类型</h3>
        <Card className="p-5 border border-gray-100 shadow-none">
          <div className="space-y-5">
            {/* Health */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Heart className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">健康提醒</p>
                  <p className="text-caption text-gray-400">疫苗、体检等健康事项</p>
                </div>
              </div>
              <Switch 
                checked={notificationTypes.health}
                onCheckedChange={() => toggleType('health')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Schedule */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Calendar className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">日程提醒</p>
                  <p className="text-caption text-gray-400">喂食、遛狗等日常事项</p>
                </div>
              </div>
              <Switch 
                checked={notificationTypes.schedule}
                onCheckedChange={() => toggleType('schedule')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Device */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Shield className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">设备警报</p>
                  <p className="text-caption text-gray-400">出行箱温度、电量等警报</p>
                </div>
              </div>
              <Switch 
                checked={notificationTypes.device}
                onCheckedChange={() => toggleType('device')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Emergency */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                    <Siren className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                  </div>
                  <div>
                    <p className="text-body mb-0.5">紧急通知</p>
                    <p className="text-caption text-gray-400">重要安全警报，无法关闭</p>
                  </div>
                </div>
                <Switch 
                  checked={notificationTypes.emergency}
                  disabled
                />
              </div>
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Social */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <MessageSquare className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">社区动态</p>
                  <p className="text-caption text-gray-400">宠物社区互动消息</p>
                </div>
              </div>
              <Switch 
                checked={notificationTypes.social}
                onCheckedChange={() => toggleType('social')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Marketing */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Bell className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">活动推广</p>
                  <p className="text-caption text-gray-400">优惠活动和产品推荐</p>
                </div>
              </div>
              <Switch 
                checked={notificationTypes.marketing}
                onCheckedChange={() => toggleType('marketing')}
              />
            </div>
          </div>
        </Card>
      </div>

      {/* Preferences */}
      <div>
        <h3 className="text-body mb-4">提醒方式</h3>
        <Card className="p-5 border border-gray-100 shadow-none">
          <div className="space-y-5">
            {/* Sound */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Volume2 className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">提示音</p>
                  <p className="text-caption text-gray-400">播放通知提示音</p>
                </div>
              </div>
              <Switch 
                checked={preferences.sound}
                onCheckedChange={() => togglePreference('sound')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Vibration */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Smartphone className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">振动</p>
                  <p className="text-caption text-gray-400">收到通知时振动</p>
                </div>
              </div>
              <Switch 
                checked={preferences.vibration}
                onCheckedChange={() => togglePreference('vibration')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Show Preview */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <MessageSquare className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">显示预览</p>
                  <p className="text-caption text-gray-400">锁屏时显示通知内容</p>
                </div>
              </div>
              <Switch 
                checked={preferences.showPreview}
                onCheckedChange={() => togglePreference('showPreview')}
              />
            </div>

            <div className="dot-divider text-gray-300" />

            {/* Group Notifications */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Bell className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">合并通知</p>
                  <p className="text-caption text-gray-400">相同类型通知合并显示</p>
                </div>
              </div>
              <Switch 
                checked={preferences.groupNotifications}
                onCheckedChange={() => togglePreference('groupNotifications')}
              />
            </div>
          </div>
        </Card>
      </div>

      {/* Do Not Disturb */}
      <div>
        <h3 className="text-body mb-4">免打扰</h3>
        <Card className="p-5 border border-gray-100 shadow-none">
          <div className="space-y-5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#F5F5F0] flex items-center justify-center">
                  <Moon className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body mb-0.5">免打扰模式</p>
                  <p className="text-caption text-gray-400">静音所有非紧急通知</p>
                </div>
              </div>
              <Switch 
                checked={preferences.doNotDisturb}
                onCheckedChange={() => togglePreference('doNotDisturb')}
              />
            </div>

            {preferences.doNotDisturb && (
              <>
                <div className="dot-divider text-gray-300" />
                <div 
                  className="flex items-center justify-between p-4 bg-[#F5F5F0] rounded-2xl cursor-pointer hover:bg-[#FFFBEA] transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <Clock className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                    <div>
                      <p className="text-body mb-0.5">定时设置</p>
                      <p className="text-caption text-gray-400">22:00 - 08:00</p>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
                </div>
              </>
            )}
          </div>
        </Card>
      </div>

      {/* Info Card */}
      <Card className="p-5 border border-gray-100 shadow-none bg-[#FFFBEA]">
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center flex-shrink-0">
            <Info className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <h4 className="text-body mb-1">通知提示</h4>
            <p className="text-caption text-gray-500">
              紧急通知（如设备警报、健康异常）将始终发送，无法关闭。建议保持推送通知开启以便及时了解宠物状况。
            </p>
          </div>
        </div>
      </Card>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Button
          variant="outline"
          className="h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
        >
          清空通知
        </Button>
        <Button
          variant="outline"
          className="h-12 rounded-full border-2 border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
        >
          测试通知
        </Button>
      </div>

      {/* Save Button */}
      <Button 
        className="w-full h-12 rounded-full bg-[#FFD84D] hover:bg-[#FFC107] text-gray-900 border-none"
      >
        保存设置
      </Button>
    </div>
  );
}