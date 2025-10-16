#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import re
import json
from datetime import datetime

def process_pet_activity_data(input_file, output_file):
    """处理宠物活动数据并转换为标准格式"""
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 使用正则表达式提取数据
    pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})([a-z_]+)([\d.]+)```json\s*(\{[^`]+\})\s*```'
    matches = re.findall(pattern, content, re.MULTILINE | re.DOTALL)
    
    processed_data = []
    
    for match in matches:
        timestamp, category, confidence, json_str = match
        
        try:
            # 解析JSON数据
            json_data = json.loads(json_str)
            
            # 创建标准格式的记录
            record = {
                'timestamp': timestamp,
                'category': category,
                'confidence': float(confidence),
                'reasons': json_data.get('reasons', ''),
                'json_category': json_data.get('category', ''),
                'json_confidence': json_data.get('confidence', 0)
            }
            
            processed_data.append(record)
            
        except json.JSONDecodeError as e:
            print(f"JSON解析错误: {e}")
            print(f"原始JSON: {json_str}")
            continue
    
    # 保存为制表符分隔的格式
    with open(output_file, 'w', encoding='utf-8') as f:
        # 写入标题行
        f.write("timestamp\tcategory\tconfidence\treasons\n")
        
        for record in processed_data:
            # 格式化reasons为JSON字符串
            reasons_json = json.dumps({
                "category": record['json_category'],
                "confidence": record['json_confidence'],
                "reasons": record['reasons']
            }, ensure_ascii=False)
            
            # 写入数据行
            f.write(f"{record['timestamp']}\t{record['category']}\t{record['confidence']}\t{reasons_json}\n")
    
    print(f"处理完成！共处理 {len(processed_data)} 条记录")
    print(f"数据已保存到: {output_file}")
    
    return len(processed_data)

if __name__ == "__main__":
    input_file = "document_content.txt"
    output_file = "formatted_pet_activity_data.txt"
    
    count = process_pet_activity_data(input_file, output_file)
    print(f"\n=== 数据处理摘要 ===")
    print(f"输入文件: {input_file}")
    print(f"输出文件: {output_file}")
    print(f"处理记录数: {count}")