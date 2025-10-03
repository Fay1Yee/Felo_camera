#!/usr/bin/env python3
"""
测试API调用脚本
用于验证后端API服务是否正常工作
"""

import requests
import base64
import json
import os

def test_api_call():
    """测试API调用"""
    # API端点
    url = "https://127.0.0.1:8443/analyze"
    
    # 测试图片路径
    test_image_path = "/Users/zephyruszhou/Documents/Felo- camera/backend/test_image.jpg"
    
    if not os.path.exists(test_image_path):
        print(f"测试图片不存在: {test_image_path}")
        return
    
    # 读取并编码图片
    with open(test_image_path, "rb") as image_file:
        image_data = base64.b64encode(image_file.read()).decode('utf-8')
    
    # 构建请求数据
    data = {
        "mode": "pet_health",
        "image": image_data
    }
    
    try:
        # 发送请求（忽略SSL证书验证）
        response = requests.post(
            url, 
            json=data, 
            verify=False,  # 忽略SSL证书验证
            timeout=30
        )
        
        print(f"状态码: {response.status_code}")
        print(f"响应内容: {response.text}")
        
        if response.status_code == 200:
            result = response.json()
            print("API调用成功!")
            print(f"分析结果: {json.dumps(result, indent=2, ensure_ascii=False)}")
        else:
            print(f"API调用失败: {response.status_code}")
            
    except Exception as e:
        print(f"请求异常: {e}")

if __name__ == "__main__":
    print("开始测试API调用...")
    test_api_call()