import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Avatar, AvatarFallback, AvatarImage } from '../ui/avatar';
import { Badge } from '../ui/badge';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { 
  User, 
  Bell, 
  Shield, 
  Palette, 
  HelpCircle, 
  MessageSquare,
  LogOut,
  ChevronRight,
  Smartphone,
  Globe,
  Moon,
  Camera,
  Database
} from 'lucide-react';

interface SettingsTemplateProps {
  onNavigate: (page: any) => void;
}

export function SettingsTemplate({ onNavigate }: SettingsTemplateProps) {
  const currentPet = {
    id: 1,
    name: "小白",
    breed: "田园猫",
    age: "2岁3个月",
    avatar: "https://images.unsplash.com/photo-1684707458757-1d33524680d1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3aGl0ZSUyMGNhdCUyMHBvcnRyYWl0fGVufDF8fHx8MTc2MDA5NjkyM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  };

  return (
    <div className="pb-6">
      <div className="space-y-6 pt-5">
        {/* User Profile Card */}
        <Card className="p-6 border border-gray-200 shadow-sm bg-white">
          <div className="flex items-center gap-4">
            <Avatar className="w-16 h-16">
              <AvatarImage src="" />
              <AvatarFallback className="bg-[#FFF8E1] text-[#37474F]">ME</AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <h3 className="text-body text-[#37474F]">我的账户</h3>
              <p className="text-caption text-[#78909C]">user@example.com</p>
            </div>
            <ChevronRight className="w-5 h-5 text-[#CFD8DC]" strokeWidth={1.5} />
          </div>
        </Card>

        {/* Current Pet Section */}
        <div className="space-y-3">
          <div className="flex items-center justify-between px-2">
            <p className="text-caption text-[#78909C]">当前宠物</p>
            <Button
              onClick={() => onNavigate('pet-registration')}
              variant="ghost"
              className="h-7 px-3 rounded-md text-caption text-[#2F5233] hover:bg-[#EDF7ED]"
            >
              + 添加宠物
            </Button>
          </div>
          
          <Card 
            className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30" 
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            <div className="flex items-center gap-3">
              {/* Pet Avatar */}
              <div className="w-14 h-14 rounded-full overflow-hidden bg-white flex-shrink-0">
                <ImageWithFallback
                  src={currentPet.avatar}
                  alt={currentPet.name}
                  className="w-full h-full object-cover"
                />
              </div>

              {/* Pet Info */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{currentPet.name}</h3>
                  <Badge className="px-2 py-0.5 rounded bg-[#EDF7ED] text-[#2E7D32] text-[11px] border-none">
                    当前
                  </Badge>
                </div>
                <p className="text-caption text-[#9E9E9E]">{currentPet.breed} · {currentPet.age}</p>
              </div>

              {/* Switch Text */}
              <button 
                className="text-caption text-[#9E9E9E] hover:text-[#424242] transition-colors flex-shrink-0"
              >
                切换
              </button>
            </div>
          </Card>
        </div>

        {/* Preferences Section */}
        <div className="space-y-3">
          <p className="text-caption text-[#78909C] px-2">偏好设置</p>
          
          <Card className="divide-y divide-gray-200 border border-gray-200 shadow-sm bg-white overflow-hidden">
            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#E8F5E9] flex items-center justify-center">
                  <Bell className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">通知提醒</p>
                  <p className="text-caption text-gray-400">接收提醒和消息</p>
                </div>
              </div>
              <Switch defaultChecked />
            </div>

            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <Moon className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">深色模式</p>
                  <p className="text-caption text-gray-400">切换外观</p>
                </div>
              </div>
              <Switch />
            </div>

            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <Globe className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">语言</p>
                  <p className="text-caption text-gray-400">简体中文</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </div>
          </Card>
        </div>

        {/* System Section */}
        <div className="space-y-3">
          <p className="text-caption text-gray-400 px-2">系统</p>
          
          <Card className="divide-y divide-gray-100 border border-gray-100 shadow-none overflow-hidden">
            <button 
              onClick={() => onNavigate('data-backup')}
              className="w-full p-5 flex items-center justify-between hover:bg-[#E8F5E9] transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#E8F5E9] flex items-center justify-center">
                  <Database className="w-5 h-5 text-[#2F5233]" strokeWidth={1.5} />
                </div>
                <div className="text-left">
                  <p className="text-body text-gray-900">数据备份</p>
                  <p className="text-caption text-gray-500">导出和恢复数据</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </button>

            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <Shield className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">隐私与安全</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </div>

            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <Smartphone className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">设备管理</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </div>
          </Card>
        </div>

        {/* Help Section */}
        <div className="space-y-3">
          <p className="text-caption text-gray-400 px-2">帮助与支持</p>
          
          <Card className="divide-y divide-gray-100 border border-gray-100 shadow-none overflow-hidden">
            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <HelpCircle className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">帮助中心</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </div>

            <div className="p-5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-[#FFFBEA] flex items-center justify-center">
                  <MessageSquare className="w-5 h-5 text-gray-700" strokeWidth={1.5} />
                </div>
                <div>
                  <p className="text-body text-gray-900">联系我们</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" strokeWidth={1.5} />
            </div>
          </Card>
        </div>

        {/* Logout Button */}
        <Button 
          variant="outline" 
          className="w-full rounded-full border-2 border-gray-200 hover:border-red-300 hover:bg-red-50 text-red-600 h-14"
        >
          <LogOut className="w-5 h-5 mr-2" strokeWidth={1.5} />
          退出登录
        </Button>

        {/* App Version */}
        <div className="text-center pt-4">
          <p className="text-caption text-gray-400">宠物管家 v1.0.0</p>
          <p className="text-caption text-gray-300 mt-1">Nothing OS Design System</p>
        </div>
      </div>
    </div>
  );
}