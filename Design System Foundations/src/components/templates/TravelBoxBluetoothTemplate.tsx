import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Switch } from '../ui/switch';
import { 
  Smartphone,
  Laptop,
  Watch,
  Tablet,
  RefreshCw
} from 'lucide-react';

interface TravelBoxBluetoothTemplateProps {
  onNavigate: (page: string) => void;
}

export function TravelBoxBluetoothTemplate({ onNavigate }: TravelBoxBluetoothTemplateProps) {
  const [bluetoothEnabled, setBluetoothEnabled] = useState(true);

  const devices = [
    { name: 'iPhone 14 Pro', type: 'phone', connected: true, battery: 85, icon: Smartphone },
    { name: 'MacBook Pro', type: 'laptop', connected: false, battery: null, icon: Laptop },
    { name: 'Apple Watch', type: 'watch', connected: false, battery: null, icon: Watch },
    { name: 'iPad Air', type: 'tablet', connected: false, battery: null, icon: Tablet }
  ];

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Bluetooth Toggle */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-[#E3F2FD] flex items-center justify-center">
              <Smartphone className="w-6 h-6 text-[#42A5F5]" strokeWidth={1.5} />
            </div>
            <div>
              <h3 className="text-body text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>蓝牙</h3>
              <p className="text-caption text-[#9E9E9E]">
                {bluetoothEnabled ? '已开启' : '已关闭'}
              </p>
            </div>
          </div>
          <Switch 
            checked={bluetoothEnabled}
            onCheckedChange={setBluetoothEnabled}
          />
        </div>
      </Card>

      {bluetoothEnabled && (
        <>
          {/* Connected Device */}
          <div>
            <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>已连接设备</h3>
            {devices.filter(d => d.connected).map((device, index) => (
              <Card
                key={index}
                className="p-4 bg-[#FFFBEA] border-[#FFD84D]"
                style={{ 
                  boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)',
                  borderWidth: '1px'
                }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-md bg-[#FFD84D] flex items-center justify-center">
                    <device.icon className="w-5 h-5 text-[#424242]" strokeWidth={1.5} />
                  </div>
                  <div className="flex-1">
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>
                      {device.name}
                    </p>
                    <p className="text-caption text-[#9E9E9E]">
                      {device.battery ? `电量 ${device.battery}%` : '已配对'}
                    </p>
                  </div>
                  <Badge className="px-2 py-1 rounded-md bg-[#EDF7ED] text-[#2E7D32] border-none">
                    已连接
                  </Badge>
                </div>

                <div className="mt-3 pt-3 border-t border-[#FFD84D]/20 flex gap-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="flex-1 h-9 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242]"
                  >
                    断开连接
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="flex-1 h-9 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242]"
                  >
                    取消配对
                  </Button>
                </div>
              </Card>
            ))}
          </div>

          {/* Available Devices */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>可用设备</h3>
              <Button
                variant="ghost"
                size="sm"
                className="h-8 px-3 rounded-md hover:bg-[#F5F5F5]"
              >
                <RefreshCw className="w-4 h-4 mr-1 text-[#9E9E9E]" strokeWidth={1.5} />
                <span className="text-caption text-[#9E9E9E]">搜索</span>
              </Button>
            </div>

            <div className="space-y-2">
              {devices.filter(d => !d.connected).map((device, index) => (
                <Card
                  key={index}
                  className="p-4 bg-white cursor-pointer transition-all hover:bg-[#F5F5F5]"
                  style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
                      <device.icon className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                    </div>
                    <div className="flex-1">
                      <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>
                        {device.name}
                      </p>
                      <p className="text-caption text-[#9E9E9E]">未配对</p>
                    </div>
                    <Button
                      size="sm"
                      className="h-8 px-3 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
                    >
                      配对
                    </Button>
                  </div>
                </Card>
              ))}
            </div>
          </div>

          {/* Settings */}
          <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
            <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>蓝牙设置</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between py-2">
                <div>
                  <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>自动连接</p>
                  <p className="text-caption text-[#9E9E9E]">自动连接已配对设备</p>
                </div>
                <Switch defaultChecked />
              </div>

              <div className="h-px bg-[#F5F5F5]" />

              <div className="flex items-center justify-between py-2">
                <div>
                  <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>设备可见性</p>
                  <p className="text-caption text-[#9E9E9E]">允许其他设备发现</p>
                </div>
                <Switch defaultChecked />
              </div>
            </div>
          </Card>
        </>
      )}

      {/* Tips */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-caption text-[#424242] mb-2" style={{ fontWeight: 600 }}>使用提示</h3>
        <ul className="space-y-1.5">
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>保持设备蓝牙开启以便接收实时通知</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>首次配对需要在设备上确认配对请求</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>蓝牙连接范围约10米</span>
          </li>
        </ul>
      </Card>
    </div>
  );
}
