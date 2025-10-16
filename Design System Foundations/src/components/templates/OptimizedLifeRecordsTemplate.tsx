import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';
import { 
  ArrowLeft,
  Camera, 
  Upload,
  FileText,
  Image as ImageIcon,
  Activity,
  CloudUpload,
  CheckCircle,
  AlertCircle,
  Clock,
  Timer,
  Play,
  Moon,
  MousePointer,
  Images,
  Video,
  FileImage,
  File,
  Table,
  Heart,
  X,
  Plus
} from 'lucide-react';

interface OptimizedLifeRecordsTemplateProps {
  onNavigate: (page: string) => void;
}

export function OptimizedLifeRecordsTemplate({ onNavigate }: OptimizedLifeRecordsTemplateProps) {
  const [isUploading, setIsUploading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('photos');

  const handleFileUpload = async () => {
    setIsUploading(true);
    setUploadStatus('正在选择文件...');

    // 模拟文件上传过程
    setTimeout(() => {
      setUploadStatus('正在处理文件...');
    }, 1000);

    setTimeout(() => {
      setUploadStatus('成功导入 15 条记录！');
      setTimeout(() => {
        setIsUploading(false);
        setUploadStatus(null);
      }, 2000);
    }, 3000);
  };

  const supportedFormats = [
    { icon: FileText, name: 'JSON', desc: '结构化数据文件' },
    { icon: File, name: 'TXT', desc: '纯文本文件' },
    { icon: Table, name: 'CSV', desc: '表格数据文件' },
    { icon: FileText, name: 'DOCX', desc: 'Word文档' },
    { icon: File, name: 'DOC', desc: '旧版Word文档' },
  ];

  const mockPhotos = Array.from({ length: 6 }, (_, i) => ({
    id: i + 1,
    url: `https://images.unsplash.com/photo-${1600000000000 + i * 100000}?w=200&h=200&fit=crop`,
    timestamp: new Date(Date.now() - i * 3600000),
  }));

  const mockActivities = Array.from({ length: 5 }, (_, i) => ({
    id: i + 1,
    name: `散步活动 ${i + 1}`,
    time: `${new Date().getHours() - i}:00`,
    duration: '30分钟',
  }));

  const activityStats = [
    { title: '运动时长', value: '2.5小时', icon: Timer, color: 'text-green-600' },
    { title: '活动次数', value: '8次', icon: Play, color: 'text-blue-600' },
    { title: '休息时间', value: '6小时', icon: Moon, color: 'text-purple-600' },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between p-4">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onNavigate('home')}
              className="p-2"
            >
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <div>
              <h1 className="text-xl font-semibold text-gray-900">生活记录</h1>
              <p className="text-sm text-gray-500">照片与活动数据</p>
            </div>
          </div>
          <div className="w-12 h-12 bg-gradient-to-br from-blue-100 to-purple-100 rounded-full flex items-center justify-center">
            <Heart className="w-6 h-6 text-blue-600" />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b border-gray-200">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-3 bg-transparent border-0 h-auto p-0">
            <TabsTrigger 
              value="photos" 
              className="data-[state=active]:bg-transparent data-[state=active]:border-b-2 data-[state=active]:border-blue-600 data-[state=active]:text-blue-600 rounded-none py-4 px-6 text-gray-600 font-medium"
            >
              照片记录
            </TabsTrigger>
            <TabsTrigger 
              value="activities" 
              className="data-[state=active]:bg-transparent data-[state=active]:border-b-2 data-[state=active]:border-blue-600 data-[state=active]:text-blue-600 rounded-none py-4 px-6 text-gray-600 font-medium"
            >
              活动记录
            </TabsTrigger>
            <TabsTrigger 
              value="import" 
              className="data-[state=active]:bg-transparent data-[state=active]:border-b-2 data-[state=active]:border-blue-600 data-[state=active]:text-blue-600 rounded-none py-4 px-6 text-gray-600 font-medium"
            >
              数据导入
            </TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      {/* Content */}
      <div className="p-4">
        <Tabs value={activeTab} className="w-full">
          {/* 照片记录 */}
          <TabsContent value="photos" className="mt-0 space-y-6">
            {/* 快速上传区域 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">快速上传</h3>
              <div className="grid grid-cols-2 gap-3">
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2 border-2 border-dashed border-blue-300 hover:border-blue-500 hover:bg-blue-50"
                  onClick={() => {/* TODO: 实现拍照功能 */}}
                >
                  <Camera className="w-6 h-6 text-blue-600" />
                  <span className="text-sm font-medium text-blue-600">拍照</span>
                </Button>
                <Button
                  variant="outline"
                  className="h-20 flex-col gap-2 border-2 border-dashed border-purple-300 hover:border-purple-500 hover:bg-purple-50"
                  onClick={() => {/* TODO: 实现相册选择功能 */}}
                >
                  <Images className="w-6 h-6 text-purple-600" />
                  <span className="text-sm font-medium text-purple-600">相册</span>
                </Button>
              </div>
            </Card>

            {/* 最近照片 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">最近照片</h3>
              <div className="grid grid-cols-3 gap-2">
                {mockPhotos.map((photo) => (
                  <div
                    key={photo.id}
                    className="aspect-square bg-gray-100 rounded-lg flex items-center justify-center"
                  >
                    <ImageIcon className="w-8 h-8 text-gray-400" />
                  </div>
                ))}
              </div>
            </Card>
          </TabsContent>

          {/* 活动记录 */}
          <TabsContent value="activities" className="mt-0 space-y-6">
            {/* 活动统计 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">今日活动统计</h3>
              <div className="grid grid-cols-3 gap-4">
                {activityStats.map((stat, index) => (
                  <div key={index} className="text-center">
                    <div className="w-12 h-12 mx-auto mb-2 bg-gray-100 rounded-full flex items-center justify-center">
                      <stat.icon className={`w-6 h-6 ${stat.color}`} />
                    </div>
                    <div className={`text-lg font-bold ${stat.color}`}>{stat.value}</div>
                    <div className="text-xs text-gray-500">{stat.title}</div>
                  </div>
                ))}
              </div>
            </Card>

            {/* 最近活动 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">最近活动</h3>
              <div className="space-y-3">
                {mockActivities.map((activity) => (
                  <div key={activity.id} className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg">
                    <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                      <Activity className="w-5 h-5 text-blue-600" />
                    </div>
                    <div className="flex-1">
                      <div className="font-medium text-gray-900">{activity.name}</div>
                      <div className="text-sm text-gray-500">{activity.time} - 持续{activity.duration}</div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </TabsContent>

          {/* 数据导入 */}
          <TabsContent value="import" className="mt-0 space-y-6">
            {/* 主要上传区域 */}
            <Card className={`p-8 bg-white border-2 rounded-xl transition-all duration-300 ${
              isUploading ? 'border-blue-500 shadow-lg' : 'border-gray-200'
            }`}>
              <div className="text-center">
                {/* 上传图标 */}
                <div className="w-20 h-20 mx-auto mb-6 bg-blue-100 rounded-full flex items-center justify-center">
                  {isUploading ? (
                    <CloudUpload className="w-10 h-10 text-blue-600 animate-pulse" />
                  ) : (
                    <Upload className="w-10 h-10 text-blue-600" />
                  )}
                </div>

                {/* 标题和状态 */}
                <h3 className="text-2xl font-bold text-gray-900 mb-2">
                  {isUploading ? '正在上传...' : '上传宠物活动数据'}
                </h3>
                <p className="text-gray-500 mb-8">
                  {uploadStatus || '支持 JSON、TXT、CSV、DOCX、DOC 格式文件'}
                </p>

                {/* 上传按钮或进度 */}
                {!isUploading ? (
                  <>
                    <Button
                      onClick={handleFileUpload}
                      className="w-full h-14 text-lg font-semibold bg-blue-600 hover:bg-blue-700 mb-4"
                    >
                      <Upload className="w-5 h-5 mr-2" />
                      选择文件上传
                    </Button>

                    {/* 分隔线 */}
                    <div className="flex items-center gap-4 my-6">
                      <div className="flex-1 h-px bg-gray-200"></div>
                      <span className="text-sm text-gray-500">或者</span>
                      <div className="flex-1 h-px bg-gray-200"></div>
                    </div>

                    {/* 拖拽区域 */}
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 bg-gray-50">
                      <MousePointer className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                      <p className="text-gray-500 font-medium">拖拽文件到此处上传</p>
                    </div>
                  </>
                ) : (
                  <div className="flex items-center justify-center">
                    <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin"></div>
                  </div>
                )}
              </div>
            </Card>

            {/* 支持的文件格式 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">支持的文件格式</h3>
              <div className="space-y-3">
                {supportedFormats.map((format, index) => (
                  <div key={index} className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                      <format.icon className="w-5 h-5 text-blue-600" />
                    </div>
                    <div>
                      <div className="font-medium text-gray-900">{format.name}</div>
                      <div className="text-sm text-gray-500">{format.desc}</div>
                    </div>
                  </div>
                ))}
              </div>
            </Card>

            {/* 导入历史 */}
            <Card className="p-6 bg-white border border-gray-200 rounded-xl">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">导入历史</h3>
              <div className="text-center py-8">
                <FileText className="w-12 h-12 mx-auto mb-3 text-gray-300" />
                <p className="text-gray-500">暂无导入记录</p>
              </div>
            </Card>
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}