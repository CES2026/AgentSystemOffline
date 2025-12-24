#!/bin/bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🚀 vLLM Linux 部署 - 启动脚本${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 检查 Docker 和 Docker Compose
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Error: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Error: Docker Compose 未安装${NC}"
    echo "请先安装 Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# 检查 NVIDIA Docker 支持
if ! docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo -e "${RED}❌ Error: NVIDIA Docker 支持未配置${NC}"
    echo "请确保："
    echo "  1. NVIDIA 驱动已安装"
    echo "  2. nvidia-docker2 已安装"
    echo "  3. Docker 已重启"
    echo ""
    echo "安装命令（Ubuntu/Debian）："
    echo "  sudo apt-get install -y nvidia-docker2"
    echo "  sudo systemctl restart docker"
    exit 1
fi

echo -e "${GREEN}✅ Docker 环境检查通过${NC}"
echo ""

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env 文件不存在${NC}"
    echo "正在从 .env.example 创建..."
    cp .env.example .env
    echo -e "${YELLOW}请编辑 .env 文件并填写必需的配置（特别是 HUGGING_FACE_HUB_TOKEN）${NC}"
    echo ""
    read -p "按回车键继续（确认已配置 .env）..."
fi

# 加载环境变量
source .env

# 检查必需的环境变量
if [ -z "$HUGGING_FACE_HUB_TOKEN" ] || [ "$HUGGING_FACE_HUB_TOKEN" = "your_huggingface_token_here" ]; then
    echo -e "${RED}❌ Error: HUGGING_FACE_HUB_TOKEN 未设置${NC}"
    echo "请在 .env 文件中设置有效的 Hugging Face Token"
    echo "获取 Token: https://huggingface.co/settings/tokens"
    exit 1
fi

echo -e "${GREEN}✅ 配置文件检查通过${NC}"
echo ""

# 创建模型缓存目录
MODEL_CACHE_PATH="${VLLM_MODEL_CACHE_PATH:-./models}"
if [ ! -d "$MODEL_CACHE_PATH" ]; then
    echo "📁 创建模型缓存目录: $MODEL_CACHE_PATH"
    mkdir -p "$MODEL_CACHE_PATH"
fi

echo -e "${BLUE}📦 部署配置:${NC}"
echo "   模型: ${VLLM_MODEL:-casperhansen/llama-3.1-70b-instruct-awq}"
echo "   最大上下文: ${VLLM_MAX_MODEL_LEN:-8192} tokens"
echo "   GPU 显存利用率: ${VLLM_GPU_MEMORY_UTILIZATION:-0.90}"
echo "   模型缓存路径: $MODEL_CACHE_PATH"
echo ""

# 构建镜像
echo -e "${BLUE}🔨 构建 Docker 镜像...${NC}"
docker-compose build

echo ""
echo -e "${BLUE}🚀 启动服务...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}✅ 服务启动成功！${NC}"
echo ""
echo -e "${BLUE}📊 服务状态:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}📝 后续操作:${NC}"
echo "  查看日志: ./scripts/logs.sh"
echo "  健康检查: ./scripts/health-check.sh"
echo "  停止服务: ./scripts/stop.sh"
echo ""
echo -e "${YELLOW}⏳ 注意: 首次启动需要下载模型（~55GB），可能需要 10-30 分钟${NC}"
echo -e "${YELLOW}   使用 ./scripts/logs.sh vllm-server 查看下载进度${NC}"
echo ""
echo -e "${BLUE}🔗 访问地址:${NC}"
echo "  FastAPI Wrapper: http://localhost:8001"
echo "  vLLM Server: http://localhost:8000 (内部使用)"
echo "  API 文档: http://localhost:8001/docs"
echo ""
echo -e "${BLUE}============================================${NC}"
