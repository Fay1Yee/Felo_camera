import { useState } from "react";
import { Card } from "../ui/card";
import { Button } from "../ui/button";
import { Input } from "../ui/input";
import { Label } from "../ui/label";
import { Textarea } from "../ui/textarea";
import { Badge } from "../ui/badge";
import {
  Calendar,
  Upload,
  FileText,
  Syringe,
  AlertCircle,
  Camera,
} from "lucide-react";

interface PetRegistrationTemplateProps {
  onNavigate: (page: any) => void;
}

export function PetRegistrationTemplate({
  onNavigate,
}: PetRegistrationTemplateProps) {
  const [petName, setPetName] = useState("");
  const [species, setSpecies] = useState("");
  const [breed, setBreed] = useState("");
  const [gender, setGender] = useState("");
  const [neutered, setNeutered] = useState("");
  const [birthDate, setBirthDate] = useState("");
  const [selectedHabits, setSelectedHabits] = useState<
    string[]
  >([]);
  const [personality, setPersonality] = useState("");
  const [diet, setDiet] = useState("");
  const [emergencyContact, setEmergencyContact] = useState("");
  const [phone, setPhone] = useState("");

  const habitOptions = [
    "吃好饭",
    "早起床",
    "睡好觉",
    "爱运动",
    "爱撒娇",
  ];

  const toggleHabit = (habit: string) => {
    if (selectedHabits.includes(habit)) {
      setSelectedHabits(
        selectedHabits.filter((h) => h !== habit),
      );
    } else {
      setSelectedHabits([...selectedHabits, habit]);
    }
  };

  const handleSubmit = () => {
    // Save data and navigate
    console.log("Submitting pet registration...");
    onNavigate("home");
  };

  return (
    <div className="pb-6 pt-5 space-y-4">
      {/* Pet Name */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          宠物名字
        </Label>
        <Input
          value={petName}
          onChange={(e) => setPetName(e.target.value)}
          placeholder="Name"
          className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
        />
      </div>

      {/* Species & Breed */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          物种 & 品种
        </Label>
        <div className="grid grid-cols-2 gap-2">
          <Input
            value={species}
            onChange={(e) => setSpecies(e.target.value)}
            placeholder="宠物"
            className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
          />
          <Input
            value={breed}
            onChange={(e) => setBreed(e.target.value)}
            placeholder="品种选择"
            className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
          />
        </div>
      </div>

      {/* Birth Date */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          出生日期
        </Label>
        <div className="relative">
          <Input
            type="date"
            value={birthDate}
            onChange={(e) => setBirthDate(e.target.value)}
            placeholder="选择日期"
            className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 pr-11 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
          />
          <Calendar
            className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-[#BDBDBD] pointer-events-none"
            strokeWidth={1.5}
          />
        </div>
      </div>

      {/* Gender & Neutered Status */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          性别 & 绝育状态
        </Label>
        <div className="grid grid-cols-4 gap-2">
          <Button
            onClick={() => setGender("公")}
            variant="outline"
            className={`h-12 rounded-md border transition-all ${
              gender === "公"
                ? "bg-[#FFD84D] border-[#FFD84D] text-[#424242] hover:bg-[#F5C842]"
                : "bg-white border-[#E0E0E0] text-[#9E9E9E] hover:bg-[#F5F5F5]"
            }`}
          >
            公
          </Button>
          <Button
            onClick={() => setGender("母")}
            variant="outline"
            className={`h-12 rounded-md border transition-all ${
              gender === "母"
                ? "bg-[#FFD84D] border-[#FFD84D] text-[#424242] hover:bg-[#F5C842]"
                : "bg-white border-[#E0E0E0] text-[#9E9E9E] hover:bg-[#F5F5F5]"
            }`}
          >
            母
          </Button>
          <Button
            onClick={() => setNeutered("已绝育")}
            variant="outline"
            className={`h-12 rounded-md border transition-all ${
              neutered === "已绝育"
                ? "bg-[#FFD84D] border-[#FFD84D] text-[#424242] hover:bg-[#F5C842]"
                : "bg-white border-[#E0E0E0] text-[#9E9E9E] hover:bg-[#F5F5F5]"
            }`}
            style={{ fontSize: "13px" }}
          >
            已绝育
          </Button>
          <Button
            onClick={() => setNeutered("未绝育")}
            variant="outline"
            className={`h-12 rounded-md border transition-all ${
              neutered === "未绝育"
                ? "bg-[#FFD84D] border-[#FFD84D] text-[#424242] hover:bg-[#F5C842]"
                : "bg-white border-[#E0E0E0] text-[#9E9E9E] hover:bg-[#F5F5F5]"
            }`}
            style={{ fontSize: "13px" }}
          >
            未绝育
          </Button>
        </div>
      </div>

      {/* Personality & Interests */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          性格 & 兴趣爱好
        </Label>
        <div className="flex flex-wrap gap-2 mb-2">
          {habitOptions.map((habit) => (
            <Badge
              key={habit}
              onClick={() => toggleHabit(habit)}
              className={`px-3 py-1.5 rounded-full border cursor-pointer transition-all ${
                selectedHabits.includes(habit)
                  ? "bg-[#FFD84D] text-[#424242] border-[#FFD84D] hover:bg-[#F5C842]"
                  : "bg-white text-[#9E9E9E] border-[#E0E0E0] hover:bg-[#FFFBEA]"
              }`}
              style={{ fontSize: "13px", fontWeight: 400 }}
            >
              {habit}
            </Badge>
          ))}
        </div>
        <Textarea
          value={personality}
          onChange={(e) => setPersonality(e.target.value)}
          placeholder="描述宠物的性格特点和兴趣爱好"
          className="min-h-[100px] bg-white border border-[#E0E0E0] rounded-md px-4 py-3 text-body placeholder:text-[#BDBDBD] resize-none focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
        />
      </div>

      {/* Diet & Precautions */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          饮食 & 注意事项
        </Label>
        <Textarea
          value={diet}
          onChange={(e) => setDiet(e.target.value)}
          placeholder="饮食习惯、过敏源、喂养时间、营养补剂摄取等"
          className="min-h-[100px] bg-white border border-[#E0E0E0] rounded-md px-4 py-3 text-body placeholder:text-[#BDBDBD] resize-none focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
        />
      </div>

      {/* Emergency Contact */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          紧急联系人
        </Label>
        <Input
          value={emergencyContact}
          onChange={(e) => setEmergencyContact(e.target.value)}
          placeholder="联系人及关系"
          className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
        />
      </div>

      {/* Phone Number */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          手机号码
        </Label>
        <Input
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          placeholder="联系电话"
          type="tel"
          className="h-12 bg-white border border-[#E0E0E0] rounded-md px-4 text-body placeholder:text-[#BDBDBD] focus:border-[#FFD84D] focus:ring-1 focus:ring-[#FFD84D] transition-all"
        />
      </div>

      {/* Upload Section */}
      <div className="space-y-2">
        <Label className="text-caption text-[#9E9E9E] px-1">
          上传文件
        </Label>
        <Card className="p-6 bg-white border-2 border-dashed border-[#E0E0E0] hover:border-[#FFD84D] transition-all cursor-pointer">
          <div className="flex flex-col items-center justify-center text-center">
            <div className="w-12 h-12 rounded-full bg-[#FFF9E6] flex items-center justify-center mb-3">
              <Upload
                className="w-6 h-6 text-[#9E9E9E]"
                strokeWidth={1.5}
              />
            </div>
            <p className="text-body text-[#424242] mb-1">
              上传文件
            </p>
            <p className="text-caption text-[#BDBDBD]">
              点击上传宠物证、芯片证、疫苗证等证件照
            </p>
          </div>
        </Card>
      </div>

      {/* Document Upload Options */}
      <div className="grid grid-cols-4 gap-2">
        <button className="flex flex-col items-center gap-2 p-3 rounded-md bg-white border border-[#E0E0E0] hover:border-[#FFD84D] hover:bg-[#FFFBEA] transition-all">
          <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
            <FileText
              className="w-5 h-5 text-[#9E9E9E]"
              strokeWidth={1.5}
            />
          </div>
          <span className="text-caption text-[#9E9E9E]">
            电商证
          </span>
        </button>
        <button className="flex flex-col items-center gap-2 p-3 rounded-md bg-white border border-[#E0E0E0] hover:border-[#FFD84D] hover:bg-[#FFFBEA] transition-all">
          <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
            <Camera
              className="w-5 h-5 text-[#9E9E9E]"
              strokeWidth={1.5}
            />
          </div>
          <span className="text-caption text-[#9E9E9E]">
            芯片证
          </span>
        </button>
        <button className="flex flex-col items-center gap-2 p-3 rounded-md bg-white border border-[#E0E0E0] hover:border-[#FFD84D] hover:bg-[#FFFBEA] transition-all">
          <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
            <Syringe
              className="w-5 h-5 text-[#9E9E9E]"
              strokeWidth={1.5}
            />
          </div>
          <span className="text-caption text-[#9E9E9E]">
            疫苗证
          </span>
        </button>
        <button className="flex flex-col items-center gap-2 p-3 rounded-md bg-white border border-[#E0E0E0] hover:border-[#FFD84D] hover:bg-[#FFFBEA] transition-all">
          <div className="w-10 h-10 rounded-md bg-[#F5F5F5] flex items-center justify-center">
            <AlertCircle
              className="w-5 h-5 text-[#9E9E9E]"
              strokeWidth={1.5}
            />
          </div>
          <span className="text-caption text-[#9E9E9E]">
            其他
          </span>
        </button>
      </div>

      {/* Submit Button */}
      <div className="pt-2">
        <Button
          onClick={handleSubmit}
          className="w-full h-14 rounded-md bg-[#FFD84D] hover:bg-[#F5C842] text-[#424242] border-none"
          style={{
            boxShadow: "0 2px 6px rgba(255, 216, 77, 0.3)",
            fontWeight: 600,
            fontSize: "16px",
          }}
        >
          提交
        </Button>
      </div>
    </div>
  );
}