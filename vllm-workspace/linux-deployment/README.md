# vLLM Linux 服务器部署指南

本目录包含了将 Modal 部署的 vLLM 迁移到 Linux 服务器的完整部署方案。

## 📋 目录

- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [详细配置](#详细配置)
- [管理命令](#管理命令)
- [故障排查](#故障排查)
- [性能优化](#性能优化)

---

## 🖥️ 系统要求

### 硬件要求

**GPU 配置（根据模型选择）：**

| 模型 | GPU 需求 | 显存 | 存储空间 |
|------|---------|------|---------|
| **Llama-3.1-70B INT4 AWQ（推荐）** | 1x A100-80GB | ~55GB | ~60GB |
| Llama-3.1-70B FP16 | 2x A100-80GB | ~140GB | ~150GB |
| Llama-3.1-8B | 1x A100-40GB | ~8GB | ~20GB |

**其他硬件：**
- CPU: 8+ 核心
- 内存: 32GB+ RAM
- 存储: 100GB+ SSD（用于模型缓存）
- 网络: 100+ Mbps（首次下载模型）

### 软件要求

- **操作系统**: Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **NVIDIA 驱动**: 525.60.13+ (支持 CUDA 12.1)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **nvidia-docker2**: 最新版本

---

## 🚀 快速开始

### 1. 安装依赖

#### Ubuntu/Debian

```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# 安装 NVIDIA 驱动（如果未安装）
sudo ubuntu-drivers autoinstall

# 安装 nvidia-docker2
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# 验证 GPU 支持
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi
```

### 2. 克隆或复制部署文件

```bash
cd /path/to/deployment
# 确保在 linux-deployment 目录下
ls  # 应该看到: docker-compose.yml, .env.example, docker/, scripts/, config/
```

### 3. 配置环境变量

```bash
# 复制配置文件
cp .env.example .env

# 编辑配置文件
nano .env  # 或使用 vim

# 必须设置：
# - HUGGING_FACE_HUB_TOKEN: 从 https://huggingface.co/settings/tokens 获取
# - VLLM_MODEL_CACHE_PATH: 模型缓存路径（确保有足够空间）
```

**最小配置示例：**

```bash
# .env
HUGGING_FACE_HUB_TOKEN=hf_xxxxxxxxxxxxxxxxxxxx
VLLM_MODEL=casperhansen/llama-3.1-70b-instruct-awq
VLLM_MODEL_CACHE_PATH=/data/vllm-models
```

### 4. 启动服务

```bash
# 运行启动脚本（会自动检查环境）
./scripts/start.sh

# 或直接使用 docker-compose
docker-compose up -d
```

### 5. 验证部署

```bash
# 健康检查
./scripts/health-check.sh

# 查看日志
./scripts/logs.sh

# 测试 API
./scripts/test-api.sh
```

**预期输出：**

```
🏥 vLLM 服务健康检查
============================================

📦 容器状态:
NAME            STATE     PORTS
vllm-server     running   0.0.0.0:8000->8000/tcp
vllm-wrapper    running   0.0.0.0:8001->8001/tcp

🔍 检查 vLLM 服务器 (http://localhost:8000)...
✅ vLLM 服务器运行正常

🔍 检查 FastAPI Wrapper (http://localhost:8001)...
✅ FastAPI Wrapper 运行正常
```

---

## ⚙️ 详细配置

### 环境变量说明

完整的环境变量配置请参考 `.env.example`。以下是关键配置：

#### 模型配置

```bash
# 模型选择
VLLM_MODEL=casperhansen/llama-3.1-70b-instruct-awq

# 上下文长度（tokens）
VLLM_MAX_MODEL_LEN=8192  # 8K 上下文
# VLLM_MAX_MODEL_LEN=16384  # 16K 上下文（需要更多显存）

# GPU 显存利用率（0.0-1.0）
VLLM_GPU_MEMORY_UTILIZATION=0.90  # 激进但稳定
# VLLM_GPU_MEMORY_UTILIZATION=0.85  # 保守，更多缓冲
```

#### 安全配置（可选）

```bash
# 启用 API 认证
VLLM_WRAPPER_API_KEY=your-secret-api-key

# 使用时需要在请求头中添加：
# Authorization: Bearer your-secret-api-key
```

#### 性能配置

```bash
# Tensor Parallel（多 GPU 并行）
VLLM_TENSOR_PARALLEL=1  # 单 GPU
# VLLM_TENSOR_PARALLEL=2  # 双 GPU（FP16 完整模型）

# 默认生成参数
VLLM_DEFAULT_MAX_TOKENS=2048
VLLM_DEFAULT_TEMPERATURE=0.7
```

### Docker Compose 配置

如需修改端口或资源限制，编辑 `docker-compose.yml`：

```yaml
# 修改端口映射
services:
  vllm-server:
    ports:
      - "9000:8000"  # 改为 9000 端口

  fastapi-wrapper:
    ports:
      - "9001:8001"  # 改为 9001 端口
```

---

## 🔧 管理命令

所有管理脚本位于 `scripts/` 目录：

```bash
# 启动服务
./scripts/start.sh

# 停止服务
./scripts/stop.sh

# 重启服务
./scripts/restart.sh

# 查看日志（所有服务）
./scripts/logs.sh

# 查看特定服务日志
./scripts/logs.sh vllm-server   # vLLM 服务器日志
./scripts/logs.sh vllm-wrapper  # FastAPI Wrapper 日志

# 健康检查
./scripts/health-check.sh

# API 测试
./scripts/test-api.sh
```

### 手动命令

```bash
# 查看容器状态
docker-compose ps

# 查看资源使用
docker stats

# 进入容器
docker exec -it vllm-server bash
docker exec -it vllm-wrapper bash

# 清理并重建
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 完全清理（包括模型缓存卷）
docker-compose down -v
```

---

## 📡 API 使用

部署成功后，可以通过以下方式访问 API：

### 1. FastAPI 文档（推荐）

访问：`http://localhost:8001/docs`

### 2. curl 示例

```bash
# 健康检查
curl http://localhost:8001/health

# 简单对话
curl -X POST http://localhost:8001/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好"}
    ],
    "max_tokens": 100
  }'

# OpenAI 兼容接口
curl -X POST http://localhost:8001/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "casperhansen/llama-3.1-70b-instruct-awq",
    "messages": [
      {"role": "user", "content": "Hello"}
    ],
    "max_tokens": 100
  }'

# 流式响应
curl -X POST http://localhost:8001/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "数到10"}
    ],
    "stream": true
  }'
```

### 3. Python 示例

```python
from openai import OpenAI

# 使用 OpenAI SDK（兼容）
client = OpenAI(
    base_url="http://localhost:8001/v1",
    api_key="EMPTY"  # 如果设置了 VLLM_WRAPPER_API_KEY，填写实际值
)

response = client.chat.completions.create(
    model="casperhansen/llama-3.1-70b-instruct-awq",
    messages=[
        {"role": "user", "content": "你好，请介绍一下自己"}
    ],
    max_tokens=200,
    temperature=0.7
)

print(response.choices[0].message.content)
```

---

## 🐛 故障排查

### 问题 1: GPU 不可用

**症状：**
```
Error: No NVIDIA GPU detected!
```

**解决方案：**

```bash
# 1. 检查 NVIDIA 驱动
nvidia-smi

# 2. 检查 Docker GPU 支持
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi

# 3. 重启 Docker
sudo systemctl restart docker

# 4. 重新安装 nvidia-docker2
sudo apt-get install --reinstall nvidia-docker2
sudo systemctl restart docker
```

### 问题 2: 模型下载失败

**症状：**
```
HTTPError: 401 Unauthorized
```

**解决方案：**

1. 检查 Hugging Face Token 是否正确
2. 确认 Token 有足够权限（需要 read 权限）
3. 对于 Llama 模型，需要先申请访问权限：https://huggingface.co/meta-llama

```bash
# 测试 Token 是否有效
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://huggingface.co/api/whoami
```

### 问题 3: 显存不足

**症状：**
```
OutOfMemoryError: CUDA out of memory
```

**解决方案：**

```bash
# 方案 1: 降低显存利用率
# 在 .env 中设置
VLLM_GPU_MEMORY_UTILIZATION=0.80  # 从 0.90 降到 0.80

# 方案 2: 减小上下文长度
VLLM_MAX_MODEL_LEN=4096  # 从 8192 降到 4096

# 方案 3: 使用更小的模型
VLLM_MODEL=meta-llama/Llama-3.1-8B-Instruct

# 重启服务
./scripts/restart.sh
```

### 问题 4: 容器启动慢

**症状：**
首次启动等待很久，vLLM 服务器一直显示 "Starting..."

**原因：**
正在下载模型（70B INT4 约 55GB）

**解决方案：**

```bash
# 查看下载进度
./scripts/logs.sh vllm-server

# 预期看到：
# Downloading model... 5.2GB/55GB
# 下载速度取决于网络和 Hugging Face 服务器

# 耐心等待，首次下载需要 10-30 分钟
```

### 问题 5: API 响应慢

**可能原因：**

1. **首次推理**: vLLM 需要预热（正常）
2. **上下文过长**: 减小 max_tokens 或上下文长度
3. **资源不足**: 检查 GPU/CPU/内存使用率

```bash
# 查看资源使用
docker stats

# 查看 GPU 使用
nvidia-smi

# 优化参数
# 在请求中设置较小的 max_tokens
curl -X POST http://localhost:8001/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [...],
    "max_tokens": 512  # 减小生成长度
  }'
```

---

## ⚡ 性能优化

### 1. 模型缓存优化

将模型缓存目录放在高速 SSD 上：

```bash
# .env
VLLM_MODEL_CACHE_PATH=/nvme/vllm-models  # 使用 NVMe SSD
```

### 2. 网络优化

对于生产环境，建议使用 Nginx 反向代理：

```nginx
# /etc/nginx/sites-available/vllm
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;  # 重要：支持流式响应
    }
}
```

### 3. 并发优化

FastAPI Wrapper 支持多 worker：

```bash
# 修改 docker/Dockerfile.wrapper 的启动命令
CMD ["python", "-m", "uvicorn", "vllm_wrapper:app", \
     "--host", "0.0.0.0", "--port", "8001", \
     "--workers", "4"]  # 增加 worker 数量
```

### 4. 监控和日志

使用 Prometheus + Grafana 监控：

```bash
# 添加到 docker-compose.yml
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

---

## 📊 资源监控

### GPU 使用

```bash
# 实时监控
watch -n 1 nvidia-smi

# 查看 GPU 利用率历史
nvidia-smi dmon -s u
```

### 容器资源

```bash
# 查看资源使用
docker stats vllm-server vllm-wrapper

# 查看详细信息
docker inspect vllm-server | jq '.[0].State'
```

---

## 🔐 生产环境建议

### 1. 启用 API 认证

```bash
# .env
VLLM_WRAPPER_API_KEY=your-strong-api-key-here
```

### 2. 使用 HTTPS

通过 Nginx + Let's Encrypt 添加 SSL：

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 3. 限流和负载均衡

使用 Nginx 限流：

```nginx
# 限制请求速率
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location /chat {
    limit_req zone=api_limit burst=20 nodelay;
    proxy_pass http://localhost:8001;
}
```

### 4. 日志管理

配置日志轮转：

```bash
# /etc/logrotate.d/docker-vllm
/var/lib/docker/containers/*/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
```

---

## 📚 架构对比

### Modal vs Linux 部署

| 特性 | Modal 部署 | Linux 部署 |
|------|-----------|-----------|
| **部署难度** | 简单（一键部署） | 中等（需要配置） |
| **成本** | 按使用付费 | 固定成本（服务器） |
| **自动扩展** | 支持 | 需手动配置 |
| **维护** | 托管（无需维护） | 自行维护 |
| **控制权** | 有限 | 完全控制 |
| **网络延迟** | 取决于 Modal 区域 | 本地网络（最低） |

---

## 🆘 获取帮助

如遇到问题，请检查：

1. **日志**: `./scripts/logs.sh`
2. **健康检查**: `./scripts/health-check.sh`
3. **GPU 状态**: `nvidia-smi`
4. **容器状态**: `docker-compose ps`

常见问题和解决方案请参考 [故障排查](#故障排查) 章节。

---

## 📄 许可证

本部署方案基于原 Modal 部署代码改编，保留原有许可证。

---

**祝部署顺利！** 🎉
