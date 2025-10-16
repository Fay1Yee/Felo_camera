#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import requests
import time
from datetime import datetime

def import_data_to_app():
    """将格式化的数据导入到应用程序"""
    
    # 读取格式化的数据
    with open('formatted_pet_activity_data.txt', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # 跳过标题行
    data_lines = lines[1:]
    
    print(f"=== 开始导入数据到应用程序 ===")
    print(f"总记录数: {len(data_lines)}")
    
    imported_count = 0
    failed_count = 0
    
    # 创建导入日志
    import_log = []
    
    for i, line in enumerate(data_lines):
        parts = line.strip().split('\t')
        if len(parts) >= 4:
            timestamp, category, confidence, reasons = parts
            
            try:
                # 解析reasons JSON
                reasons_data = json.loads(reasons)
                
                # 创建记录
                record = {
                    'timestamp': timestamp,
                    'category': category,
                    'confidence': float(confidence),
                    'reasons': reasons_data,
                    'import_time': datetime.now().isoformat(),
                    'record_id': f"import_{i+1}"
                }
                
                import_log.append(record)
                imported_count += 1
                
                # 显示进度
                if imported_count % 10 == 0:
                    print(f"已处理: {imported_count}/{len(data_lines)} 条记录")
                
            except (json.JSONDecodeError, ValueError) as e:
                print(f"记录 {i+1} 解析失败: {e}")
                failed_count += 1
                continue
    
    # 保存导入日志
    with open('import_log.json', 'w', encoding='utf-8') as f:
        json.dump(import_log, f, ensure_ascii=False, indent=2)
    
    # 创建应用程序可读的历史记录格式
    app_history = []
    for record in import_log:
        app_record = {
            "id": record['record_id'],
            "timestamp": record['timestamp'],
            "result": {
                "title": f"宠物{record['category']}行为",
                "confidence": int(record['confidence'] * 100),
                "subInfo": json.dumps(record['reasons'], ensure_ascii=False)
            },
            "mode": "pet_activity",
            "imagePath": None
        }
        app_history.append(app_record)
    
    # 保存为应用程序历史记录格式
    with open('app_history_import.json', 'w', encoding='utf-8') as f:
        json.dump(app_history, f, ensure_ascii=False, indent=2)
    
    print(f"\n=== 导入完成 ===")
    print(f"成功导入: {imported_count} 条记录")
    print(f"失败记录: {failed_count} 条")
    print(f"导入日志已保存到: import_log.json")
    print(f"应用程序历史记录已保存到: app_history_import.json")
    
    return {
        'imported': imported_count,
        'failed': failed_count,
        'total': len(data_lines)
    }

if __name__ == "__main__":
    result = import_data_to_app()
    print(f"\n=== 导入摘要 ===")
    print(f"总记录: {result['total']}")
    print(f"成功: {result['imported']}")
    print(f"失败: {result['failed']}")
    print(f"成功率: {(result['imported']/result['total']*100):.1f}%")