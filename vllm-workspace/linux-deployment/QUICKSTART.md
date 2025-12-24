# vLLM Linux 部署 - 快速开始

## 5 分钟快速部署指南

### 前提条件

- ✅ Ubuntu 20.04+ 系统
- ✅ NVIDIA GPU (A100-80GB 推荐)
- ✅ NVIDIA 驱动已安装（525.60.13+）
- ✅ Docker 和 nvidia-docker2 已安装
- ✅ Hugging Face 账号和 Token

### 部署步骤

```bash
# 1. 进入部署目录
cd linux-deployment/

# 2. 配置环境变量
cp .env.example .env
nano .env  # 编辑并设置 HUGGING_FACE_HUB_TOKEN

# 3. 启动服务
./scripts/start.sh

# 4. 等待模型下载（10-30 分钟）
./scripts/logs.sh vllm-server

# 5. 健康检查
./scripts/health-check.sh

# 6. 测试 API
./scripts/test-api.sh
```

### 验证部署

访问以下地址：
- API 文档: http://localhost:8001/docs
- 健康检查: http://localhost:8001/health

### 测试对话

```bash
curl -X POST http://localhost:8001/chat \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 常见问题

**Q: GPU 不可用？**
```bash
# 检查 GPU
nvidia-smi

# 测试 Docker GPU 支持
docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi

# 重启 Docker
sudo systemctl restart docker
```

**Q: 模型下载慢？**
- 这是正常现象，70B INT4 模型约 55GB
- 使用 `./scripts/logs.sh vllm-server` 查看进度
- 确保网络稳定，首次下载需要 10-30 分钟

**Q: 启动失败？**
```bash
# 查看日志
./scripts/logs.sh

# 检查环境变量
cat .env

# 重启服务
./scripts/restart.sh
```

### 下一步

- 阅读完整文档: [README.md](README.md)
- 配置生产环境: [README.md#生产环境建议](README.md#生产环境建议)
- 性能优化: [README.md#性能优化](README.md#性能优化)

---

**需要帮助？** 查看 [故障排查](README.md#故障排查) 章节
