import { useState, useEffect } from 'react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { PhoneStatusBar } from './PhoneStatusBar';
import { PhoneHomeIndicator } from './PhoneHomeIndicator';
import { 
  X, 
  Zap, 
  ZapOff, 
  Camera, 
  Sparkles,
  Heart,
  Package,
  Activity,
  ImageIcon,
  ChevronLeft,
  ChevronRight
} from 'lucide-react';

type CameraMode = 'pet' | 'carrier' | 'health' | 'photo';

interface DetectionResult {
  type: 'pet' | 'carrier' | 'health';
  label: string;
  confidence: number;
  position: { x: number; y: number; width: number; height: number };
  details?: string;
}

interface AICameraInterfaceProps {
  onClose: () => void;
  onCapture?: (mode: CameraMode, results?: DetectionResult[]) => void;
}

export function AICameraInterface({ onClose, onCapture }: AICameraInterfaceProps) {
  const [mode, setMode] = useState<CameraMode>('pet');
  const [flashEnabled, setFlashEnabled] = useState(false);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [detections, setDetections] = useState<DetectionResult[]>([]);
  const [showModeHint, setShowModeHint] = useState(true);

  const modes = [
    {
      id: 'pet' as CameraMode,
      name: '宠物识别',
      icon: Heart,
      color: '#2F5233',
      bgColor: '#E8F5E9',
      description: '识别宠物品种、情绪'
    },
    {
      id: 'carrier' as CameraMode,
      name: '出行箱',
      icon: Package,
      color: '#37474F',
      bgColor: '#FFF8E1',
      description: '扫描设备状态'
    },
    {
      id: 'health' as CameraMode,
      name: '健康标记',
      icon: Activity,
      color: '#2F5233',
      bgColor: '#E8F5E9',
      description: '记录健康症状'
    },
    {
      id: 'photo' as CameraMode,
      name: '普通拍摄',
      icon: ImageIcon,
      color: '#78909C',
      bgColor: '#F5F5F0',
      description: '拍摄照片保存'
    }
  ];

  const currentMode = modes.find(m => m.id === mode)!;

  // Simulate AI detection based on mode
  useEffect(() => {
    if (mode === 'pet') {
      // Simulate pet detection after 1 second
      const timer = setTimeout(() => {
        setDetections([
          {
            type: 'pet',
            label: '金毛犬',
            confidence: 0.94,
            position: { x: 25, y: 30, width: 50, height: 45 },
            details: '情绪：放松'
          }
        ]);
      }, 1000);
      return () => clearTimeout(timer);
    } else if (mode === 'carrier') {
      const timer = setTimeout(() => {
        setDetections([
          {
            type: 'carrier',
            label: '智能出行箱',
            confidence: 0.89,
            position: { x: 20, y: 35, width: 60, height: 40 },
            details: '电量：85%'
          }
        ]);
      }, 1000);
      return () => clearTimeout(timer);
    } else if (mode === 'health') {
      const timer = setTimeout(() => {
        setDetections([
          {
            type: 'health',
            label: '眼部区域',
            confidence: 0.91,
            position: { x: 30, y: 25, width: 40, height: 15 },
            details: '可添加健康标记'
          }
        ]);
      }, 1000);
      return () => clearTimeout(timer);
    } else {
      setDetections([]);
    }
  }, [mode]);

  // Hide mode hint after 3 seconds
  useEffect(() => {
    const timer = setTimeout(() => {
      setShowModeHint(false);
    }, 3000);
    return () => clearTimeout(timer);
  }, [mode]);

  const handleCapture = () => {
    setIsAnalyzing(true);
    
    setTimeout(() => {
      setIsAnalyzing(false);
      if (onCapture) {
        onCapture(mode, detections);
      }
    }, 1500);
  };

  const switchMode = (newMode: CameraMode) => {
    setMode(newMode);
    setShowModeHint(true);
  };

  const nextMode = () => {
    const currentIndex = modes.findIndex(m => m.id === mode);
    const nextIndex = (currentIndex + 1) % modes.length;
    switchMode(modes[nextIndex].id);
  };

  const prevMode = () => {
    const currentIndex = modes.findIndex(m => m.id === mode);
    const prevIndex = (currentIndex - 1 + modes.length) % modes.length;
    switchMode(modes[prevIndex].id);
  };

  return (
    <div className="fixed inset-0 bg-[#424242] z-50 flex flex-col relative" style={{ maxWidth: '390px', margin: '0 auto' }}>
      {/* Phone Status Bar - Fixed */}
      <div className="fixed top-0 left-0 right-0 z-[60] bg-black" style={{ maxWidth: '390px', margin: '0 auto' }}>
        <PhoneStatusBar />
      </div>

      {/* Camera Container */}
      <div className="flex-1 bg-black flex flex-col overflow-hidden" style={{ paddingTop: '44px', paddingBottom: '32px' }}>
        {/* Camera Viewfinder - Full screen */}
        <div className="flex-1 relative overflow-hidden">
        {/* Simulated Camera Feed */}
        <div className="absolute inset-0 bg-gradient-to-br from-gray-800 via-gray-700 to-gray-900">
          {/* Dot grid overlay for Nothing OS feel */}
          <div className="absolute inset-0 dot-grid-bg text-white opacity-5" />
          
          {/* Center guide lines */}
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <div className="w-full h-full relative">
              {/* Vertical center line */}
              <div className="absolute left-1/2 top-0 bottom-0 w-px bg-white opacity-10" />
              {/* Horizontal center line */}
              <div className="absolute top-1/2 left-0 right-0 h-px bg-white opacity-10" />
            </div>
          </div>
        </div>

        {/* Top Controls */}
        <div className="absolute top-0 left-0 right-0 px-6 py-4 flex items-center justify-between z-10">
          <Button
            onClick={onClose}
            variant="ghost"
            className="w-10 h-10 p-0 rounded-full bg-black/50 backdrop-blur-md hover:bg-black/70 text-white border-none"
          >
            <X className="w-6 h-6" strokeWidth={1.5} />
          </Button>

          <div className="flex items-center gap-3">
            {/* Mode Indicator */}
            <div 
              className="px-4 py-2 rounded-full backdrop-blur-md border flex items-center gap-2"
              style={{ 
                backgroundColor: `${currentMode.bgColor}33`,
                borderColor: `${currentMode.color}66`
              }}
            >
              <currentMode.icon 
                className="w-4 h-4" 
                style={{ color: currentMode.color }}
                strokeWidth={1.5}
              />
              <span className="text-caption text-white">{currentMode.name}</span>
            </div>

            {/* Flash Toggle */}
            <Button
              onClick={() => setFlashEnabled(!flashEnabled)}
              variant="ghost"
              className="w-10 h-10 p-0 rounded-full bg-black/50 backdrop-blur-md hover:bg-black/70 text-white border-none"
            >
              {flashEnabled ? (
                <Zap className="w-5 h-5 text-[#FFD84D]" strokeWidth={1.5} />
              ) : (
                <ZapOff className="w-5 h-5" strokeWidth={1.5} />
              )}
            </Button>
          </div>
        </div>

        {/* AI Detection Overlays */}
        {detections.map((detection, index) => (
          <div
            key={index}
            className="absolute animate-in fade-in zoom-in-95 duration-500"
            style={{
              left: `${detection.position.x}%`,
              top: `${detection.position.y}%`,
              width: `${detection.position.width}%`,
              height: `${detection.position.height}%`
            }}
          >
            {/* Dot border frame */}
            <div 
              className="absolute inset-0 rounded-2xl animate-pulse"
              style={{
                border: `2px dashed ${currentMode.color}`,
                boxShadow: `0 0 20px ${currentMode.color}40`
              }}
            >
              {/* Corner markers */}
              <div className="absolute -top-1 -left-1 w-4 h-4 rounded-tl-lg" style={{ borderTop: `3px solid ${currentMode.color}`, borderLeft: `3px solid ${currentMode.color}` }} />
              <div className="absolute -top-1 -right-1 w-4 h-4 rounded-tr-lg" style={{ borderTop: `3px solid ${currentMode.color}`, borderRight: `3px solid ${currentMode.color}` }} />
              <div className="absolute -bottom-1 -left-1 w-4 h-4 rounded-bl-lg" style={{ borderBottom: `3px solid ${currentMode.color}`, borderLeft: `3px solid ${currentMode.color}` }} />
              <div className="absolute -bottom-1 -right-1 w-4 h-4 rounded-br-lg" style={{ borderBottom: `3px solid ${currentMode.color}`, borderRight: `3px solid ${currentMode.color}` }} />
            </div>

            {/* Label Badge */}
            <div 
              className="absolute -top-8 left-0 px-3 py-1.5 rounded-full backdrop-blur-md flex items-center gap-2"
              style={{ 
                backgroundColor: `${currentMode.bgColor}DD`,
                border: `1px solid ${currentMode.color}`
              }}
            >
              <Sparkles className="w-3 h-3" style={{ color: currentMode.color }} strokeWidth={2} />
              <span className="text-caption" style={{ color: currentMode.color }}>
                {detection.label}
              </span>
              <Badge 
                variant="secondary" 
                className="ml-1 px-1.5 py-0 h-4 rounded-full border-none text-[10px]"
                style={{ 
                  backgroundColor: currentMode.color,
                  color: 'white'
                }}
              >
                {Math.round(detection.confidence * 100)}%
              </Badge>
            </div>

            {/* Details */}
            {detection.details && (
              <div 
                className="absolute -bottom-8 left-0 px-3 py-1 rounded-full backdrop-blur-md"
                style={{ 
                  backgroundColor: `${currentMode.bgColor}DD`,
                  border: `1px solid ${currentMode.color}`
                }}
              >
                <span className="text-caption" style={{ color: currentMode.color }}>
                  {detection.details}
                </span>
              </div>
            )}
          </div>
        ))}

        {/* Mode Hint - Shows when switching modes */}
        {showModeHint && (
          <div className="absolute top-24 left-1/2 transform -translate-x-1/2 animate-in fade-in slide-in-from-top-4 duration-300">
            <div className="px-6 py-3 rounded-full bg-black/80 backdrop-blur-md border border-white/20">
              <p className="text-body text-white text-center">
                {currentMode.description}
              </p>
            </div>
          </div>
        )}

        {/* Analyzing Overlay */}
        {isAnalyzing && (
          <div className="absolute inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center animate-in fade-in duration-200">
            <div className="text-center">
              <div className="relative mb-6">
                <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] rounded-full scale-150 opacity-20" />
                <div className="w-20 h-20 rounded-full bg-[#FFD84D] mx-auto flex items-center justify-center animate-pulse relative">
                  <Sparkles className="w-10 h-10 text-[#37474F]" strokeWidth={1.5} />
                </div>
              </div>
              <p className="text-body text-white mb-2">AI 分析中...</p>
              <p className="text-caption text-[#90A4AE]">{currentMode.name}</p>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Controls */}
      <div className="bg-black/95 backdrop-blur-md border-t border-white/10 pb-safe">
        {/* Mode Switcher */}
        <div className="px-4 py-4 overflow-x-auto">
          <div className="flex items-center justify-center gap-2 min-w-max mx-auto">
            {modes.map((m) => {
              const Icon = m.icon;
              const isActive = m.id === mode;
              return (
                <button
                  key={m.id}
                  onClick={() => switchMode(m.id)}
                  className={`
                    flex flex-col items-center gap-1.5 px-4 py-2 rounded-2xl transition-all
                    ${isActive ? 'scale-105' : 'scale-100 opacity-60'}
                  `}
                  style={{
                    backgroundColor: isActive ? `${m.bgColor}33` : 'transparent',
                    border: isActive ? `2px solid ${m.color}` : '2px solid transparent'
                  }}
                >
                  <Icon 
                    className={`w-6 h-6 ${isActive ? '' : 'text-white/60'}`}
                    style={isActive ? { color: m.color } : {}}
                    strokeWidth={1.5}
                  />
                  <span 
                    className={`text-caption whitespace-nowrap ${isActive ? '' : 'text-white/60'}`}
                    style={isActive ? { color: m.color } : {}}
                  >
                    {m.name}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Capture Button Area */}
        <div className="flex items-center justify-center gap-8 px-6 pb-6 pt-2">
          {/* Previous Mode */}
          <Button
            onClick={prevMode}
            variant="ghost"
            className="w-12 h-12 p-0 rounded-full bg-white/10 hover:bg-white/20 text-white border-none"
          >
            <ChevronLeft className="w-6 h-6" strokeWidth={1.5} />
          </Button>

          {/* Capture Button */}
          <button
            onClick={handleCapture}
            disabled={isAnalyzing}
            className="relative group"
          >
            {/* Outer ring */}
            <div 
              className="w-20 h-20 rounded-full flex items-center justify-center transition-all group-hover:scale-105"
              style={{ 
                backgroundColor: `${currentMode.color}20`,
                border: `3px solid ${currentMode.color}`
              }}
            >
              {/* Inner button */}
              <div 
                className="w-16 h-16 rounded-full flex items-center justify-center transition-all group-hover:scale-95"
                style={{ backgroundColor: currentMode.color }}
              >
                <Camera className="w-8 h-8 text-white" strokeWidth={1.5} />
              </div>
            </div>
            
            {/* Dot halo effect */}
            <div 
              className="absolute inset-0 dot-grid-bg rounded-full scale-125 opacity-20 pointer-events-none"
              style={{ color: currentMode.color }}
            />
          </button>

          {/* Next Mode */}
          <Button
            onClick={nextMode}
            variant="ghost"
            className="w-12 h-12 p-0 rounded-full bg-white/10 hover:bg-white/20 text-white border-none"
          >
            <ChevronRight className="w-6 h-6" strokeWidth={1.5} />
          </Button>
        </div>

        {/* Mode Description */}
        <div className="px-6 pb-4">
          <p className="text-caption text-center text-white/60">
            {currentMode.description}
          </p>
        </div>
      </div>
      </div>

      {/* Phone Home Indicator - Fixed */}
      <div className="fixed bottom-0 left-0 right-0 z-[60] bg-black" style={{ maxWidth: '390px', margin: '0 auto' }}>
        <PhoneHomeIndicator />
      </div>
    </div>
  );
}