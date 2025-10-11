import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Slider } from '../ui/slider';
import { 
  Wind,
  Zap,
  Timer,
  RotateCw
} from 'lucide-react';

interface TravelBoxFanTemplateProps {
  onNavigate: (page: string) => void;
}

export function TravelBoxFanTemplate({ onNavigate }: TravelBoxFanTemplateProps) {
  const [fanEnabled, setFanEnabled] = useState(true);
  const [fanSpeed, setFanSpeed] = useState([60]);
  const [autoMode, setAutoMode] = useState(true);
  const [timerEnabled, setTimerEnabled] = useState(false);

  const getSpeedLevel = () => {
    if (fanSpeed[0] < 33) return '低速';
    if (fanSpeed[0] < 66) return '中速';
    return '高速';
  };

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Fan Control */}
      <Card className="p-5 bg-[#E3F2FD]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="text-center mb-4">
          <div className="w-20 h-20 rounded-full bg-[#42A5F5]/20 flex items-center justify-center mx-auto mb-4">
            <Wind 
              className={`w-10 h-10 text-[#42A5F5] ${fanEnabled ? 'animate-spin' : ''}`} 
              strokeWidth={1.5}
              style={{ animationDuration: `${3 - (fanSpeed[0] / 50)}s` }}
            />
          </div>
          <h2 className="text-[40px] text-[#424242] mb-1" style={{ fontWeight: 700 }}>
            {fanSpeed[0]}%
          </h2>
          <p className="text-caption text-[#9E9E9E] mb-2">风扇速度</p>
          <div className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-white">
            <span className="text-caption text-[#424242]" style={{ fontWeight: 600 }}>{getSpeedLevel()}</span>
          </div>
        </div>

        <div className="p-4 rounded-md bg-white">
          <Slider
            value={fanSpeed}
            onValueChange={setFanSpeed}
            min={0}
            max={100}
            step={10}
            disabled={!fanEnabled}
            className="w-full mb-3"
          />
          <div className="flex items-center justify-between text-caption text-[#9E9E9E]">
            <span>低速</span>
            <span>中速</span>
            <span>高速</span>
          </div>
        </div>
      </Card>

      {/* Fan Settings */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>风扇设置</h3>
        
        <div className="space-y-0">
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3">
              <Wind className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
              <div>
                <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>启用风扇</p>
                <p className="text-caption text-[#9E9E9E]">开启空气循环系统</p>
              </div>
            </div>
            <Switch 
              checked={fanEnabled}
              onCheckedChange={setFanEnabled}
            />
          </div>

          {fanEnabled && (
            <>
              <div className="h-px bg-[#F5F5F5]" />

              <div className="flex items-center justify-between py-3">
                <div className="flex items-center gap-3">
                  <Zap className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                  <div>
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>自动模式</p>
                    <p className="text-caption text-[#9E9E9E]">根据温度自动调节</p>
                  </div>
                </div>
                <Switch 
                  checked={autoMode}
                  onCheckedChange={setAutoMode}
                />
              </div>

              <div className="h-px bg-[#F5F5F5]" />

              <div className="flex items-center justify-between py-3">
                <div className="flex items-center gap-3">
                  <Timer className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                  <div>
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>定时关闭</p>
                    <p className="text-caption text-[#9E9E9E]">设置自动关闭时间</p>
                  </div>
                </div>
                <Switch 
                  checked={timerEnabled}
                  onCheckedChange={setTimerEnabled}
                />
              </div>
            </>
          )}
        </div>
      </Card>

      {/* Timer Settings */}
      {fanEnabled && timerEnabled && (
        <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>定时设置</h3>
          <div className="grid grid-cols-3 gap-2">
            {[
              { label: '30分钟', value: 30 },
              { label: '1小时', value: 60 },
              { label: '2小时', value: 120 },
              { label: '3小时', value: 180 },
              { label: '6小时', value: 360 },
              { label: '12小时', value: 720 }
            ].map((timer, index) => (
              <Button
                key={index}
                variant="ghost"
                className="h-11 rounded-md bg-[#F5F5F5] hover:bg-[#EEEEEE] text-[#424242]"
              >
                {timer.label}
              </Button>
            ))}
          </div>
        </Card>
      )}

      {/* Speed Presets */}
      {fanEnabled && (
        <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>速度档位</h3>
          <div className="grid grid-cols-3 gap-2">
            {[
              { label: '低速', value: 30, icon: '🌬️' },
              { label: '中速', value: 60, icon: '💨' },
              { label: '高速', value: 90, icon: '🌪️' }
            ].map((preset, index) => (
              <button
                key={index}
                onClick={() => setFanSpeed([preset.value])}
                className={`p-3 rounded-md transition-all ${
                  Math.abs(fanSpeed[0] - preset.value) < 15
                    ? 'bg-[#E3F2FD] border border-[#42A5F5]' 
                    : 'bg-[#F5F5F5] hover:bg-[#EEEEEE]'
                }`}
              >
                <div className="text-[24px] mb-1">{preset.icon}</div>
                <p className="text-caption text-[#424242]">{preset.label}</p>
              </button>
            ))}
          </div>
        </Card>
      )}

      {/* Fan Status */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>运行状态</h3>
        <div className="space-y-2">
          <div className="flex items-center justify-between py-1">
            <span className="text-caption text-[#9E9E9E]">运行时间</span>
            <span className="text-caption text-[#424242]">2小时15分</span>
          </div>
          <div className="h-px bg-[#E0E0E0]" />
          
          <div className="flex items-center justify-between py-1">
            <span className="text-caption text-[#9E9E9E]">耗电量</span>
            <span className="text-caption text-[#424242]">0.5 Wh</span>
          </div>
          <div className="h-px bg-[#E0E0E0]" />
          
          <div className="flex items-center justify-between py-1">
            <span className="text-caption text-[#9E9E9E]">转速</span>
            <span className="text-caption text-[#424242]">1200 RPM</span>
          </div>
        </div>
      </Card>

      {/* Maintenance */}
      <Card className="p-4 bg-[#FFFBEA]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-md bg-[#FFD84D] flex items-center justify-center flex-shrink-0">
            <RotateCw className="w-5 h-5 text-[#424242]" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <h3 className="text-body text-[#424242] mb-1" style={{ fontWeight: 600 }}>维护提醒</h3>
            <p className="text-caption text-[#9E9E9E] mb-3">
              建议每月清洁风扇滤网一次，确保空气循环效果
            </p>
            <Button
              variant="ghost"
              size="sm"
              className="h-9 px-4 rounded-md bg-white hover:bg-[#F5F5F5] text-[#424242]"
            >
              查看清洁指南
            </Button>
          </div>
        </div>
      </Card>

      {/* Tips */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-caption text-[#424242] mb-2" style={{ fontWeight: 600 }}>使用提示</h3>
        <ul className="space-y-1.5">
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>适当的空气循环有助于温度均匀</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>自动模式会根据温度智能调节风速</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>建议夏季使用高速，冬季使用低速</span>
          </li>
        </ul>
      </Card>

      {/* Save Button */}
      <Button
        className="w-full h-12 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
        style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
      >
        保存设置
      </Button>
    </div>
  );
}
