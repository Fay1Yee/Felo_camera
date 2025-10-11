import { useState } from 'react';
import {
  Database,
  Download,
  Upload,
  Clock,
  Check,
  AlertCircle,
  HardDrive,
  FileText,
  Image,
  Activity,
  Calendar,
  ChevronRight,
  Cloud,
  Smartphone,
} from 'lucide-react';
import { Button } from '../ui/button';
import { Switch } from '../ui/switch';
import { Badge } from '../ui/badge';
import { Progress } from '../ui/progress';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';
import { Checkbox } from '../ui/checkbox';

interface BackupRecord {
  id: string;
  date: Date;
  size: string;
  status: 'completed' | 'failed';
  type: 'auto' | 'manual';
  items: {
    profiles: number;
    photos: number;
    records: number;
  };
}

const mockBackupHistory: BackupRecord[] = [
  {
    id: '1',
    date: new Date('2025-09-30T02:00:00'),
    size: '45.2 MB',
    status: 'completed',
    type: 'auto',
    items: { profiles: 2, photos: 156, records: 89 },
  },
  {
    id: '2',
    date: new Date('2025-09-29T15:30:00'),
    size: '12.8 MB',
    status: 'completed',
    type: 'manual',
    items: { profiles: 2, photos: 45, records: 23 },
  },
  {
    id: '3',
    date: new Date('2025-09-28T02:00:00'),
    size: '43.1 MB',
    status: 'completed',
    type: 'auto',
    items: { profiles: 2, photos: 152, records: 86 },
  },
];

interface DataBackupTemplateProps {
  onNavigate: (page: string) => void;
}

export function DataBackupTemplate({ onNavigate }: DataBackupTemplateProps) {
  const [autoBackup, setAutoBackup] = useState(true);
  const [backupFrequency, setBackupFrequency] = useState('daily');
  const [backupLocation, setBackupLocation] = useState('cloud');
  const [isExporting, setIsExporting] = useState(false);

  // Data selection for export
  const [exportSelection, setExportSelection] = useState({
    profiles: true,
    health: true,
    photos: true,
    travel: true,
    reminders: true,
    aiRecords: true,
  });

  // Storage usage (mock data)
  const storageUsage = {
    total: 2048, // MB
    used: 487.3, // MB
    breakdown: [
      { type: 'photos', label: '照片', size: 234.5, icon: Image, color: '#FFD84D' },
      { type: 'profiles', label: '档案', size: 12.3, icon: FileText, color: '#4CAF50' },
      { type: 'health', label: '健康记录', size: 156.8, icon: Activity, color: '#42A5F5' },
      { type: 'travel', label: '出行数据', size: 45.2, icon: Calendar, color: '#FFB300' },
      { type: 'other', label: '其他', size: 38.5, icon: Database, color: '#90A4AE' },
    ],
  };

  const handleExport = async () => {
    setIsExporting(true);
    // Simulate export
    await new Promise(resolve => setTimeout(resolve, 2000));
    setIsExporting(false);
    console.log('Export completed:', exportSelection);
  };

  const handleBackupNow = async () => {
    console.log('Manual backup initiated');
    // Add backup logic
  };

  const handleRestore = (backupId: string) => {
    console.log('Restore backup:', backupId);
    // Add restore logic
  };

  const percentageUsed = (storageUsage.used / storageUsage.total) * 100;

  return (
    <div className="pb-6">
      {/* Storage Usage Card */}
      <div className="bg-white rounded-3xl p-6 mb-6 mt-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 rounded-2xl bg-[#FFF8E1] flex items-center justify-center">
            <HardDrive className="w-6 h-6 text-[#2F5233]" strokeWidth={1.5} />
          </div>
          <div>
            <h3 className="text-[#37474F]">存储空间</h3>
            <p className="text-caption text-[#78909C]">
              已使用 {storageUsage.used.toFixed(1)} MB / {storageUsage.total} MB
            </p>
          </div>
        </div>

        <div className="mb-4">
          <Progress value={percentageUsed} className="h-3 bg-[#F5F5F0]" />
        </div>

        <div className="space-y-3">
          {storageUsage.breakdown.map((item) => {
            const ItemIcon = item.icon;
            const percentage = (item.size / storageUsage.used) * 100;
            return (
              <div key={item.type} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div
                    className="w-8 h-8 rounded-xl flex items-center justify-center"
                    style={{ backgroundColor: `${item.color}20` }}
                  >
                    <ItemIcon className="w-4 h-4" style={{ color: item.color }} strokeWidth={1.5} />
                  </div>
                  <span className="text-caption text-[#546E7A]">{item.label}</span>
                </div>
                <div className="text-right">
                  <div className="text-caption text-[#37474F]">{item.size.toFixed(1)} MB</div>
                  <div className="text-[10px] text-[#90A4AE]">{percentage.toFixed(0)}%</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Auto Backup Settings */}
      <div className="bg-white rounded-3xl p-6 mb-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 rounded-2xl bg-[#E8F5E9] flex items-center justify-center">
            <Cloud className="w-6 h-6 text-[#2F5233]" strokeWidth={1.5} />
          </div>
          <div className="flex-1">
            <h3 className="text-[#37474F]">自动备份</h3>
            <p className="text-caption text-[#78909C]">定期保护数据</p>
          </div>
          <Switch checked={autoBackup} onCheckedChange={setAutoBackup} />
        </div>

        {autoBackup && (
          <div className="space-y-4 pl-[60px]">
            <div>
              <label className="text-caption text-[#78909C] mb-2 block">备份频率</label>
              <Select value={backupFrequency} onValueChange={setBackupFrequency}>
                <SelectTrigger className="w-full rounded-2xl border-gray-200 h-12">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="daily">每日备份</SelectItem>
                  <SelectItem value="weekly">每周备份</SelectItem>
                  <SelectItem value="monthly">每月备份</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-caption text-[#78909C] mb-2 block">备份位置</label>
              <Select value={backupLocation} onValueChange={setBackupLocation}>
                <SelectTrigger className="w-full rounded-2xl border-gray-200 h-12">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="cloud">云端存储</SelectItem>
                  <SelectItem value="local">本地设备</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="pt-2">
              <Button
                onClick={handleBackupNow}
                className="w-full rounded-2xl bg-[#FFD84D] hover:bg-[#FFC107] text-[#37474F] border-none"
              >
                <Upload className="w-4 h-4 mr-2" strokeWidth={1.5} />
                立即备份
              </Button>
            </div>
          </div>
        )}
      </div>

      {/* Export Data Section */}
      <div className="bg-white rounded-3xl p-6 mb-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-12 h-12 rounded-2xl bg-[#FFF8E1] flex items-center justify-center">
            <Download className="w-6 h-6 text-[#2F5233]" strokeWidth={1.5} />
          </div>
          <div>
            <h3 className="text-[#37474F]">导出数据</h3>
            <p className="text-caption text-[#78909C]">选择要导出的内容</p>
          </div>
        </div>

        <div className="space-y-4">
          {[
            { key: 'profiles', label: '宠物档案', icon: FileText },
            { key: 'health', label: '健康记录', icon: Activity },
            { key: 'photos', label: '相册照片', icon: Image },
            { key: 'travel', label: '出行数据', icon: Calendar },
            { key: 'reminders', label: '提醒设置', icon: Clock },
            { key: 'aiRecords', label: 'AI 识别记录', icon: Database },
          ].map(({ key, label, icon: Icon }) => (
            <div
              key={key}
              className="flex items-center justify-between p-4 rounded-2xl hover:bg-[#F5F5F0] transition-colors cursor-pointer"
              onClick={() =>
                setExportSelection({
                  ...exportSelection,
                  [key]: !exportSelection[key as keyof typeof exportSelection],
                })
              }
            >
              <div className="flex items-center gap-3">
                <Icon className="w-5 h-5 text-[#90A4AE]" strokeWidth={1.5} />
                <span className="text-[#546E7A]">{label}</span>
              </div>
              <Checkbox
                checked={exportSelection[key as keyof typeof exportSelection]}
                onCheckedChange={(checked) =>
                  setExportSelection({
                    ...exportSelection,
                    [key]: checked as boolean,
                  })
                }
              />
            </div>
          ))}
        </div>

        <div className="mt-6">
          <Button
            onClick={handleExport}
            disabled={isExporting || !Object.values(exportSelection).some(Boolean)}
            className="w-full rounded-2xl bg-[#2F5233] hover:bg-[#1F3823] text-white border-none disabled:opacity-50"
          >
            {isExporting ? (
              <>
                <Clock className="w-4 h-4 mr-2 animate-spin" strokeWidth={1.5} />
                导出中...
              </>
            ) : (
              <>
                <Download className="w-4 h-4 mr-2" strokeWidth={1.5} />
                导出选中数据
              </>
            )}
          </Button>
          <p className="text-caption text-[#90A4AE] text-center mt-3">
            数据将以 JSON 格式导出
          </p>
        </div>
      </div>

      {/* Backup History */}
      <div className="bg-white rounded-3xl p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-[#37474F]">备份历史</h3>
            <p className="text-caption text-[#78909C]">最近的备份记录</p>
          </div>
          <Badge className="bg-[#E8F5E9] text-[#2F5233] border-none">
            {mockBackupHistory.length} 条
          </Badge>
        </div>

        <div className="space-y-3">
          {mockBackupHistory.map((backup) => (
            <div
              key={backup.id}
              className="border border-gray-200 rounded-2xl p-4 hover:bg-[#F5F5F0] transition-colors"
            >
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-3">
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center ${
                      backup.status === 'completed'
                        ? 'bg-[#E8F5E9]'
                        : 'bg-red-50'
                    }`}
                  >
                    {backup.status === 'completed' ? (
                      <Check className="w-5 h-5 text-[#4CAF50]" strokeWidth={1.5} />
                    ) : (
                      <AlertCircle className="w-5 h-5 text-[#EF5350]" strokeWidth={1.5} />
                    )}
                  </div>
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-[#37474F]">{backup.size}</span>
                      <Badge
                        variant="outline"
                        className={`text-[10px] px-2 py-0.5 ${
                          backup.type === 'auto'
                            ? 'border-[#90A4AE] text-[#78909C]'
                            : 'border-[#FFD84D] text-[#2F5233] bg-[#FFF8E1]'
                        }`}
                      >
                        {backup.type === 'auto' ? '自动' : '手动'}
                      </Badge>
                    </div>
                    <div className="flex items-center gap-2 text-caption text-[#78909C]">
                      <Clock className="w-3 h-3" strokeWidth={1.5} />
                      {backup.date.toLocaleString('zh-CN', {
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between pl-[52px]">
                <div className="flex gap-4 text-caption text-[#90A4AE]">
                  <span>{backup.items.profiles} 档案</span>
                  <span>{backup.items.photos} 照片</span>
                  <span>{backup.items.records} 记录</span>
                </div>
                {backup.status === 'completed' && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleRestore(backup.id)}
                    className="rounded-xl text-[#2F5233] h-8"
                  >
                    恢复
                  </Button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Tips */}
      <div className="mt-6 bg-[#FFF8E1] rounded-2xl p-4">
        <div className="flex gap-3">
          <AlertCircle className="w-5 h-5 text-[#FFB300] flex-shrink-0 mt-0.5" strokeWidth={1.5} />
          <div className="text-caption text-[#2F5233]">
            <p className="mb-1">提示：</p>
            <ul className="space-y-1 pl-4 list-disc">
              <li>建议定期备份重要数据</li>
              <li>导出的数据可用于迁移到新设备</li>
              <li>云端备份需要网络连接</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}