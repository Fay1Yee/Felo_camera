import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Input } from '../ui/input';
import { 
  Wifi, 
  Lock,
  Eye,
  EyeOff,
  RefreshCw,
  Signal
} from 'lucide-react';

interface TravelBoxWiFiTemplateProps {
  onNavigate: (page: string) => void;
}

export function TravelBoxWiFiTemplate({ onNavigate }: TravelBoxWiFiTemplateProps) {
  const [showPassword, setShowPassword] = useState(false);
  const [selectedNetwork, setSelectedNetwork] = useState('PetHome_5G');

  const networks = [
    { name: 'PetHome_5G', signal: 'strong', secured: true, connected: true },
    { name: 'Home_WiFi', signal: 'medium', secured: true, connected: false },
    { name: 'Guest_Network', signal: 'weak', secured: false, connected: false },
    { name: 'Office_5G', signal: 'medium', secured: true, connected: false }
  ];

  const getSignalIcon = (signal: string) => {
    if (signal === 'strong') return 3;
    if (signal === 'medium') return 2;
    return 1;
  };

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Current Connection */}
      <Card className="p-4 bg-[#FFFBEA]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-center gap-3 mb-3">
          <div className="w-12 h-12 rounded-full bg-[#FFD84D] flex items-center justify-center">
            <Wifi className="w-6 h-6 text-[#424242]" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <p className="text-caption text-[#9E9E9E] mb-0.5">当前连接</p>
            <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>PetHome_5G</h3>
          </div>
          <Badge className="px-2 py-1 rounded-md bg-[#EDF7ED] text-[#2E7D32] border-none">
            已连接
          </Badge>
        </div>
        
        <div className="grid grid-cols-3 gap-2">
          <div className="text-center p-2 rounded-md bg-white">
            <p className="text-caption text-[#9E9E9E] mb-0.5">信号强度</p>
            <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>强</p>
          </div>
          <div className="text-center p-2 rounded-md bg-white">
            <p className="text-caption text-[#9E9E9E] mb-0.5">频段</p>
            <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>5GHz</p>
          </div>
          <div className="text-center p-2 rounded-md bg-white">
            <p className="text-caption text-[#9E9E9E] mb-0.5">速度</p>
            <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>快</p>
          </div>
        </div>
      </Card>

      {/* Available Networks */}
      <div>
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-body text-[#424242]" style={{ fontWeight: 600 }}>可用网络</h3>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 px-3 rounded-md hover:bg-[#F5F5F5]"
          >
            <RefreshCw className="w-4 h-4 mr-1 text-[#9E9E9E]" strokeWidth={1.5} />
            <span className="text-caption text-[#9E9E9E]">刷新</span>
          </Button>
        </div>

        <div className="space-y-2">
          {networks.map((network, index) => (
            <Card
              key={index}
              className={`p-4 cursor-pointer transition-all ${
                network.connected 
                  ? 'bg-[#FFFBEA] border-[#FFD84D]' 
                  : 'bg-white hover:bg-[#F5F5F5]'
              }`}
              style={{ 
                boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)',
                borderWidth: network.connected ? '1px' : '0'
              }}
              onClick={() => setSelectedNetwork(network.name)}
            >
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-1">
                  {[...Array(getSignalIcon(network.signal))].map((_, i) => (
                    <div
                      key={i}
                      className="w-1 bg-[#424242]"
                      style={{ height: `${(i + 1) * 4}px` }}
                    />
                  ))}
                </div>
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>
                      {network.name}
                    </p>
                    {network.secured && (
                      <Lock className="w-3 h-3 text-[#9E9E9E]" strokeWidth={1.5} />
                    )}
                  </div>
                  <p className="text-caption text-[#9E9E9E]">
                    {network.signal === 'strong' ? '信号强' : network.signal === 'medium' ? '信号中' : '信号弱'}
                  </p>
                </div>

                {network.connected && (
                  <Badge className="px-2 py-0.5 rounded bg-[#EDF7ED] text-[#2E7D32] text-[11px] border-none">
                    已连接
                  </Badge>
                )}
              </div>
            </Card>
          ))}
        </div>
      </div>

      {/* Connection Form */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>连接设置</h3>
        
        <div className="space-y-3">
          <div>
            <label className="text-caption text-[#9E9E9E] mb-1 block">网络名称</label>
            <Input
              value={selectedNetwork}
              onChange={(e) => setSelectedNetwork(e.target.value)}
              className="h-11 rounded-md bg-[#F5F5F5] border-none"
              placeholder="输入网络名称"
            />
          </div>

          <div>
            <label className="text-caption text-[#9E9E9E] mb-1 block">密码</label>
            <div className="relative">
              <Input
                type={showPassword ? 'text' : 'password'}
                className="h-11 rounded-md bg-[#F5F5F5] border-none pr-10"
                placeholder="输入WiFi密码"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2"
              >
                {showPassword ? (
                  <EyeOff className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                ) : (
                  <Eye className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                )}
              </button>
            </div>
          </div>

          <Button
            className="w-full h-11 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
            style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
          >
            连接网络
          </Button>
        </div>
      </Card>

      {/* Tips */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-caption text-[#424242] mb-2" style={{ fontWeight: 600 }}>连接提示</h3>
        <ul className="space-y-1.5">
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>建议连接5GHz频段获得更快的速度</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>确保路由器在设备附近以获得最佳信号</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>首次连接需要输入正确的WiFi密码</span>
          </li>
        </ul>
      </Card>
    </div>
  );
}
