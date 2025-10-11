import { useState } from 'react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Camera, User, Heart, Check, ArrowRight, Compass } from 'lucide-react';
import { PhoneStatusBar } from './PhoneStatusBar';
import { PhoneHomeIndicator } from './PhoneHomeIndicator';

interface OnboardingGuideProps {
  onComplete: () => void;
  onNavigate: (page: any) => void;
}

export function OnboardingGuide({ onComplete, onNavigate }: OnboardingGuideProps) {
  const [currentStep, setCurrentStep] = useState(0);

  const steps = [
    {
      title: '欢迎使用',
      description: '为您的宠物提供全方位智能照护',
      icon: '🐾',
      iconBg: '#FFF9E6',
      features: [
        '智能健康管理',
        'AI 行为识别',
        '出行工具集成',
        '证件资料管理'
      ]
    },
    {
      title: '建立档案',
      subtitle: '第一步',
      description: '为您的宠物创建专属健康档案',
      icon: User,
      iconBg: '#FFF9E6',
      features: [
        '基础信息登记',
        '疫苗健康记录',
        '成长数据追踪',
        '多端同步共享'
      ]
    },
    {
      title: 'AI 相机',
      subtitle: '核心功能',
      description: '智能识别宠物状态与行为',
      icon: Camera,
      iconBg: '#FFF9E6',
      features: [
        '健康状况分析',
        '行为模式识别',
        '情绪状态检测',
        '异常警报提醒'
      ]
    },
    {
      title: '智能设备',
      subtitle: '出行工具',
      description: '出行箱监控与资料包管理',
      icon: Compass,
      iconBg: '#FFF9E6',
      features: [
        '实时环境监控',
        '智能模式调节',
        '证件资料包',
        '检疫信息管理'
      ]
    }
  ];

  const currentStepData = steps[currentStep];
  const isLastStep = currentStep === steps.length - 1;

  const handleNext = () => {
    if (isLastStep) {
      onComplete();
    } else {
      setCurrentStep(currentStep + 1);
    }
  };

  const IconComponent = typeof currentStepData.icon === 'string' ? null : currentStepData.icon;

  return (
    <div className="min-h-screen bg-[#424242] flex flex-col relative" style={{ maxWidth: '390px', margin: '0 auto' }}>
      {/* Phone Status Bar - Fixed */}
      <div className="fixed top-0 left-0 right-0 z-50" style={{ maxWidth: '390px', margin: '0 auto' }}>
        <PhoneStatusBar />
      </div>

      {/* App Container */}
      <div className="flex-1 bg-[#FAFAFA] flex flex-col overflow-hidden" style={{ paddingTop: '44px', paddingBottom: '32px' }}>
        {/* Header */}
        <div className="px-5 pt-2 pb-1">
          <h1 className="text-[28px] text-[#424242]" style={{ fontWeight: 700, letterSpacing: '-0.5px' }}>
            Felo
          </h1>
        </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-start px-5 pt-4 pb-4">
        {/* Icon Circle */}
        <div className="mb-3">
          <div 
            className="w-24 h-24 rounded-full flex items-center justify-center relative"
            style={{ 
              backgroundColor: currentStepData.iconBg,
              border: '2px solid #F5C842',
              boxShadow: '0 2px 8px rgba(245, 196, 66, 0.12)'
            }}
          >
            {typeof currentStepData.icon === 'string' ? (
              <span className="text-[36px]">{currentStepData.icon}</span>
            ) : IconComponent ? (
              <IconComponent className="w-10 h-10 text-[#616161]" strokeWidth={1.5} />
            ) : null}
          </div>
        </div>

        {/* Title Section */}
        <div className="text-center mb-4">
          {currentStepData.subtitle && (
            <p className="text-caption text-[#9E9E9E] mb-0.5">{currentStepData.subtitle}</p>
          )}
          <h2 className="text-[22px] text-[#424242] mb-1" style={{ fontWeight: 600, lineHeight: '28px' }}>
            {currentStepData.title}
          </h2>
          <p className="text-caption text-[#9E9E9E]" style={{ lineHeight: '18px' }}>
            {currentStepData.description}
          </p>
        </div>

        {/* Features List */}
        <div className="w-full space-y-2 mb-5">
          {currentStepData.features.map((feature, index) => (
            <Card 
              key={index}
              className="p-3 bg-white flex items-center gap-2.5"
              style={{ boxShadow: '0 1px 2px rgba(0, 0, 0, 0.04)' }}
            >
              <div className="w-5 h-5 rounded-full bg-[#66BB6A] flex items-center justify-center flex-shrink-0">
                <Check className="w-3 h-3 text-white" strokeWidth={2.5} />
              </div>
              <span className="text-caption text-[#424242]">{feature}</span>
            </Card>
          ))}
        </div>

        {/* Progress Dots */}
        <div className="flex gap-1.5 mb-5">
          {steps.map((_, index) => (
            <div
              key={index}
              className={`h-1.5 rounded-full transition-all ${
                index === currentStep
                  ? 'w-6 bg-[#FFD84D]'
                  : 'w-1.5 bg-[#E0E0E0]'
              }`}
            />
          ))}
        </div>

        {/* Buttons */}
        <div className="w-full space-y-2">
          {isLastStep ? (
            <>
              <Button
                onClick={() => {
                  onComplete();
                  setTimeout(() => onNavigate('pet-registration'), 100);
                }}
                className="w-full h-12 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
                style={{ 
                  boxShadow: '0 2px 6px rgba(255, 216, 77, 0.3)'
                }}
              >
                <span style={{ fontWeight: 600 }}>创建宠物档案</span>
                <ArrowRight className="w-4 h-4 ml-2" strokeWidth={2} />
              </Button>
              <Button
                onClick={handleNext}
                variant="ghost"
                className="w-full h-11 rounded-md text-[#9E9E9E] hover:bg-[#F5F5F5] border-none"
              >
                <span style={{ fontWeight: 500 }}>跳过，稍后填写</span>
              </Button>
            </>
          ) : (
            <Button
              onClick={handleNext}
              className="w-full h-12 rounded-md bg-[#FFA726] hover:bg-[#FB8C00] text-white border-none"
              style={{ 
                boxShadow: '0 2px 6px rgba(255, 167, 38, 0.3)'
              }}
            >
              <span style={{ fontWeight: 600 }}>下一步</span>
              <ArrowRight className="w-4 h-4 ml-2" strokeWidth={2} />
            </Button>
          )}
        </div>
      </div>
      </div>

      {/* Phone Home Indicator - Fixed */}
      <div className="fixed bottom-0 left-0 right-0 z-50" style={{ maxWidth: '390px', margin: '0 auto' }}>
        <PhoneHomeIndicator />
      </div>
    </div>
  );
}
