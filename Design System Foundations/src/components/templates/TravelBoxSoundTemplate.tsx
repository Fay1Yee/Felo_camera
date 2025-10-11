import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Slider } from '../ui/slider';
import { 
  Volume2,
  VolumeX,
  Volume1,
  Bell,
  Music
} from 'lucide-react';

interface TravelBoxSoundTemplateProps {
  onNavigate: (page: string) => void;
}

export function TravelBoxSoundTemplate({ onNavigate }: TravelBoxSoundTemplateProps) {
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [volume, setVolume] = useState([70]);
  const [alertSound, setAlertSound] = useState(true);
  const [whiteNoise, setWhiteNoise] = useState(false);

  const getVolumeIcon = () => {
    if (volume[0] === 0) return VolumeX;
    if (volume[0] < 50) return Volume1;
    return Volume2;
  };

  const VolumeIcon = getVolumeIcon();

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Volume Control */}
      <Card className="p-5 bg-[#FFFBEA]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <div className="text-center mb-4">
          <div className="w-20 h-20 rounded-full bg-[#FFD84D] flex items-center justify-center mx-auto mb-4">
            <VolumeIcon className="w-10 h-10 text-[#424242]" strokeWidth={1.5} />
          </div>
          <h2 className="text-[40px] text-[#424242] mb-1" style={{ fontWeight: 700 }}>
            {volume[0]}%
          </h2>
          <p className="text-caption text-[#9E9E9E]">当前音量</p>
        </div>

        <div className="p-4 rounded-md bg-white">
          <Slider
            value={volume}
            onValueChange={setVolume}
            min={0}
            max={100}
            step={5}
            className="w-full mb-3"
          />
          <div className="flex items-center justify-between text-caption text-[#9E9E9E]">
            <span>静音</span>
            <span>最大</span>
          </div>
        </div>
      </Card>

      {/* Sound Settings */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>声音设置</h3>
        
        <div className="space-y-0">
          <div className="flex items-center justify-between py-3">
            <div className="flex items-center gap-3">
              <Volume2 className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
              <div>
                <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>启用声音</p>
                <p className="text-caption text-[#9E9E9E]">开启所有声音功能</p>
              </div>
            </div>
            <Switch 
              checked={soundEnabled}
              onCheckedChange={setSoundEnabled}
            />
          </div>

          {soundEnabled && (
            <>
              <div className="h-px bg-[#F5F5F5]" />

              <div className="flex items-center justify-between py-3">
                <div className="flex items-center gap-3">
                  <Bell className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                  <div>
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>警报声音</p>
                    <p className="text-caption text-[#9E9E9E]">温度异常时播放警报</p>
                  </div>
                </div>
                <Switch 
                  checked={alertSound}
                  onCheckedChange={setAlertSound}
                />
              </div>

              <div className="h-px bg-[#F5F5F5]" />

              <div className="flex items-center justify-between py-3">
                <div className="flex items-center gap-3">
                  <Music className="w-5 h-5 text-[#9E9E9E]" strokeWidth={1.5} />
                  <div>
                    <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>白噪音</p>
                    <p className="text-caption text-[#9E9E9E]">播放舒缓白噪音</p>
                  </div>
                </div>
                <Switch 
                  checked={whiteNoise}
                  onCheckedChange={setWhiteNoise}
                />
              </div>
            </>
          )}
        </div>
      </Card>

      {/* Sound Types */}
      {soundEnabled && (
        <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
          <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>白噪音类型</h3>
          <div className="grid grid-cols-2 gap-2">
            {[
              { name: '雨声', emoji: '🌧️', active: true },
              { name: '海浪', emoji: '🌊', active: false },
              { name: '森林', emoji: '🌲', active: false },
              { name: '火炉', emoji: '🔥', active: false }
            ].map((sound, index) => (
              <button
                key={index}
                className={`p-3 rounded-md transition-all ${
                  sound.active 
                    ? 'bg-[#FFF9E6] border border-[#F5C842]' 
                    : 'bg-[#F5F5F5] hover:bg-[#EEEEEE]'
                }`}
              >
                <div className="text-[24px] mb-1">{sound.emoji}</div>
                <p className="text-caption text-[#424242]">{sound.name}</p>
              </button>
            ))}
          </div>
        </Card>
      )}

      {/* Volume Presets */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>快速设置</h3>
        <div className="grid grid-cols-3 gap-2">
          {[
            { label: '静音', value: 0 },
            { label: '适中', value: 50 },
            { label: '最大', value: 100 }
          ].map((preset, index) => (
            <Button
              key={index}
              variant="ghost"
              onClick={() => setVolume([preset.value])}
              className={`h-11 rounded-md ${
                volume[0] === preset.value 
                  ? 'bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242]' 
                  : 'bg-[#F5F5F5] hover:bg-[#EEEEEE] text-[#9E9E9E]'
              }`}
            >
              {preset.label}
            </Button>
          ))}
        </div>
      </Card>

      {/* Schedule */}
      <Card className="p-4 bg-white" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-body text-[#424242] mb-3" style={{ fontWeight: 600 }}>定时设置</h3>
        <div className="space-y-3">
          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-caption text-[#424242] mb-0.5" style={{ fontWeight: 600 }}>夜间自动降低音量</p>
              <p className="text-caption text-[#9E9E9E]">22:00 - 07:00 降至30%</p>
            </div>
            <Switch defaultChecked />
          </div>
        </div>
      </Card>

      {/* Tips */}
      <Card className="p-4 bg-[#F5F5F5]" style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}>
        <h3 className="text-caption text-[#424242] mb-2" style={{ fontWeight: 600 }}>使用提示</h3>
        <ul className="space-y-1.5">
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>白噪音可以帮助宠物更好地休息</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>建议在夜间降低音量避免打扰</span>
          </li>
          <li className="text-caption text-[#9E9E9E] flex items-start gap-2">
            <span className="text-[#F5C842]">•</span>
            <span>警报声音即使静音也会播放</span>
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
