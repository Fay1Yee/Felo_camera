import { Wifi, Signal, Battery } from 'lucide-react';

export function PhoneStatusBar() {
  // 获取当前时间
  const currentTime = new Date().toLocaleTimeString('zh-CN', { 
    hour: '2-digit', 
    minute: '2-digit',
    hour12: false 
  });

  return (
    <div className="h-11 bg-white/98 backdrop-blur-md px-6 flex items-center justify-between relative" style={{ margin: 0, padding: '0 24px' }}>
      {/* Left: Time */}
      <div className="flex items-center">
        <span className="text-[15px] text-[#424242]" style={{ fontWeight: 600 }}>
          {currentTime}
        </span>
      </div>

      {/* Center: Dynamic Island / Notch (optional) */}
      <div className="absolute left-1/2 top-0 transform -translate-x-1/2 w-32 h-7 bg-[#424242] rounded-b-2xl" />

      {/* Right: Status Icons */}
      <div className="flex items-center gap-2">
        <Signal className="w-4 h-4 text-[#424242]" strokeWidth={2} />
        <Wifi className="w-4 h-4 text-[#424242]" strokeWidth={2} />
        <div className="flex items-center gap-0.5">
          <Battery className="w-6 h-6 text-[#424242]" strokeWidth={2} />
          <span className="text-[12px] text-[#424242]" style={{ fontWeight: 600 }}>100%</span>
        </div>
      </div>
    </div>
  );
}
