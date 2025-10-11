import { useState } from 'react';
import { Card } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Badge } from '../ui/badge';
import { Textarea } from '../ui/textarea';
import { 
  Camera, 
  Upload, 
  X, 
  ChevronRight,
  Calendar as CalendarIcon,
  FileText,
  CreditCard,
  Video
} from 'lucide-react';
import { Calendar } from '../ui/calendar';
import { Popover, PopoverContent, PopoverTrigger } from '../ui/popover';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';

interface CreateProfileTemplateProps {
  onNavigate: (page: any) => void;
}

export function CreateProfileTemplate({ onNavigate }: CreateProfileTemplateProps) {
  const [date, setDate] = useState<Date>();
  const [selectedTags, setSelectedTags] = useState<string[]>(['猫粮过敏']);
  const [sex, setSex] = useState<'male' | 'female' | null>('female');
  const [neutered, setNeutered] = useState<boolean>(true);

  const healthTags = [
    '猫粮过敏', '肠胃敏感', '心脏病史', '皮肤过敏', 
    '关节问题', '无已知疾病'
  ];

  const toggleTag = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter(t => t !== tag));
    } else {
      setSelectedTags([...selectedTags, tag]);
    }
  };

  return (
    <div className="pb-8">
      {/* Form Section */}
      <div className="space-y-6 pt-6">
        {/* Pet Name */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">宠物名字</Label>
          <Input 
            placeholder="例如：Momo" 
            className="border-gray-200 rounded-2xl bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D] focus:ring-2 focus:ring-offset-0"
            defaultValue="Momo"
          />
        </Card>

        {/* Species & Breed */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">物种 & 品种</Label>
          <div className="space-y-3">
            <Select defaultValue="cat">
              <SelectTrigger className="rounded-2xl border-gray-200 bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D]">
                <SelectValue placeholder="选择物种" />
              </SelectTrigger>
              <SelectContent className="rounded-2xl">
                <SelectItem value="cat">猫咪 🐱</SelectItem>
                <SelectItem value="dog">狗狗 🐶</SelectItem>
                <SelectItem value="rabbit">兔子 🐰</SelectItem>
                <SelectItem value="hamster">仓鼠 🐹</SelectItem>
              </SelectContent>
            </Select>
            
            <Select defaultValue="british">
              <SelectTrigger className="rounded-2xl border-gray-200 bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D]">
                <SelectValue placeholder="选择品种" />
              </SelectTrigger>
              <SelectContent className="rounded-2xl">
                <SelectItem value="british">英国短毛猫</SelectItem>
                <SelectItem value="persian">波斯猫</SelectItem>
                <SelectItem value="ragdoll">布偶猫</SelectItem>
                <SelectItem value="siamese">暹罗猫</SelectItem>
                <SelectItem value="mixed">混种</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </Card>

        {/* Birthdate */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">出生日期</Label>
          <Popover>
            <PopoverTrigger asChild>
              <Button 
                variant="outline" 
                className="w-full justify-start text-left rounded-2xl border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]"
              >
                <CalendarIcon className="mr-2 h-4 w-4" strokeWidth={1.5} />
                {date ? date.toLocaleDateString('zh-CN') : '选择日期'}
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0 rounded-2xl" align="start">
              <Calendar
                mode="single"
                selected={date}
                onSelect={setDate}
                initialFocus
                className="rounded-2xl"
              />
            </PopoverContent>
          </Popover>
        </Card>

        {/* Sex & Neuter Status */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">性别 & 绝育状态</Label>
          
          <div className="space-y-4">
            <div className="flex gap-3">
              <Button
                variant={sex === 'male' ? 'default' : 'outline'}
                onClick={() => setSex('male')}
                className={`flex-1 rounded-full ${
                  sex === 'male' 
                    ? 'bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none' 
                    : 'border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]'
                }`}
              >
                公
              </Button>
              <Button
                variant={sex === 'female' ? 'default' : 'outline'}
                onClick={() => setSex('female')}
                className={`flex-1 rounded-full ${
                  sex === 'female' 
                    ? 'bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none' 
                    : 'border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]'
                }`}
              >
                母
              </Button>
            </div>

            <div className="dot-divider text-gray-300" />

            <div className="flex gap-3">
              <Button
                variant={neutered ? 'default' : 'outline'}
                onClick={() => setNeutered(true)}
                className={`flex-1 rounded-full ${
                  neutered 
                    ? 'bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none' 
                    : 'border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]'
                }`}
              >
                已绝育
              </Button>
              <Button
                variant={!neutered ? 'default' : 'outline'}
                onClick={() => setNeutered(false)}
                className={`flex-1 rounded-full ${
                  !neutered 
                    ? 'bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none' 
                    : 'border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA]'
                }`}
              >
                未绝育
              </Button>
            </div>
          </div>
        </Card>

        {/* Health History & Allergies */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">健康史 & 过敏信息</Label>
          <p className="text-caption text-gray-400 mb-4">选择所有适用项</p>
          
          <div className="flex flex-wrap gap-2">
            {healthTags.map((tag) => (
              <Badge
                key={tag}
                variant={selectedTags.includes(tag) ? 'default' : 'outline'}
                onClick={() => toggleTag(tag)}
                className={`cursor-pointer rounded-full px-4 py-2 transition-all ${
                  selectedTags.includes(tag)
                    ? 'bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none'
                    : 'border-gray-200 hover:border-[#FFD84D] hover:bg-[#FFFBEA] text-gray-600'
                }`}
              >
                {tag}
                {selectedTags.includes(tag) && (
                  <X className="ml-1 h-3 w-3" strokeWidth={2} />
                )}
              </Badge>
            ))}
          </div>
        </Card>

        {/* Diet & Daily Routine */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">饮食 & 日常习惯</Label>
          <Textarea 
            placeholder="例如：每日两餐，早8点晚6点，喜欢鸡肉味猫粮..." 
            className="min-h-[100px] border-gray-200 rounded-2xl bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D] resize-none"
          />
        </Card>

        {/* Emergency Contact */}
        <Card className="p-6 border border-gray-100 shadow-none">
          <Label className="text-body text-gray-700 mb-3 block">紧急联系人</Label>
          <div className="space-y-3">
            <Input 
              placeholder="联系人姓名" 
              className="border-gray-200 rounded-2xl bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D]"
            />
            <Input 
              placeholder="手机号码" 
              type="tel"
              className="border-gray-200 rounded-2xl bg-white focus:border-[#FFD84D] focus:ring-[#FFD84D]"
            />
          </div>
        </Card>

        {/* Upload Section */}
        <Card className="p-6 border-2 border-dashed border-gray-200 shadow-none hover:border-[#FFD84D] hover:bg-[#FFFBEA] transition-all">
          <div className="text-center space-y-4">
            <div className="inline-flex w-16 h-16 rounded-full bg-[#FFFBEA] items-center justify-center">
              <Upload className="w-7 h-7 text-gray-700" strokeWidth={1.5} />
            </div>
            
            <div>
              <h3 className="text-body text-gray-700 mb-2">上传文件</h3>
              <p className="text-caption text-gray-400">点击上传疫苗本、芯片证书、照片或视频</p>
            </div>

            <div className="grid grid-cols-2 gap-3 pt-2">
              <Button 
                variant="outline" 
                className="rounded-2xl border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <FileText className="w-4 h-4 mr-2" strokeWidth={1.5} />
                疫苗本
              </Button>
              <Button 
                variant="outline" 
                className="rounded-2xl border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <CreditCard className="w-4 h-4 mr-2" strokeWidth={1.5} />
                芯片证书
              </Button>
              <Button 
                variant="outline" 
                className="rounded-2xl border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <Camera className="w-4 h-4 mr-2" strokeWidth={1.5} />
                宠物照片
              </Button>
              <Button 
                variant="outline" 
                className="rounded-2xl border-gray-200 hover:border-[#FFD84D] hover:bg-white"
              >
                <Video className="w-4 h-4 mr-2" strokeWidth={1.5} />
                短视频
              </Button>
            </div>
          </div>
        </Card>

        {/* CTA Button - Full Width with Dot Pattern */}
        <div className="relative">
          <div className="absolute inset-0 dot-grid-bg text-gray-900 rounded-full" />
          <Button 
            onClick={() => onNavigate('profile')}
            className="w-full rounded-full bg-[#FFD84D] hover:bg-[#FFC700] text-gray-900 border-none h-14 relative"
          >
            继续
            <ChevronRight className="ml-2 h-5 w-5" strokeWidth={1.5} />
          </Button>
        </div>
      </div>
    </div>
  );
}