#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime

def generate_ui_verification_guide():
    """生成UI验证指南"""
    
    # 读取统计数据
    with open('statistics_data.json', 'r', encoding='utf-8') as f:
        stats_data = json.load(f)
    
    # 读取行为分析数据
    with open('behavior_analysis_data.json', 'r', encoding='utf-8') as f:
        behavior_data = json.load(f)
    
    print("=== 宠物活动数据UI验证指南 ===")
    print(f"数据导入时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"总记录数: {stats_data['summary']['total_records']}")
    print(f"数据时间范围: {stats_data['summary']['date_range']['start']} 至 {stats_data['summary']['date_range']['end']}")
    
    print("\n📋 验证清单:")
    
    # 1. 历史记录页面验证
    print("\n1️⃣ 历史记录页面验证")
    print("   ✅ 导航到历史记录页面")
    print("   ✅ 点击导入按钮")
    print("   ✅ 选择 'final_pet_activity_data.txt' 文件")
    print("   ✅ 确认导入成功提示")
    print("   ✅ 验证历史记录列表显示108条记录")
    print("   ✅ 检查时间戳格式正确")
    print("   ✅ 验证行为类别显示正确")
    
    # 2. 统计报表页面验证
    print("\n2️⃣ 统计报表页面验证")
    print("   预期数据:")
    print(f"   - 总活动次数: {stats_data['summary']['total_records']}")
    print(f"   - 活动类别数: {stats_data['summary']['total_categories']}")
    print(f"   - 平均置信度: {stats_data['summary']['avg_confidence']:.1%}")
    
    print("   类别分布:")
    for category, count in stats_data['category_distribution'].items():
        percentage = (count / stats_data['summary']['total_records']) * 100
        print(f"   - {get_category_chinese(category)}: {count}次 ({percentage:.1f}%)")
    
    print("   小时分布:")
    for hour, count in stats_data['hourly_distribution'].items():
        print(f"   - {hour}:00-{hour}:59: {count}次活动")
    
    # 3. 行为分析页面验证
    print("\n3️⃣ 行为分析页面验证")
    print("   行为模式分析:")
    
    # 获取前3个最常见的行为
    top_behaviors = sorted(
        behavior_data['behavior_patterns'].items(),
        key=lambda x: x[1]['count'],
        reverse=True
    )[:3]
    
    for i, (category, data) in enumerate(top_behaviors, 1):
        print(f"   {i}. {get_category_chinese(category)}:")
        print(f"      - 出现次数: {data['count']}")
        print(f"      - 占比: {data['percentage']:.1f}%")
        print(f"      - 平均置信度: {data['avg_confidence']:.1%}")
        print(f"      - 活跃时段: {format_peak_hours(data['peak_hours'])}")
    
    print("\n   行为洞察:")
    for insight in behavior_data['insights']:
        print(f"   • {insight}")
    
    print("\n   改进建议:")
    for recommendation in behavior_data['recommendations']:
        print(f"   • {recommendation}")
    
    # 4. 数据一致性验证
    print("\n4️⃣ 数据一致性验证")
    print("   ✅ 历史记录总数与统计报表一致")
    print("   ✅ 类别分布在各页面显示一致")
    print("   ✅ 时间范围在各页面显示一致")
    print("   ✅ 置信度数据在各页面显示一致")
    
    # 5. 功能性验证
    print("\n5️⃣ 功能性验证")
    print("   ✅ 历史记录可以按时间排序")
    print("   ✅ 历史记录可以按类别筛选")
    print("   ✅ 统计图表正确显示")
    print("   ✅ 行为分析图表正确显示")
    print("   ✅ 数据导出功能正常")
    
    # 6. 性能验证
    print("\n6️⃣ 性能验证")
    print("   ✅ 页面加载速度正常")
    print("   ✅ 数据筛选响应及时")
    print("   ✅ 图表渲染流畅")
    print("   ✅ 内存使用合理")
    
    print("\n🎯 验证重点:")
    print("1. 确保所有108条记录都正确导入")
    print("2. 验证7个行为类别都正确显示")
    print("3. 检查时间范围覆盖2025-10-13 19:50:51 至 20:26:42")
    print("4. 确认平均置信度为50%")
    print("5. 验证中文描述正确显示")
    
    print("\n⚠️  常见问题排查:")
    print("• 如果导入失败，检查文件格式是否正确")
    print("• 如果数据显示不全，检查权限设置")
    print("• 如果图表不显示，检查数据格式")
    print("• 如果中文乱码，检查编码设置")
    
    return {
        'verification_points': 24,
        'expected_records': stats_data['summary']['total_records'],
        'expected_categories': stats_data['summary']['total_categories'],
        'data_quality_score': calculate_data_quality_score(stats_data, behavior_data)
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

def format_peak_hours(peak_hours):
    """格式化活跃时段"""
    if not peak_hours:
        return "无数据"
    
    top_hour = peak_hours[0]
    return f"{top_hour[0]}:00-{top_hour[0]}:59 ({top_hour[1]}次)"

def calculate_data_quality_score(stats_data, behavior_data):
    """计算数据质量分数"""
    score = 0
    
    # 数据完整性 (30分)
    if stats_data['summary']['total_records'] > 100:
        score += 30
    elif stats_data['summary']['total_records'] > 50:
        score += 20
    else:
        score += 10
    
    # 类别多样性 (25分)
    category_count = stats_data['summary']['total_categories']
    if category_count >= 7:
        score += 25
    elif category_count >= 5:
        score += 20
    elif category_count >= 3:
        score += 15
    else:
        score += 10
    
    # 时间覆盖 (20分)
    start_time = datetime.fromisoformat(stats_data['summary']['date_range']['start'])
    end_time = datetime.fromisoformat(stats_data['summary']['date_range']['end'])
    duration = (end_time - start_time).total_seconds() / 60  # 分钟
    
    if duration > 30:
        score += 20
    elif duration > 15:
        score += 15
    else:
        score += 10
    
    # 行为分析质量 (25分)
    behavior_patterns = behavior_data['behavior_patterns']
    avg_description_length = sum(
        pattern['avg_description_length'] 
        for pattern in behavior_patterns.values()
    ) / len(behavior_patterns)
    
    if avg_description_length > 60:
        score += 25
    elif avg_description_length > 40:
        score += 20
    else:
        score += 15
    
    return min(score, 100)

if __name__ == "__main__":
    result = generate_ui_verification_guide()
    
    print(f"\n=== 验证摘要 ===")
    print(f"验证点数量: {result['verification_points']}")
    print(f"预期记录数: {result['expected_records']}")
    print(f"预期类别数: {result['expected_categories']}")
    print(f"数据质量分数: {result['data_quality_score']}/100")
    
    if result['data_quality_score'] >= 90:
        print("🌟 数据质量优秀，可以进行UI验证")
    elif result['data_quality_score'] >= 70:
        print("✅ 数据质量良好，建议进行UI验证")
    else:
        print("⚠️  数据质量需要改进，建议先优化数据")