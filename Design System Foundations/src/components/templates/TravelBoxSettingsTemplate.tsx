import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { 
  Wifi, 
  Battery, 
  Thermometer, 
  Bell, 
  Lock, 
  Volume2, 
  Sun, 
  Moon,
  Bluetooth,
  RefreshCw,
  Info,
  Settings2,
  ChevronRight,
  Fan
} from 'lucide-react';

interface TravelBoxSettingsTemplateProps {
  onNavigate: (page: any) => void;
}

export function TravelBoxSettingsTemplate({ onNavigate }: TravelBoxSettingsTemplateProps) {
  const [settings, setSettings] = useState({
    autoLock: true,
    tempAlert: true,
    batteryAlert: true,
    soundEnabled: true,
    nightMode: false,
    autoSync: true,
    vibration: true
  });

  const deviceInfo = {
    name: "出行箱 Pro",
    model: "TB-2024",
    serialNumber: "SN20240915001",
    firmwareVersion: "v2.1.3",
    battery: 85,
    connected: true,
    lastSync: "2分钟前"
  };

  const toggleSetting = (key: keyof typeof settings) => {
    setSettings(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  const settingsList = [
    {
      icon: Wifi,
      title: 'WiFi',
      subtitle: '已连接到 "Home Network"',
      page: 'travel-box-wifi' as const,
      color: '#42A5F5',
      bgColor: '#E3F2FD'
    },
    {
      icon: Bluetooth,
      title: '蓝牙',
      subtitle: '已连接 2 个设备',
      page: 'travel-box-bluetooth' as const,
      color: '#42A5F5',
      bgColor: '#E3F2FD'
    },
    {
      icon: Thermometer,
      title: '温度控制',
      subtitle: '18-26°C · 自动调节',
      page: 'travel-box-temperature' as const,
      color: '#FFA726',
      bgColor: '#FFF3E0'
    },
    {
      icon: Volume2,
      title: '声音控制',
      subtitle: '音量 70%',
      page: 'travel-box-sound' as const,
      color: '#66BB6A',
      bgColor: '#E8F5E9'
    },
    {
      icon: Fan,
      title: '风扇控制',
      subtitle: '自动模式',
      page: 'travel-box-fan' as const,
      color: '#AB47BC',
      bgColor: '#F3E5F5'
    }
  ];

  return (
    <div className="pb-6 pt-5 space-y-5">
      {/* Device Status Card */}
      <Card className="p-4 bg-[#FFFBEA] border border-[#FFD84D]/30 relative overflow-hidden" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="absolute inset-0 dot-grid-bg text-[#FFD84D]" />
        <div className="relative">
          <div className="flex items-start justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-md bg-white flex items-center justify-center">
                <Settings2 className="w-6 h-6 text-[#424242]" strokeWidth={1.5} />
              </div>
              <div>
                <h2 className="text-title text-[#424242]">{deviceInfo.name}</h2>
                <p className="text-caption text-[#9E9E9E]">{deviceInfo.model}</p>
              </div>
            </div>
            <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-white">
              <div className={`w-2 h-2 rounded-full ${deviceInfo.connected ? 'bg-[#66BB6A]' : 'bg-[#E0E0E0]'}`} />
              <span className="text-caption text-[#424242]">
                {deviceInfo.connected ? '在线' : '离线'}
              </span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div className="p-3 rounded-md bg-white">
              <p className="text-caption text-[#9E9E9E] mb-1">序列号</p>
              <p className="text-mono text-[#424242]" style={{ fontSize: '11px' }}>{deviceInfo.serialNumber}</p>
            </div>
            <div className="p-3 rounded-md bg-white">
              <p className="text-caption text-[#9E9E9E] mb-1">固件版本</p>
              <p className="text-mono text-[#424242]" style={{ fontSize: '11px' }}>{deviceInfo.firmwareVersion}</p>
            </div>
            <div className="p-3 rounded-md bg-white">
              <p className="text-caption text-[#9E9E9E] mb-1">电量</p>
              <div className="flex items-center gap-2">
                <Battery className="w-4 h-4 text-[#66BB6A]" strokeWidth={1.5} />
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{deviceInfo.battery}%</p>
              </div>
            </div>
            <div className="p-3 rounded-md bg-white">
              <p className="text-caption text-[#9E9E9E] mb-1">最后同步</p>
              <p className="text-caption text-[#424242]">{deviceInfo.lastSync}</p>
            </div>
          </div>
        </div>
      </Card>

      {/* Quick Settings */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>快速设置</h3>
        <Card className="divide-y divide-[#F5F5F5] bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          {settingsList.map((setting, index) => (
            <button
              key={index}
              onClick={() => onNavigate(setting.page)}
              className="w-full p-4 flex items-center justify-between hover:bg-[#FAFAFA] transition-colors"
            >
              <div className="flex items-center gap-3">
                <div 
                  className="w-10 h-10 rounded-md flex items-center justify-center"
                  style={{ backgroundColor: setting.bgColor }}
                >
                  <setting.icon className="w-5 h-5" style={{ color: setting.color }} strokeWidth={1.5} />
                </div>
                <div className="text-left">
                  <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>{setting.title}</p>
                  <p className="text-caption text-[#9E9E9E]">{setting.subtitle}</p>
                </div>
              </div>
              <ChevronRight className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
            </button>
          ))}
        </Card>
      </div>

      {/* Alerts & Notifications */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>提醒与通知</h3>
        <Card className="divide-y divide-[#F5F5F5] bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#FFF3E0] flex items-center justify-center">
                <Thermometer className="w-5 h-5 text-[#FFA726]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>温度警报</p>
                <p className="text-caption text-[#9E9E9E]">温度异常时通知</p>
              </div>
            </div>
            <Switch 
              checked={settings.tempAlert}
              onCheckedChange={() => toggleSetting('tempAlert')}
            />
          </div>

          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#E8F5E9] flex items-center justify-center">
                <Battery className="w-5 h-5 text-[#66BB6A]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>电量提醒</p>
                <p className="text-caption text-[#9E9E9E]">电量低于20%时通知</p>
              </div>
            </div>
            <Switch 
              checked={settings.batteryAlert}
              onCheckedChange={() => toggleSetting('batteryAlert')}
            />
          </div>

          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#F3E5F5] flex items-center justify-center">
                <Lock className="w-5 h-5 text-[#AB47BC]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>自动锁定</p>
                <p className="text-caption text-[#9E9E9E]">5分钟无操作后锁定</p>
              </div>
            </div>
            <Switch 
              checked={settings.autoLock}
              onCheckedChange={() => toggleSetting('autoLock')}
            />
          </div>

          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-md bg-[#E3F2FD] flex items-center justify-center">
                <RefreshCw className="w-5 h-5 text-[#42A5F5]" strokeWidth={1.5} />
              </div>
              <div>
                <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>自动同步</p>
                <p className="text-caption text-[#9E9E9E]">实时同步设备数据</p>
              </div>
            </div>
            <Switch 
              checked={settings.autoSync}
              onCheckedChange={() => toggleSetting('autoSync')}
            />
          </div>
        </Card>
      </div>

      {/* Device Actions */}
      <div>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>设备操作</h3>
        <div className="space-y-2">
          <Button
            className="w-full h-12 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242] border border-[#E0E0E0] justify-between"
          >
            <div className="flex items-center gap-2">
              <RefreshCw className="w-5 h-5" strokeWidth={1.5} />
              <span>检查固件更新</span>
            </div>
            <ChevronRight className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
          </Button>

          <Button
            className="w-full h-12 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242] border border-[#E0E0E0] justify-between"
          >
            <div className="flex items-center gap-2">
              <Info className="w-5 h-5" strokeWidth={1.5} />
              <span>设备信息</span>
            </div>
            <ChevronRight className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
          </Button>

          <Button
            variant="outline"
            className="w-full h-12 rounded-md border-[#EF5350] text-[#EF5350] hover:bg-[#FFEBEE]"
          >
            重置设备
          </Button>
        </div>
      </div>

      {/* Help Card */}
      <Card className="p-4 bg-[#E3F2FD] border border-[#42A5F5]/20" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-[#42A5F5] flex items-center justify-center flex-shrink-0">
            <Info className="w-4 h-4 text-white" strokeWidth={1.5} />
          </div>
          <div>
            <p className="text-caption text-[#424242] mb-1" style={{ fontWeight: 600 }}>
              遇到问题？
            </p>
            <p className="text-caption text-[#546E7A]">
              查看使用手册或联系客服获取帮助
            </p>
            <Button
              variant="link"
              className="h-auto p-0 mt-2 text-caption text-[#42A5F5]"
              style={{ fontWeight: 600 }}
            >
              查看帮助文档
            </Button>
          </div>
        </div>
      </Card>
    </div>
  );
}
