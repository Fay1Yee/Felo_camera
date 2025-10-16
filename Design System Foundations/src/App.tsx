import { useState, createContext } from 'react';
import { Button } from './components/ui/button';

// Import templates
import { HomeTemplate } from './components/templates/HomeTemplate';
import { TravelHubTemplate } from './components/templates/TravelHubTemplate';
import { SettingsTemplate } from './components/templates/SettingsTemplate';
import { ScenariosTemplate } from './components/templates/ScenariosTemplate';
import { CreateProfileTemplate } from './components/templates/CreateProfileTemplate';
import { PetRegistrationTemplate } from './components/templates/PetRegistrationTemplate';
import { HealthTemplate } from './components/templates/HealthTemplate';
import { ReminderTemplate } from './components/templates/ReminderTemplate';
import { OnboardingGuide } from './components/OnboardingGuide';
import { AICameraInterface } from './components/AICameraInterface';
import { CameraTestTemplate } from './components/templates/CameraTestTemplate';
import { HealthDetailTemplate } from './components/templates/HealthDetailTemplate';
import { TravelBoxSettingsTemplate } from './components/templates/TravelBoxSettingsTemplate';
import { NotificationSettingsTemplate } from './components/templates/NotificationSettingsTemplate';
import { PetProfileDetailTemplate } from './components/templates/PetProfileDetailTemplate';
import { TravelPlanDetailTemplate } from './components/templates/TravelPlanDetailTemplate';
import { LifeRecordsTemplate } from './components/templates/LifeRecordsTemplate';
import { OptimizedLifeRecordsTemplate } from './components/templates/OptimizedLifeRecordsTemplate';
import { DataBackupTemplate } from './components/templates/DataBackupTemplate';
import { HabitsDetailTemplate } from './components/templates/HabitsDetailTemplate';
import { TravelBoxWiFiTemplate } from './components/templates/TravelBoxWiFiTemplate';
import { TravelBoxBluetoothTemplate } from './components/templates/TravelBoxBluetoothTemplate';
import { TravelBoxTemperatureTemplate } from './components/templates/TravelBoxTemperatureTemplate';
import { TravelBoxSoundTemplate } from './components/templates/TravelBoxSoundTemplate';
import { TravelBoxFanTemplate } from './components/templates/TravelBoxFanTemplate';
import { PhoneStatusBar } from './components/PhoneStatusBar';
import { PhoneHomeIndicator } from './components/PhoneHomeIndicator';

// Icons
import { Home, User, Camera, Box, UserCircle, ArrowLeft, Plus } from 'lucide-react';

type PageType = 'home' | 'scenarios' | 'travel-hub' | 'pet-profile-detail' | 'settings' | 'create-profile' | 'pet-registration' | 'health' | 'reminder' | 'camera-test' | 'health-detail' | 'travel-box-settings' | 'notification-settings' | 'travel-plan-detail' | 'life-records' | 'optimized-life-records' | 'data-backup' | 'habits-detail' | 'travel-box-wifi' | 'travel-box-bluetooth' | 'travel-box-temperature' | 'travel-box-sound' | 'travel-box-fan';

export type ScenarioType = 'travel' | 'home' | 'medical' | 'city';

export interface ScenarioContextType {
  currentScenario: ScenarioType;
  setCurrentScenario: (scenario: ScenarioType) => void;
}

export const ScenarioContext = createContext<ScenarioContextType>({
  currentScenario: 'travel',
  setCurrentScenario: () => {},
});

interface PageConfig {
  title: string;
  subtitle?: string;
  component: React.ComponentType<{ onNavigate: (page: PageType) => void }>;
  showInNav?: boolean;
  parentPage?: PageType;
}

export default function App() {
  const [pageStack, setPageStack] = useState<PageType[]>(['home']);
  const [showCamera, setShowCamera] = useState(false);
  const [showOnboarding, setShowOnboarding] = useState(true);
  const [currentScenario, setCurrentScenario] = useState<ScenarioType>('travel');

  const currentPage = pageStack[pageStack.length - 1];

  const pages: Record<PageType, PageConfig> = {
    'home': {
      title: '今日',
      subtitle: '宠物管家',
      component: HomeTemplate,
      showInNav: true
    },
    'pet-profile-detail': {
      title: '档案',
      subtitle: '宠物身份证',
      component: PetProfileDetailTemplate,
      showInNav: true
    },
    'scenarios': {
      title: '出行箱',
      subtitle: '设备与场景',
      component: ScenariosTemplate,
      showInNav: true
    },
    'settings': {
      title: '我的',
      subtitle: '个人中心',
      component: SettingsTemplate,
      showInNav: true
    },
    'travel-hub': {
      title: '出行',
      subtitle: '设备与工具',
      component: TravelHubTemplate,
      parentPage: 'scenarios'
    },
    'create-profile': {
      title: '创建档案',
      subtitle: '填写宠物信息',
      component: CreateProfileTemplate,
      parentPage: 'pet-profile-detail'
    },
    'pet-registration': {
      title: '档案填写',
      subtitle: '宠物信息',
      component: PetRegistrationTemplate
    },
    'health': {
      title: '健康',
      subtitle: '记录与管理',
      component: HealthTemplate,
      parentPage: 'home'
    },
    'reminder': {
      title: '消息',
      subtitle: '提醒与通知',
      component: ReminderTemplate,
      parentPage: 'home'
    },
    'camera-test': {
      title: 'AI 相机',
      subtitle: '体验中心',
      component: CameraTestTemplate,
      parentPage: 'home'
    },
    'health-detail': {
      title: '病历详情',
      subtitle: '健康记录',
      component: HealthDetailTemplate,
      parentPage: 'health'
    },
    'travel-box-settings': {
      title: '出行箱设置',
      subtitle: '设备管理',
      component: TravelBoxSettingsTemplate,
      parentPage: 'travel-hub'
    },
    'notification-settings': {
      title: '通知设置',
      subtitle: '消息管理',
      component: NotificationSettingsTemplate,
      parentPage: 'reminder'
    },
    'travel-plan-detail': {
      title: '出行计划',
      subtitle: '准备清单',
      component: TravelPlanDetailTemplate,
      parentPage: 'travel-hub'
    },
    'life-records': {
      title: '生活记录',
      subtitle: '照片与活动',
      component: LifeRecordsTemplate,
      parentPage: 'home'
    },
    'optimized-life-records': {
      title: '优化生活记录',
      subtitle: '文件上传与管理',
      component: OptimizedLifeRecordsTemplate,
      parentPage: 'home'
    },
    'data-backup': {
      title: '数据备份',
      subtitle: '导出与恢复',
      component: DataBackupTemplate,
      parentPage: 'settings'
    },
    'habits-detail': {
      title: '日常习惯',
      subtitle: '行为分析',
      component: HabitsDetailTemplate,
      parentPage: 'pet-profile-detail'
    },
    'travel-box-wifi': {
      title: 'WiFi设置',
      subtitle: '网络连接',
      component: TravelBoxWiFiTemplate,
      parentPage: 'scenarios'
    },
    'travel-box-bluetooth': {
      title: '蓝牙设置',
      subtitle: '设备配对',
      component: TravelBoxBluetoothTemplate,
      parentPage: 'scenarios'
    },
    'travel-box-temperature': {
      title: '温度控制',
      subtitle: '温度警报',
      component: TravelBoxTemperatureTemplate,
      parentPage: 'scenarios'
    },
    'travel-box-sound': {
      title: '声音控制',
      subtitle: '音量设置',
      component: TravelBoxSoundTemplate,
      parentPage: 'scenarios'
    },
    'travel-box-fan': {
      title: '风扇控制',
      subtitle: '空气循环',
      component: TravelBoxFanTemplate,
      parentPage: 'scenarios'
    }
  };

  const navigateTo = (page: PageType) => {
    // If navigating to a nav page, reset stack
    if (pages[page].showInNav) {
      setPageStack([page]);
    } else {
      // Push to stack
      setPageStack([...pageStack, page]);
    }
  };

  const goBack = () => {
    if (pageStack.length > 1) {
      setPageStack(pageStack.slice(0, -1));
    } else {
      // If only one page, go to parent
      const parentPage = pages[currentPage].parentPage;
      if (parentPage) {
        setPageStack([parentPage]);
      }
    }
  };

  const handleCameraClick = () => {
    setShowCamera(true);
  };

  const handleCameraClose = () => {
    setShowCamera(false);
  };

  const handleCameraCapture = (mode: string, results?: any) => {
    console.log('Captured:', mode, results);
    // Could navigate to results page or save data
    // For now, just close the camera after a moment
    setTimeout(() => {
      setShowCamera(false);
    }, 500);
  };

  const currentPageConfig = pages[currentPage];
  const CurrentComponent = currentPageConfig.component;
  const isNavPage = currentPageConfig.showInNav;

  if (showOnboarding) {
    return (
      <OnboardingGuide 
        onComplete={() => setShowOnboarding(false)} 
        onNavigate={navigateTo}
      />
    );
  }

  return (
    <ScenarioContext.Provider value={{ currentScenario, setCurrentScenario }}>
      <div className="min-h-screen bg-[#424242] flex flex-col relative" style={{ maxWidth: '390px', margin: '0 auto' }}>
        {/* Phone Status Bar - Fixed */}
        <div className="fixed top-0 left-0 right-0 z-50" style={{ maxWidth: '390px', margin: '0 auto' }}>
          <PhoneStatusBar />
        </div>

      {/* Top Header - Unified Navigation Bar - Fixed */}
      {!isNavPage && (
        <div className="fixed left-0 right-0 bg-white/98 backdrop-blur-md px-5 py-3 z-40" style={{ top: '44px', maxWidth: '390px', margin: '0 auto', boxShadow: 'none', borderTop: 'none' }}>
          <div className="flex items-center justify-between gap-3">
            {/* Left: Back Button + Brand + Title */}
            <div className="flex items-center gap-3 flex-1 min-w-0">
              {/* Back Button - Yellow Circle */}
              <Button 
                variant="ghost" 
                size="sm" 
                onClick={goBack}
                className="rounded-full w-10 h-10 p-0 bg-[#FFD84D] hover:bg-[#F5C842] flex-shrink-0"
              >
                <ArrowLeft className="w-5 h-5 text-[#424242]" strokeWidth={2} />
              </Button>

              {/* Brand + Title */}
              <div className="flex items-center gap-2 flex-1 min-w-0">
                <h1 className="text-[20px] text-[#424242]" style={{ fontWeight: 700 }}>Felo</h1>
                <span className="text-body text-[#9E9E9E]">{currentPageConfig.title}</span>
              </div>
            </div>

            {/* Right: Action Buttons for specific pages */}
            {currentPage === 'pet-profile-detail' && (
              <div className="flex items-center gap-2">
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-9 w-9 p-0 rounded-md hover:bg-[#F5F5F5]"
                >
                  <div className="w-5 h-5 text-[#9E9E9E]">📤</div>
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  className="h-9 w-9 p-0 rounded-md hover:bg-[#F5F5F5]"
                >
                  <div className="w-5 h-5 text-[#9E9E9E]">✏️</div>
                </Button>
              </div>
            )}
          </div>
        </div>
      )}
      
      {/* Top Header for Nav Pages - Fixed */}
      {isNavPage && (
        <div className="fixed left-0 right-0 bg-white/98 backdrop-blur-md px-5 py-3 z-40" style={{ top: '44px', maxWidth: '390px', margin: '0 auto', boxShadow: 'none', borderTop: 'none' }}>
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-[20px] text-[#424242]" style={{ fontWeight: 700 }}>Felo</h1>
              <p className="text-caption text-[#9E9E9E]">{currentPageConfig.title}</p>
            </div>
          </div>
        </div>
      )}

      {/* App Container */}
      <div className="flex-1 bg-[#FAFAFA] flex flex-col overflow-hidden" style={{ paddingTop: '104px', paddingBottom: isNavPage ? '76px' : '32px' }}>
        {/* Main Content Area - Scrollable */}
        <div className="flex-1 overflow-y-auto px-5">
          <CurrentComponent onNavigate={navigateTo} />
        </div>
      </div>

      {/* Bottom Navigation - Fixed - Only show on nav pages */}
      {isNavPage && (
        <div className="fixed left-0 right-0 bg-white/98 backdrop-blur-md z-40" style={{ bottom: '0', maxWidth: '390px', margin: '0 auto', boxShadow: 'none', borderBottom: 'none', paddingBottom: '32px' }}>
          <div className="flex items-end justify-around px-3 py-2">
            {/* Home Tab */}
            <button
              onClick={() => navigateTo('home')}
              className={`flex flex-col items-center gap-0.5 py-2 px-3 rounded-md transition-all ${
                currentPage === 'home' 
                  ? 'bg-[#FFFBEA]' 
                  : 'hover:bg-[#F5F5F5]'
              }`}
            >
              <Home 
                className={`w-5 h-5 ${
                  currentPage === 'home' ? 'text-[#2F5233]' : 'text-[#BDBDBD]'
                }`} 
                strokeWidth={1.5} 
              />
              <span className={`text-caption ${
                currentPage === 'home' ? 'text-[#424242]' : 'text-[#9E9E9E]'
              }`}>
                今日
              </span>
            </button>

            {/* Profile Tab */}
            <button
              onClick={() => navigateTo('pet-profile-detail')}
              className={`flex flex-col items-center gap-0.5 py-2 px-3 rounded-md transition-all ${
                currentPage === 'pet-profile-detail'
                  ? 'bg-[#FFFBEA]' 
                  : 'hover:bg-[#F5F5F5]'
              }`}
            >
              <User 
                className={`w-5 h-5 ${
                  currentPage === 'pet-profile-detail' ? 'text-[#2F5233]' : 'text-[#BDBDBD]'
                }`} 
                strokeWidth={1.5} 
              />
              <span className={`text-caption ${
                currentPage === 'pet-profile-detail' ? 'text-[#424242]' : 'text-[#9E9E9E]'
              }`}>
                档案
              </span>
            </button>

            {/* AI Camera - Center Large Button */}
            <button
              onClick={handleCameraClick}
              className="relative -mt-3"
            >
              <div className="absolute inset-0 dot-grid-bg text-[#2F5233] rounded-full scale-150 opacity-10" />
              <div 
                className="w-14 h-14 rounded-full bg-[#FFD84D] hover:bg-[#F5C842] flex items-center justify-center transition-all hover:scale-105 relative"
                style={{ boxShadow: '0 2px 6px rgba(0, 0, 0, 0.08)' }}
              >
                <Camera className="w-7 h-7 text-[#424242]" strokeWidth={1.5} />
              </div>
            </button>

            {/* Scenarios Tab */}
            <button
              onClick={() => navigateTo('scenarios')}
              className={`flex flex-col items-center gap-0.5 py-2 px-3 rounded-md transition-all ${
                currentPage === 'scenarios' 
                  ? 'bg-[#FFFBEA]' 
                  : 'hover:bg-[#F5F5F5]'
              }`}
            >
              <Box 
                className={`w-5 h-5 ${
                  currentPage === 'scenarios' ? 'text-[#2F5233]' : 'text-[#BDBDBD]'
                }`} 
                strokeWidth={1.5} 
              />
              <span className={`text-caption ${
                currentPage === 'scenarios' ? 'text-[#424242]' : 'text-[#9E9E9E]'
              }`}>
                出行箱
              </span>
            </button>

            {/* Settings Tab */}
            <button
              onClick={() => navigateTo('settings')}
              className={`flex flex-col items-center gap-0.5 py-2 px-3 rounded-md transition-all ${
                currentPage === 'settings' 
                  ? 'bg-[#FFFBEA]' 
                  : 'hover:bg-[#F5F5F5]'
              }`}
            >
              <UserCircle 
                className={`w-5 h-5 ${
                  currentPage === 'settings' ? 'text-[#2F5233]' : 'text-[#BDBDBD]'
                }`} 
                strokeWidth={1.5} 
              />
              <span className={`text-caption ${
                currentPage === 'settings' ? 'text-[#424242]' : 'text-[#9E9E9E]'
              }`}>
                我的
              </span>
            </button>
          </div>
        </div>
      )}

      {/* AI Camera Interface */}
      {showCamera && (
        <AICameraInterface 
          onClose={handleCameraClose}
          onCapture={handleCameraCapture}
        />
      )}

      {/* Phone Home Indicator - Fixed */}
      <div className="fixed bottom-0 left-0 right-0 z-50" style={{ maxWidth: '390px', margin: '0 auto' }}>
        <PhoneHomeIndicator />
      </div>
    </div>
    </ScenarioContext.Provider>
  );
}