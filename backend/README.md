# Nothing Phone 3a Camera Backend API

基于 FastAPI 的智能图片分析后端服务，集成火山引擎 Ark API，为 Nothing Phone 3a 相机应用提供 AI 图像识别功能。

## 🚀 功能特性

- **多模式图片分析**：支持普通场景、宠物识别、健康分析、旅行助手四种分析模式
- **智能图片处理**：自动压缩、格式转换、尺寸优化
- **AI 驱动分析**：集成火山引擎 Ark API，使用 doubao-seed-1-6-250615 模型
- **RESTful API**：标准化 API 接口，支持跨平台调用
- **实时健康检查**：完整的服务状态监控
- **错误处理**：完善的异常处理和日志记录
- **CORS 支持**：支持跨域请求，便于前端集成

## 📋 技术栈

- **框架**：FastAPI 0.104+
- **AI 服务**：火山引擎 Ark API (OpenAI 兼容)
- **图片处理**：Pillow (PIL)
- **服务器**：Uvicorn ASGI
- **环境管理**：python-dotenv

## 🛠 快速开始

### 1. 环境要求

- Python 3.8+
- pip 包管理器

### 2. 安装依赖

```bash
# 创建虚拟环境（推荐）
python -m venv venv
source venv/bin/activate  # Linux/macOS
# 或 venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

### 3. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入你的 API 密钥
ARK_API_KEY=e779c50a-bc8c-4673-ada3-30c4e7987018
HOST=0.0.0.0
PORT=8000
DEBUG=true
LOG_LEVEL=info
```

### 4. 启动服务

```bash
python main.py
```

服务将在 `http://localhost:8000` 启动，访问 `http://localhost:8000/docs` 查看 API 文档。

## 📚 API 接口文档

### POST /analyze

**功能**：上传图片进行 AI 分析

**请求参数**：
- `file` (required): 图片文件，支持 JPEG、PNG、WebP 格式
- `mode` (optional): 分析模式，默认为 "normal"
  - `normal`: 普通场景识别
  - `pet`: 宠物识别与行为分析
  - `health`: 健康相关信息分析
  - `travel`: 旅行场景与地点识别

**请求示例**：
```bash
curl -X POST "http://localhost:8000/analyze" \
  -F "file=@your_image.jpg" \
  -F "mode=pet"
```

**响应格式**：
```json
{
  "success": true,
  "mode": "pet",
  "analysis": {
    "title": "宠物识别",
    "description": "这是一只金毛犬，看起来很健康活泼，正在草地上玩耍...",
    "confidence": 0.85,
    "sub_info": "宠物行为识别"
  },
  "timestamp": 1703123456789
}
```

**错误响应**：
```json
{
  "detail": "不支持的文件格式"
}
```

### GET /health

**功能**：服务健康检查

**响应示例**：
```json
{
  "status": "healthy",
  "service": "Nothing Phone 3a Camera API",
  "version": "1.0.0",
  "timestamp": 1703123456789,
  "api_config": {
    "model": "doubao-seed-1-6-250615",
    "status": "configured"
  }
}
```

### GET /

**功能**：API 根路径，返回服务信息

## 🏗 系统架构

```
┌─────────────────┐    HTTP/HTTPS    ┌─────────────────┐
│   Flutter App   │ ────────────────▶ │   FastAPI       │
│   (前端应用)     │                  │   Backend       │
└─────────────────┘                  └─────────────────┘
                                              │
                                              │ API调用
                                              ▼
                                     ┌─────────────────┐
                                     │  火山引擎 Ark    │
                                     │  AI 服务        │
                                     └─────────────────┘
```

## 🔧 开发说明

### 图片处理流程

1. **文件验证**：检查文件格式和大小
2. **图片优化**：自动压缩大图片（>1024x1024）
3. **格式转换**：统一转换为 JPEG 格式
4. **Base64 编码**：转换为 API 可接受的格式

### AI 分析流程

1. **模式选择**：根据用户选择的模式构建不同的提示词
2. **API 调用**：调用火山引擎 Ark API 进行分析
3. **结果处理**：解析 AI 响应并格式化
4. **响应构建**：构建符合前端期望的 JSON 响应

### 日志记录

- 使用 Python logging 模块
- 记录 API 调用、错误信息、性能指标
- 支持不同日志级别配置

## 🚀 部署指南

### 开发环境

```bash
# 直接运行
python main.py

# 或使用 uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 生产环境

#### Docker 部署

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### 云服务部署

推荐使用以下云服务：
- **阿里云**：函数计算 FC、容器服务 ACK
- **腾讯云**：云函数 SCF、容器服务 TKE
- **华为云**：函数工作流 FunctionGraph、云容器引擎 CCE

### 安全配置

生产环境请确保：

1. **环境变量安全**：
   ```bash
   # 使用安全的 API 密钥管理
   ARK_API_KEY=your_secure_api_key
   DEBUG=false
   ```

2. **CORS 配置**：
   ```python
   # 限制允许的来源
   allow_origins=["https://yourdomain.com"]
   ```

3. **HTTPS 配置**：
   ```bash
   # 使用反向代理（如 Nginx）配置 HTTPS
   # 或使用云服务的 HTTPS 证书
   ```

4. **请求限制**：
   ```python
   # 添加请求频率限制
   from slowapi import Limiter
   ```

## 🔍 监控与维护

### 性能监控

- API 响应时间
- 错误率统计
- 资源使用情况
- AI API 调用次数

### 日志分析

```bash
# 查看实时日志
tail -f logs/app.log

# 分析错误日志
grep "ERROR" logs/app.log
```

### 健康检查

定期访问 `/health` 端点确保服务正常运行。

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证。

## 📞 支持

如有问题或建议，请提交 Issue 或联系开发团队。