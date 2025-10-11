import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Slider } from '../ui/slider';
import { 
  Thermometer,
  AlertTriangle,
  TrendingUp,
  TrendingDown
} from 'lucide-react';

interface TravelBoxTemperatureTemplateProps {
  onNavigate: (page: string) => void;
}

export function TravelBoxTemperatureTemplate({ onNavigate }: TravelBoxTemperatureTemplateProps) {
  const [tempAlert, setTempAlert] = useState(true);
  const [tempRange, setTempRange] = useState([18, 26]);
  const [autoAdjust, setAutoAdjust] = useState(true);

  const currentTemp = 23;
  const isInRange = currentTemp >= tempRange[0] && currentTemp <= tempRange[1];

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Current Temperature */}
      <Card 
        className={`p-5 ${isInRange ? 'bg-[#EDF7ED]' : 'bg-[#FFEBEE]'}`}
        style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
      >
        <div className="text-center">
          <div className={`w-20 h-20 rounded-full ${isInRange ? 'bg-[#66BB6A]/20' : 'bg-[#EF5350]/20'} flex items-center justify-center mx-auto mb-4`}>
            <Thermometer className={`w-10 h-10 ${isInRange ? 'text-[#66BB6A]' : 'text-[#EF5350]'}`} strokeWidth={1.5} />
          </div>
          <h2 className="text-[40px] text-[#424242] mb-1" style={{ fontWeight: 700 }}>
            {currentTemp}°C
          </h2>
          <p className="text-caption text-[#9E9E9E] mb-1">当前温度</p>
          {isInRange ? (
            <div className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#66BB6A]/20">
              <span className="text-caption text-[#2E7D32]" style={{ fontWeight: 600 }}>温度正常</span>
            </div>
          ) : (
            <div className="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-[#EF5350]/20">
              <AlertTriangle className="w-3 h-3 text-[#EF5350]" strokeWidth={2} />
              <span className="text-caption text-[#EF5350]" style={{ fontWeight: 600 }}>温度异常</span>
            </div>
          )}
        </div>

        {/* Temperature Trend */}
        <div className="grid grid-cols-2 gap-3 mt-4">
          <div className="p-3 rounded-md bg-white text-center">
            <div className="flex items-center justify-center gap-1 mb-1">
              <TrendingUp className="w-4 h-4 text-[#EF5350]" strokeWidth={1.5} />
              <p className="text-caption text-[#9E9E9E]">最高</p>
            </div>
            <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>28°C</p>
          </div>
          <div className="p-3 rounded-md bg-white text-center">
            <div className="flex items-center justify-center gap-1 mb-1">
              <TrendingDown className="w-4 h-4 text-[#42A5F5]" strokeWidth={1.5} />
              <p className="text-caption text-[#9E9E9E]">最低</p>
            </div>
            <p className="text-body text-[#424242]" style={{ fontWeight: 600 }}>20°C</p>
          </div>
        </div>
      </Card>

      {/* Temperature Alert Settings */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h3 className="text-body text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>温度警报</h3>
            <p className="text-caption text-[#9E9E9E]">超出范围时提醒</p>
          </div>
          <Switch 
            checked={tempAlert}
            onCheckedChange={setTempAlert}
          />
        </div>

        {tempAlert && (
          <div className="p-4 rounded-md bg-[#F5F5F5]">
            <div className="flex items-center justify-between mb-3">
              <span className="text-caption text-[#9E9E9E]">安全温度范围</span>
              <span className="text-body text-[#424242]" style={{ fontWeight: 600 }}>
                {tempRange[0]}°C - {tempRange[1]}°C
              </span>
            </div>
            <Slider
              value={tempRange}
              onValueChange={setTempRange}
              min={10}
              max={35}
              step={1}
              className="w-full mb-3"
            />
            <div className="flex items-center justify-between text-caption text-[#9E9E9E]">
              <span>10°C</span>
              <span>35°C</span>
            </div>
          </div>
        )}
      </Card>

      {/* Auto Adjust */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-body text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>自动调节</h3>
            <p className="text-caption text-[#9E9E9E]">智能保持温度在安全范围</p>
          </div>
          <Switch 
            checked={autoAdjust}
            onCheckedChange={setAutoAdjust}
          />
        </div>

        {autoAdjust && (
          <div className="mt-3 p-3 rounded-md bg-[#FFF9E6]">
            <p className="text-caption text-[#9E9E9E]">
              系统将自动启动加热或制冷功能，保持温度在设定范围内
            </p>
          </div>
        )}
      </Card>

      {/* Alert Methods */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>提醒方式</h3>
        <div className="space-y-3">
          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>推送通知</p>
              <p className="text-caption text-[#9E9E9E]">手机接收警报通知</p>
            </div>
            <Switch defaultChecked />
          </div>

          <div className="h-px bg-[#F5F5F5]" />

          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>声音警报</p>
              <p className="text-caption text-[#9E9E9E]">设备发出警报声</p>
            </div>
            <Switch defaultChecked />
          </div>

          <div className="h-px bg-[#F5F5F5]" />

          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>振动提醒</p>
              <p className="text-caption text-[#9E9E9E]">手机振动提醒</p>
            </div>
            <Switch />
          </div>
        </div>
      </Card>

      {/* Temperature History */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>24小时温度记录</h3>
        <div className="space-y-2">
          {[
            { time: '22:00', temp: 23, status: 'normal' },
            { time: '18:00', temp: 24, status: 'normal' },
            { time: '14:00', temp: 28, status: 'high' },
            { time: '10:00', temp: 22, status: 'normal' },
            { time: '06:00', temp: 20, status: 'normal' }
          ].map((record, index) => (
            <div key={index} className="flex items-center justify-between py-2">
              <span className="text-caption text-[#9E9E9E]">{record.time}</span>
              <div className="flex items-center gap-2">
                <span className="text-caption text-[#424242]">{record.temp}°C</span>
                {record.status === 'high' && (
                  <AlertTriangle className="w-4 h-4 text-[#EF5350]" strokeWidth={1.5} />
                )}
              </div>
            </div>
          ))}
        </div>
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
