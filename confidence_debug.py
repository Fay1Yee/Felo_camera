#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json

def debug_confidence_issue():
    """诊断置信度显示问题"""
    
    print("=== 置信度问题诊断 ===\n")
    
    # 1. 检查原始数据文件
    print("1. 检查 final_pet_activity_data.txt 中的置信度值:")
    with open('final_pet_activity_data.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        for i, line in enumerate(lines[1:6]):  # 检查前5条记录
            parts = line.strip().split('\t')
            if len(parts) >= 3:
                timestamp, category, confidence = parts[0], parts[1], parts[2]
                print(f"  记录 {i+1}: {category} - 置信度: {confidence}")
    
    print()
    
    # 2. 检查应用程序导入格式
    print("2. 检查 app_history_import.json 中的置信度值:")
    with open('app_history_import.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
        for i, record in enumerate(data[:5]):  # 检查前5条记录
            confidence = record['result']['confidence']
            title = record['result']['title']
            print(f"  记录 {i+1}: {title} - 置信度: {confidence}")
    
    print()
    
    # 3. 分析问题
    print("3. 问题分析:")
    print("   - 原始数据中置信度为 0.5 (50%)")
    print("   - 应用程序导入格式中置信度为 50 (正确)")
    print("   - 如果UI显示0%，可能的原因:")
    print("     a) 您导入的是错误的文件格式")
    print("     b) 应用程序解析逻辑有问题")
    print("     c) 数据类型转换问题")
    
    print()
    
    # 4. 解决方案
    print("4. 解决方案:")
    print("   请确保您导入的是以下文件之一:")
    print("   - final_pet_activity_data.txt (标准格式)")
    print("   - app_history_import.json (应用程序格式)")
    print()
    print("   如果问题仍然存在，请检查应用程序的解析代码。")
    
    # 5. 创建测试数据
    print("5. 创建测试数据文件:")
    test_data = """timestamp	category	confidence	reasons
2025-10-13 19:50:51	observe	0.8	{"category": "观望", "confidence": 0.8, "reasons": "测试数据 - 置信度80%"}
2025-10-13 19:51:00	explore	0.9	{"category": "探索", "confidence": 0.9, "reasons": "测试数据 - 置信度90%"}
2025-10-13 19:51:10	play	0.7	{"category": "玩耍", "confidence": 0.7, "reasons": "测试数据 - 置信度70%"}"""
    
    with open('test_confidence_data.txt', 'w', encoding='utf-8') as f:
        f.write(test_data)
    
    print("   已创建 test_confidence_data.txt 用于测试")
    print("   请尝试导入此文件，看置信度是否正确显示为 80%, 90%, 70%")

if __name__ == "__main__":
    debug_confidence_issue()