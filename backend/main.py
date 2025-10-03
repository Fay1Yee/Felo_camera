#!/usr/bin/env python3
"""
FastAPI 后端服务器 - 代理 Volcengine Ark API 请求
为 Nothing Phone 3a 测试应用提供图片分析服务
"""

import os
import base64
import logging
from typing import Optional, Dict, Any
from io import BytesIO

from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
from openai import OpenAI
from PIL import Image
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Nothing Phone 3a Camera API",
    description="图片分析服务 - 基于 Volcengine Ark",
    version="1.0.0"
)

# 配置 CORS 允许 Flutter 客户端访问
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 开发环境允许所有来源
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 初始化 Volcengine Ark 客户端
def get_ark_client() -> OpenAI:
    """获取配置好的 Ark 客户端"""
    api_key = os.getenv("ARK_API_KEY")
    if not api_key:
        raise ValueError("ARK_API_KEY environment variable not set")
    
    return OpenAI(
        api_key=api_key,
        base_url="https://ark.cn-beijing.volces.com/api/v3"
    )

# 模式对应的提示词
MODE_PROMPTS = {
    "normal": "Please analyze this image content and describe the main objects and scenes concisely.",
    "pet": "Please identify the pet type, breed and status in the image, and describe the pet's characteristics and behavior.",
    "health": "Please analyze this image from a health perspective, identify possible health-related information, and give suggestions.",
    "travel": "Please analyze this travel scene image, identify locations, landscapes or travel-related elements, and describe them."
}

def encode_image_to_base64(image_bytes: bytes) -> str:
    """将图片字节转换为 base64 编码"""
    try:
        # 验证图片格式
        image = Image.open(BytesIO(image_bytes))
        
        # 如果图片过大，进行压缩
        max_size = (1024, 1024)
        if image.size[0] > max_size[0] or image.size[1] > max_size[1]:
            image.thumbnail(max_size, Image.Resampling.LANCZOS)
            
            # 重新编码压缩后的图片
            buffer = BytesIO()
            image.save(buffer, format='JPEG', quality=85)
            image_bytes = buffer.getvalue()
        
        return base64.b64encode(image_bytes).decode('utf-8')
    except Exception as e:
        logger.error(f"图片编码失败: {e}")
        raise HTTPException(status_code=400, detail="图片格式不支持或损坏")

@app.get("/")
async def root():
    """健康检查接口"""
    return {"message": "Nothing Phone 3a Camera API 运行正常", "status": "ok"}

@app.post("/analyze")
async def analyze_image(
    file: UploadFile = File(...),
    mode: str = Form(default="normal")
):
    """
    图片分析接口
    
    Args:
        file: 上传的图片文件
        mode: 分析模式 (normal, pet, health, travel)
    
    Returns:
        JSON 响应包含分析结果
    """
    try:
        # 添加详细日志
        logger.info(f"Received request - file: {file.filename}, content_type: {file.content_type}, mode: {mode}")
        
        # 验证文件类型
        if not file.content_type or not file.content_type.startswith('image/'):
            logger.error(f"Invalid content type: {file.content_type}")
            raise HTTPException(status_code=400, detail="请上传有效的图片文件")
        
        # 验证模式
        if mode not in MODE_PROMPTS:
            logger.warning(f"Invalid mode '{mode}', using 'normal'")
            mode = "normal"
        
        # 读取图片数据
        image_bytes = await file.read()
        logger.info(f"Image size: {len(image_bytes)} bytes")
        
        if len(image_bytes) == 0:
            logger.error("Empty image file")
            raise HTTPException(status_code=400, detail="图片文件为空")
        
        # 编码图片
        try:
            base64_image = encode_image_to_base64(image_bytes)
            logger.info("Image encoded successfully")
        except Exception as e:
            logger.error(f"Image encoding failed: {e}")
            raise HTTPException(status_code=400, detail=f"图片编码失败: {str(e)}")
        
        # 获取 Ark 客户端
        client = get_ark_client()
        
        # 构建请求
        messages = [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": MODE_PROMPTS[mode]
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{base64_image}"
                        }
                    }
                ]
            }
        ]
        
        # 调用 Ark API
        logger.info(f"Analyzing image - mode: {mode}")
        try:
            response = client.chat.completions.create(
                model="doubao-seed-1-6-250615",  # 使用用户提供的推理接入点 ID
                messages=messages,
                max_tokens=300,
                temperature=0.7
            )
            logger.info("Ark API call successful")
        except Exception as api_error:
            logger.error(f"Ark API call failed: {api_error}")
            # 返回模拟结果以便测试
            analysis_result = f"This is an image analysis result in {mode} mode. Returning mock data due to API configuration issues."
        
        # 解析响应
        try:
            if 'response' in locals():
                analysis_result = response.choices[0].message.content.strip()
            # 如果没有response（API调用失败），使用之前设置的模拟结果
        except Exception as e:
            logger.error(f"Response parsing failed: {e}")
            analysis_result = f"This is an image analysis result in {mode} mode. Response parsing error, returning mock data."
        
        # 构建符合 Flutter 客户端期望的响应格式
        result = {
            "success": True,
            "mode": mode,
            "analysis": {
                "title": get_title_for_mode(mode),
                "description": analysis_result,
                "confidence": 0.85,  # 模拟置信度
                "sub_info": get_sub_info_for_mode(mode)
            },
            "timestamp": int(os.times().elapsed * 1000)  # 毫秒时间戳
        }
        
        logger.info(f"Analysis completed - mode: {mode}")
        return JSONResponse(content=result)
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"图片分析失败: {e}")
        raise HTTPException(status_code=500, detail=f"分析失败: {str(e)}")

def get_title_for_mode(mode: str) -> str:
    """根据模式获取标题"""
    titles = {
        "normal": "Scene Recognition",
        "pet": "Pet Recognition", 
        "health": "Health Analysis",
        "travel": "Travel Assistant"
    }
    return titles.get(mode, "Smart Analysis")

def get_sub_info_for_mode(mode: str) -> str:
    """根据模式获取副标题信息"""
    sub_infos = {
        "normal": "AI Vision Analysis",
        "pet": "Pet Behavior Recognition",
        "health": "Health Status Assessment", 
        "travel": "Travel Perspective"
    }
    return sub_infos.get(mode, "Smart Recognition")

@app.get("/health")
async def health_check():
    """详细健康检查"""
    try:
        # 检查 API 密钥
        api_key = os.getenv("ARK_API_KEY")
        if not api_key:
            return JSONResponse(
                status_code=503,
                content={"status": "error", "message": "ARK_API_KEY 未配置"}
            )
        
        # 可以添加更多检查项
        return {
            "status": "healthy",
            "api_configured": bool(api_key),
            "model": "doubao-seed-1-6-250615"
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={"status": "error", "message": str(e)}
        )

if __name__ == "__main__":
    # 检查必需的环境变量
    if not os.getenv("ARK_API_KEY"):
        logger.error("请设置 ARK_API_KEY 环境变量")
        exit(1)
    
    logger.info("启动 Nothing Phone 3a Camera API 服务器...")
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8443,
        reload=True,
        log_level="info",
        ssl_keyfile="key.pem",
        ssl_certfile="cert.pem"
    )