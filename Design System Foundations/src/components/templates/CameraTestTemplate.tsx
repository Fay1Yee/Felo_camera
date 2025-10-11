import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { AICameraInterface } from '../AICameraInterface';
import { Camera, Sparkles, Heart, Package, Activity, ImageIcon } from 'lucide-react';

interface CameraTestTemplateProps {
  onNavigate: (page: any) => void;
}

export function CameraTestTemplate({ onNavigate }: CameraTestTemplateProps) {
  const [showCamera, setShowCamera] = useState(false);

  const handleCapture = (mode: string, results?: any) => {
    console.log('Captured:', mode, results);
    setTimeout(() => {
      setShowCamera(false);
    }, 500);
  };

  const modes = [
    {
      id: 'pet',
      name: '宠物识别',
      icon: Heart,
      color: '#2F5233',
      description: '主人能看出我是什么品种和心情'
    },
    {
      id: 'carrier',
      name: '出行箱扫描',
      icon: Package,
      color: '#37474F',
      description: '主人能检查我的出行箱状态'
    },
    {
      id: 'health',
      name: '健康标记',
      icon: Activity,
      color: '#2F5233',
      description: '主人能标记我不舒服的地方'
    },
    {
      id: 'photo',
      name: '普通拍摄',
      icon: ImageIcon,
      color: '#78909C',
      description: '主人给我拍照存到档案里'
    }
  ];

  return (
    <>
      <div className="space-y-6 pb-8">
        <div className="pt-6">
          <h1 className="text-display mb-2 text-[#37474F]">AI 相机体验</h1>
          <p className="text-body text-[#78909C]">点击下方按钮打开 AI 相机界面</p>
        </div>

        {/* Launch Camera Button */}
        <Card className="p-8 border-2 border-[#FFD84D] bg-gradient-to-br from-[#FFF8E1] to-white relative overflow-hidden">
          <div className="absolute inset-0 dot-grid-bg text-[#FFD84D] opacity-20" />
          
          <div className="relative text-center">
            <div className="w-24 h-24 rounded-full bg-[#FFD84D] mx-auto mb-6 flex items-center justify-center relative">
              <div className="absolute inset-0 dot-grid-bg text-[#2F5233] rounded-full scale-150 opacity-20" />
              <Camera className="w-12 h-12 text-[#37474F] relative" strokeWidth={1.5} />
            </div>
            
            <h3 className="text-title mb-2 text-[#37474F]">体验 AI 相机</h3>
            <p className="text-caption text-[#78909C] mb-6">
              支持 4 种识别模式，智能识别宠物、设备和健康信息
            </p>
            
            <Button
              onClick={() => setShowCamera(true)}
              className="h-14 px-8 rounded-full bg-[#FFD84D] hover:bg-[#FFC107] text-[#37474F] border-none shadow-md"
            >
              <Camera className="w-5 h-5 mr-2" strokeWidth={1.5} />
              打开 AI 相机
            </Button>
          </div>
        </Card>

        {/* Features Grid */}
        <div>
          <h3 className="text-body mb-4 text-[#37474F]">识别模式</h3>
          <div className="grid grid-cols-2 gap-3">
            {modes.map((mode) => {
              const Icon = mode.icon;
              return (
                <Card 
                  key={mode.id}
                  className="p-5 border border-gray-200 shadow-sm bg-white hover:shadow-md transition-shadow"
                >
                  <div 
                    className="w-12 h-12 rounded-full flex items-center justify-center mb-3"
                    style={{ backgroundColor: `${mode.color}15` }}
                  >
                    <Icon 
                      className="w-6 h-6" 
                      style={{ color: mode.color }}
                      strokeWidth={1.5}
                    />
                  </div>
                  <h4 className="text-body mb-1 text-[#37474F]">{mode.name}</h4>
                  <p className="text-caption text-[#78909C]">{mode.description}</p>
                </Card>
              );
            })}
          </div>
        </div>

        {/* Feature Highlights */}
        <Card className="p-6 border border-gray-200 bg-white shadow-sm">
          <div className="flex items-start gap-3 mb-4">
            <div className="w-8 h-8 rounded-full bg-[#E8F5E9] flex items-center justify-center flex-shrink-0">
              <Sparkles className="w-4 h-4 text-[#2F5233]" strokeWidth={2} />
            </div>
            <div>
              <h4 className="text-body mb-1 text-[#37474F]">核心特性</h4>
              <p className="text-caption text-[#78909C]">Nothing OS 风格的 AI 相机体验</p>
            </div>
          </div>

          <div className="space-y-3">
            <div className="flex items-center gap-3">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2F5233]" />
              <p className="text-caption text-[#78909C]">实时 AI 识别，1秒内响应</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2F5233]" />
              <p className="text-caption text-[#78909C]">点阵边框高亮识别区域</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2F5233]" />
              <p className="text-caption text-[#78909C]">置信度显示，结果准确可靠</p>
            </div>
            <div className="flex items-center gap-3">
              <div className="w-1.5 h-1.5 rounded-full bg-[#2F5233]" />
              <p className="text-caption text-[#78909C]">左右箭头快速切换模式</p>
            </div>
          </div>
        </Card>

        {/* Tips */}
        <Card className="p-5 border border-gray-200 bg-[#F5F5F0] shadow-none">
          <div className="flex items-start gap-3">
            <span className="text-2xl">💡</span>
            <div>
              <h4 className="text-body mb-1 text-[#37474F]">使用提示</h4>
              <p className="text-caption text-[#78909C]">
                相机会根据当前模式自动识别画面内容。切换模式时会显示功能说明，识别到目标后会显示点阵边框和标签信息。
              </p>
            </div>
          </div>
        </Card>
      </div>

      {/* AI Camera Interface */}
      {showCamera && (
        <AICameraInterface 
          onClose={() => setShowCamera(false)}
          onCapture={handleCapture}
        />
      )}
    </>
  );
}