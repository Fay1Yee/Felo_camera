#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import requests
import json
import sys

def parse_document_with_api(content):
    """使用后端API解析文档内容"""
    url = "http://localhost:8000/analyze-document"
    
    payload = {
        "prompt": content,
        "analysis_type": "text_analysis"
    }
    
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        response.raise_for_status()
        
        result = response.json()
        return result
    
    except requests.exceptions.RequestException as e:
        print(f"API请求失败: {e}")
        return None
    except json.JSONDecodeError as e:
        print(f"JSON解析失败: {e}")
        return None

def main():
    # 读取文档内容
    try:
        with open("document_content.txt", "r", encoding="utf-8") as f:
            content = f.read()
    except FileNotFoundError:
        print("找不到document_content.txt文件")
        sys.exit(1)
    
    print("正在调用后端API解析文档...")
    result = parse_document_with_api(content)
    
    if result:
        print("=== API解析结果 ===")
        print(json.dumps(result, ensure_ascii=False, indent=2))
        
        # 保存解析结果
        with open("parsed_document_result.json", "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print("\n=== 解析结果已保存到 parsed_document_result.json ===")
    else:
        print("API解析失败")

if __name__ == "__main__":
    main()