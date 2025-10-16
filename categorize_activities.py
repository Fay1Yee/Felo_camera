#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import sys
import re
from collections import defaultdict
from datetime import datetime

def parse_raw_document(content):
    """直接解析原始文档内容"""
    events = []
    
    # 使用正则表达式提取时间戳、类别、置信度和原因
    pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})([a-z_]+)([\d.]+)```json\s*\{\s*"category":\s*"([^"]+)",\s*"confidence":\s*([\d.]+),\s*"reasons":\s*"([^"]+)"\s*\}'
    
    matches = re.findall(pattern, content, re.DOTALL)
    
    for match in matches:
        timestamp, category_en, confidence_raw, category_cn, confidence, reasons = match
        
        # 格式化时间戳
        try:
            dt = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")
            formatted_timestamp = dt.isoformat()
        except:
            formatted_timestamp = timestamp
        
        # 创建事件对象
        event = {
            "timestamp": formatted_timestamp,
            "title": f"{category_cn}行为",
            "content": reasons,
            "category": category_en,
            "confidence": float(confidence),
            "metadata": {
                "source": "document",
                "original_text": f"category: {category_cn}, confidence: {confidence}",
                "location": "室内" if "室内" in reasons else "未知"
            },
            "tags": extract_tags_from_content(reasons, category_cn)
        }
        
        events.append(event)
    
    return events

def extract_tags_from_content(content, category):
    """从内容中提取标签"""
    tags = [category]
    
    # 常见标签词汇
    tag_keywords = {
        "猫": ["猫"],
        "狗": ["狗"],
        "室内": ["室内", "房间", "家庭"],
        "观望": ["观望", "注视", "观察", "警觉"],
        "探索": ["探索", "嗅探", "巡视", "移动"],
        "休息": ["休息", "躺", "放松", "静止"],
        "床单": ["床单", "垫子", "毛绒"],
        "蓝色": ["蓝色"]
    }
    
    for tag, keywords in tag_keywords.items():
        if any(keyword in content for keyword in keywords):
            if tag not in tags:
                tags.append(tag)
    
    return tags

def categorize_activities(events):
    """按活动类型分类整理数据"""
    categories = defaultdict(list)
    
    # 活动类型映射
    category_mapping = {
        "observe": "观望行为",
        "explore": "探索行为", 
        "rest": "休息行为",
        "occupy": "领地行为",
        "feeding": "进食行为",
        "exercise": "运动行为",
        "grooming": "清洁行为",
        "training": "训练行为",
        "social": "社交行为",
        "elimination": "如厕行为",
        "abnormal": "异常行为",
        "other": "其他行为",
        "no_pet": "无宠物",
        "neutral": "无特定行为"
    }
    
    for event in events:
        category = event.get("category", "other")
        category_name = category_mapping.get(category, category)
        
        # 格式化事件数据
        formatted_event = {
            "时间": event.get("timestamp", ""),
            "标题": event.get("title", ""),
            "内容": event.get("content", ""),
            "置信度": event.get("confidence", 0),
            "标签": event.get("tags", []),
            "位置": event.get("metadata", {}).get("location", ""),
            "原始类别": category
        }
        
        categories[category_name].append(formatted_event)
    
    return categories

def generate_summary(categories):
    """生成分类汇总信息"""
    summary = {
        "总事件数": sum(len(events) for events in categories.values()),
        "活动类型数": len(categories),
        "各类型统计": {}
    }
    
    for category, events in categories.items():
        if events:
            summary["各类型统计"][category] = {
                "事件数量": len(events),
                "平均置信度": round(sum(event["置信度"] for event in events) / len(events), 2),
                "时间范围": {
                    "开始": min(event["时间"] for event in events if event["时间"]),
                    "结束": max(event["时间"] for event in events if event["时间"])
                }
            }
    
    return summary

def main():
    # 读取原始文档内容
    try:
        with open("document_content.txt", "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("找不到document_content.txt文件")
        sys.exit(1)
    
    # 解析事件数据
    events = parse_raw_document(content)
    print(f"共解析到 {len(events)} 个事件")
    
    if not events:
        print("未能解析到任何事件数据")
        sys.exit(1)
    
    # 按类型分类
    categories = categorize_activities(events)
    
    # 生成汇总
    summary = generate_summary(categories)
    
    # 输出结果
    print("\n=== 宠物活动分类汇总 ===")
    print(f"总事件数: {summary['总事件数']}")
    print(f"活动类型数: {summary['活动类型数']}")
    
    print("\n=== 各类型详细统计 ===")
    for category, stats in summary["各类型统计"].items():
        print(f"\n【{category}】")
        print(f"  事件数量: {stats['事件数量']}")
        print(f"  平均置信度: {stats['平均置信度']}")
        print(f"  时间范围: {stats['时间范围']['开始']} ~ {stats['时间范围']['结束']}")
    
    # 保存分类结果
    categorized_data = {
        "汇总信息": summary,
        "分类数据": dict(categories)
    }
    
    with open("categorized_activities.json", "w", encoding="utf-8") as f:
        json.dump(categorized_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n=== 分类结果已保存到 categorized_activities.json ===")
    
    # 显示每个类型的前几个事件示例
    print("\n=== 各类型事件示例 ===")
    for category, events in categories.items():
        if events:
            print(f"\n【{category}】示例:")
            for i, event in enumerate(events[:3]):  # 显示前3个事件
                print(f"  {i+1}. {event['时间']} - {event['标题']}")
                print(f"     {event['内容'][:50]}...")

if __name__ == "__main__":
    main()