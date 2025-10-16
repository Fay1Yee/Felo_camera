#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime, timedelta
from collections import defaultdict

def create_final_import_files():
    """创建最终的导入文件，确保与应用程序完全兼容"""
    
    # 读取处理好的数据
    with open('import_log.json', 'r', encoding='utf-8') as f:
        import_data = json.load(f)
    
    print("=== 创建最终导入文件 ===")
    print(f"处理记录数: {len(import_data)}")
    
    # 1. 创建标准的宠物活动数据文件（用于应用程序文件导入）
    with open('final_pet_activity_data.txt', 'w', encoding='utf-8') as f:
        f.write("timestamp\tcategory\tconfidence\treasons\n")
        
        for record in import_data:
            timestamp = record['timestamp']
            category = record['category']
            confidence = record['confidence']
            reasons = json.dumps(record['reasons'], ensure_ascii=False)
            
            f.write(f"{timestamp}\t{category}\t{confidence}\t{reasons}\n")
    
    # 2. 创建统计报表数据
    stats_data = generate_statistics_data(import_data)
    with open('statistics_data.json', 'w', encoding='utf-8') as f:
        json.dump(stats_data, f, ensure_ascii=False, indent=2)
    
    # 3. 创建行为分析数据
    behavior_data = generate_behavior_analysis(import_data)
    with open('behavior_analysis_data.json', 'w', encoding='utf-8') as f:
        json.dump(behavior_data, f, ensure_ascii=False, indent=2)
    
    # 4. 创建时间线数据
    timeline_data = generate_timeline_data(import_data)
    with open('timeline_data.json', 'w', encoding='utf-8') as f:
        json.dump(timeline_data, f, ensure_ascii=False, indent=2)
    
    print("✅ 最终导入文件创建完成")
    print("📁 文件列表:")
    print("  - final_pet_activity_data.txt (标准格式，用于应用程序导入)")
    print("  - statistics_data.json (统计报表数据)")
    print("  - behavior_analysis_data.json (行为分析数据)")
    print("  - timeline_data.json (时间线数据)")
    
    return {
        'total_records': len(import_data),
        'files_created': 4,
        'statistics': stats_data,
        'behavior_analysis': behavior_data
    }

def generate_statistics_data(import_data):
    """生成统计报表数据"""
    
    # 按日期分组
    daily_stats = defaultdict(lambda: {
        'total_activities': 0,
        'categories': defaultdict(int),
        'avg_confidence': 0,
        'confidence_sum': 0
    })
    
    # 按小时分组
    hourly_stats = defaultdict(int)
    
    # 总体统计
    category_totals = defaultdict(int)
    total_confidence = 0
    
    for record in import_data:
        dt = datetime.fromisoformat(record['timestamp'])
        date_key = dt.strftime('%Y-%m-%d')
        hour_key = dt.hour
        category = record['category']
        confidence = record['confidence']
        
        # 日统计
        daily_stats[date_key]['total_activities'] += 1
        daily_stats[date_key]['categories'][category] += 1
        daily_stats[date_key]['confidence_sum'] += confidence
        
        # 小时统计
        hourly_stats[hour_key] += 1
        
        # 总体统计
        category_totals[category] += 1
        total_confidence += confidence
    
    # 计算平均置信度
    for date_key in daily_stats:
        stats = daily_stats[date_key]
        stats['avg_confidence'] = stats['confidence_sum'] / stats['total_activities']
        del stats['confidence_sum']  # 删除临时字段
    
    return {
        'summary': {
            'total_records': len(import_data),
            'total_categories': len(category_totals),
            'avg_confidence': total_confidence / len(import_data),
            'date_range': {
                'start': min(record['timestamp'] for record in import_data),
                'end': max(record['timestamp'] for record in import_data)
            }
        },
        'daily_statistics': dict(daily_stats),
        'hourly_distribution': dict(hourly_stats),
        'category_distribution': dict(category_totals)
    }

def generate_behavior_analysis(import_data):
    """生成行为分析数据"""
    
    # 行为模式分析
    behavior_patterns = {}
    
    # 按类别分析
    for category in set(record['category'] for record in import_data):
        category_records = [r for r in import_data if r['category'] == category]
        
        # 时间分布
        hours = [datetime.fromisoformat(r['timestamp']).hour for r in category_records]
        hour_distribution = defaultdict(int)
        for hour in hours:
            hour_distribution[hour] += 1
        
        # 置信度分析
        confidences = [r['confidence'] for r in category_records]
        avg_confidence = sum(confidences) / len(confidences)
        
        # 描述长度分析
        descriptions = [r['reasons'].get('reasons', '') for r in category_records]
        avg_description_length = sum(len(desc) for desc in descriptions) / len(descriptions)
        
        behavior_patterns[category] = {
            'count': len(category_records),
            'percentage': len(category_records) / len(import_data) * 100,
            'avg_confidence': avg_confidence,
            'hour_distribution': dict(hour_distribution),
            'avg_description_length': avg_description_length,
            'peak_hours': sorted(hour_distribution.items(), key=lambda x: x[1], reverse=True)[:3]
        }
    
    # 行为转换分析
    transitions = defaultdict(int)
    for i in range(len(import_data) - 1):
        current_category = import_data[i]['category']
        next_category = import_data[i + 1]['category']
        transitions[f"{current_category} -> {next_category}"] += 1
    
    return {
        'behavior_patterns': behavior_patterns,
        'behavior_transitions': dict(transitions),
        'insights': generate_behavior_insights(behavior_patterns),
        'recommendations': generate_recommendations(behavior_patterns)
    }

def generate_behavior_insights(behavior_patterns):
    """生成行为洞察"""
    
    insights = []
    
    # 最活跃的行为
    most_active = max(behavior_patterns.items(), key=lambda x: x[1]['count'])
    insights.append(f"最常见的行为是'{most_active[0]}'，占总活动的{most_active[1]['percentage']:.1f}%")
    
    # 最高置信度的行为
    highest_confidence = max(behavior_patterns.items(), key=lambda x: x[1]['avg_confidence'])
    insights.append(f"置信度最高的行为是'{highest_confidence[0]}'，平均置信度为{highest_confidence[1]['avg_confidence']:.2f}")
    
    # 活跃时段分析
    all_hours = defaultdict(int)
    for pattern in behavior_patterns.values():
        for hour, count in pattern['hour_distribution'].items():
            all_hours[hour] += count
    
    peak_hour = max(all_hours.items(), key=lambda x: x[1])
    insights.append(f"最活跃的时段是{peak_hour[0]}:00-{peak_hour[0]}:59，共有{peak_hour[1]}次活动")
    
    return insights

def generate_recommendations(behavior_patterns):
    """生成建议"""
    
    recommendations = []
    
    # 基于行为分布的建议
    explore_count = behavior_patterns.get('explore', {}).get('count', 0)
    observe_count = behavior_patterns.get('observe', {}).get('count', 0)
    
    if explore_count > observe_count:
        recommendations.append("宠物表现出较强的探索欲望，建议提供更多新环境和玩具")
    else:
        recommendations.append("宠物更倾向于观察，建议创造安全的观察环境")
    
    # 基于置信度的建议
    low_confidence_behaviors = [
        name for name, data in behavior_patterns.items() 
        if data['avg_confidence'] < 0.7
    ]
    
    if low_confidence_behaviors:
        recommendations.append(f"以下行为的识别置信度较低，建议改善监控条件: {', '.join(low_confidence_behaviors)}")
    
    return recommendations

def generate_timeline_data(import_data):
    """生成时间线数据"""
    
    timeline = []
    
    for record in import_data:
        dt = datetime.fromisoformat(record['timestamp'])
        
        timeline_item = {
            'timestamp': record['timestamp'],
            'time_formatted': dt.strftime('%H:%M:%S'),
            'date_formatted': dt.strftime('%Y年%m月%d日'),
            'category': record['category'],
            'category_chinese': get_category_chinese(record['category']),
            'confidence': record['confidence'],
            'confidence_percentage': int(record['confidence'] * 100),
            'description': record['reasons'].get('reasons', ''),
            'metadata': record['reasons']
        }
        
        timeline.append(timeline_item)
    
    return {
        'timeline': timeline,
        'summary': {
            'total_events': len(timeline),
            'duration': str(datetime.fromisoformat(import_data[-1]['timestamp']) - 
                           datetime.fromisoformat(import_data[0]['timestamp'])),
            'categories': list(set(item['category'] for item in timeline))
        }
    }

def get_category_chinese(category):
    """获取类别的中文名称"""
    category_map = {
        'explore': '探索',
        'observe': '观望',
        'neutral': '中性',
        'no_pet': '无宠物',
        'occupy': '占据',
        'attack': '攻击',
        'play': '玩耍',
        'sleep': '睡觉',
        'eat': '进食',
        'drink': '饮水',
        'groom': '梳理',
        'rest': '休息'
    }
    return category_map.get(category, category)

if __name__ == "__main__":
    result = create_final_import_files()
    
    print(f"\n=== 导入验证摘要 ===")
    print(f"总记录数: {result['total_records']}")
    print(f"创建文件数: {result['files_created']}")
    print(f"统计类别数: {len(result['statistics']['category_distribution'])}")
    print(f"行为模式数: {len(result['behavior_analysis']['behavior_patterns'])}")
    
    print(f"\n=== 下一步操作 ===")
    print("1. 在应用程序中导航到历史记录页面")
    print("2. 点击导入按钮，选择 'final_pet_activity_data.txt' 文件")
    print("3. 验证数据在历史记录中的显示")
    print("4. 检查统计报表页面的数据展示")
    print("5. 验证行为分析页面的数据一致性")