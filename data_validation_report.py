#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import pandas as pd
from datetime import datetime, timedelta
from collections import Counter
import matplotlib.pyplot as plt
import seaborn as sns

def generate_validation_report():
    """生成数据验证和统计报告"""
    
    # 读取导入的数据
    with open('import_log.json', 'r', encoding='utf-8') as f:
        import_data = json.load(f)
    
    with open('app_history_import.json', 'r', encoding='utf-8') as f:
        app_history = json.load(f)
    
    print("=== 宠物活动数据验证报告 ===")
    print(f"报告生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"数据来源: timestampcategoryconfidencereasons2025.docx")
    
    # 基本统计
    total_records = len(import_data)
    print(f"\n=== 基本统计 ===")
    print(f"总记录数: {total_records}")
    print(f"应用程序历史记录数: {len(app_history)}")
    print(f"数据完整性: {len(app_history)/total_records*100:.1f}%")
    
    # 时间范围分析
    timestamps = [datetime.fromisoformat(record['timestamp']) for record in import_data]
    timestamps.sort()
    
    print(f"\n=== 时间范围分析 ===")
    print(f"开始时间: {timestamps[0].strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"结束时间: {timestamps[-1].strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"时间跨度: {timestamps[-1] - timestamps[0]}")
    print(f"平均间隔: {(timestamps[-1] - timestamps[0]) / len(timestamps)}")
    
    # 行为分类统计
    categories = [record['category'] for record in import_data]
    category_counts = Counter(categories)
    
    print(f"\n=== 行为分类统计 ===")
    for category, count in category_counts.most_common():
        percentage = (count / total_records) * 100
        print(f"{category}: {count} 次 ({percentage:.1f}%)")
    
    # 置信度分析
    confidences = [record['confidence'] for record in import_data]
    avg_confidence = sum(confidences) / len(confidences)
    
    print(f"\n=== 置信度分析 ===")
    print(f"平均置信度: {avg_confidence:.3f}")
    print(f"最高置信度: {max(confidences):.3f}")
    print(f"最低置信度: {min(confidences):.3f}")
    
    # 按小时统计活动分布
    hourly_activity = {}
    for record in import_data:
        dt = datetime.fromisoformat(record['timestamp'])
        hour = dt.hour
        if hour not in hourly_activity:
            hourly_activity[hour] = 0
        hourly_activity[hour] += 1
    
    print(f"\n=== 按小时活动分布 ===")
    for hour in sorted(hourly_activity.keys()):
        count = hourly_activity[hour]
        percentage = (count / total_records) * 100
        print(f"{hour:02d}:00-{hour:02d}:59: {count} 次 ({percentage:.1f}%)")
    
    # 行为质量分析
    print(f"\n=== 行为质量分析 ===")
    
    # 分析reasons字段的质量
    reasons_lengths = []
    chinese_reasons = 0
    detailed_reasons = 0
    
    for record in import_data:
        reasons = record['reasons'].get('reasons', '')
        reasons_lengths.append(len(reasons))
        
        # 检查是否包含中文
        if any('\u4e00' <= char <= '\u9fff' for char in reasons):
            chinese_reasons += 1
        
        # 检查是否包含详细描述
        if len(reasons) > 50:
            detailed_reasons += 1
    
    print(f"平均描述长度: {sum(reasons_lengths)/len(reasons_lengths):.1f} 字符")
    print(f"中文描述比例: {chinese_reasons/total_records*100:.1f}%")
    print(f"详细描述比例: {detailed_reasons/total_records*100:.1f}%")
    
    # 数据质量评分
    quality_score = 0
    
    # 完整性评分 (30%)
    completeness = len(app_history) / total_records
    quality_score += completeness * 30
    
    # 置信度评分 (25%)
    confidence_score = avg_confidence * 25
    quality_score += confidence_score
    
    # 描述质量评分 (25%)
    description_quality = (detailed_reasons / total_records) * 25
    quality_score += description_quality
    
    # 分类多样性评分 (20%)
    diversity_score = min(len(category_counts) / 10, 1.0) * 20
    quality_score += diversity_score
    
    print(f"\n=== 数据质量评分 ===")
    print(f"完整性评分: {completeness*30:.1f}/30")
    print(f"置信度评分: {confidence_score:.1f}/25")
    print(f"描述质量评分: {description_quality:.1f}/25")
    print(f"分类多样性评分: {diversity_score:.1f}/20")
    print(f"总体质量评分: {quality_score:.1f}/100")
    
    # 生成统计摘要
    summary = {
        "数据概览": {
            "总记录数": total_records,
            "时间跨度": str(timestamps[-1] - timestamps[0]),
            "行为类型数": len(category_counts),
            "平均置信度": round(avg_confidence, 3)
        },
        "行为分布": dict(category_counts),
        "质量评分": {
            "总分": round(quality_score, 1),
            "完整性": round(completeness*30, 1),
            "置信度": round(confidence_score, 1),
            "描述质量": round(description_quality, 1),
            "分类多样性": round(diversity_score, 1)
        },
        "时间分布": hourly_activity
    }
    
    # 保存报告
    with open('validation_report.json', 'w', encoding='utf-8') as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)
    
    print(f"\n=== 报告生成完成 ===")
    print(f"详细报告已保存到: validation_report.json")
    
    return summary

if __name__ == "__main__":
    report = generate_validation_report()
    
    print(f"\n=== 建议 ===")
    if report["质量评分"]["总分"] >= 80:
        print("✅ 数据质量优秀，可以直接用于统计分析和行为分析")
    elif report["质量评分"]["总分"] >= 60:
        print("⚠️ 数据质量良好，建议优化描述质量")
    else:
        print("❌ 数据质量需要改进，建议重新处理")