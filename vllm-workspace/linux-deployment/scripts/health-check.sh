#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🏥 vLLM 服务健康检查${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 检查容器状态
echo -e "${BLUE}📦 容器状态:${NC}"
docker-compose ps
echo ""

# 检查 vLLM 服务器
echo -e "${BLUE}🔍 检查 vLLM 服务器 (http://localhost:8000)...${NC}"
if curl -s -f http://localhost:8000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ vLLM 服务器运行正常${NC}"

    # 获取模型列表
    echo ""
    echo -e "${BLUE}📚 可用模型:${NC}"
    curl -s http://localhost:8000/v1/models | jq '.data[].id' 2>/dev/null || echo "无法获取模型列表"
else
    echo -e "${RED}❌ vLLM 服务器不可用${NC}"
    echo -e "${YELLOW}提示: 首次启动可能需要 10-30 分钟下载模型${NC}"
fi

echo ""

# 检查 FastAPI Wrapper
echo -e "${BLUE}🔍 检查 FastAPI Wrapper (http://localhost:8001)...${NC}"
if curl -s -f http://localhost:8001/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ FastAPI Wrapper 运行正常${NC}"

    # 获取健康状态详情
    echo ""
    echo -e "${BLUE}📊 Wrapper 状态详情:${NC}"
    curl -s http://localhost:8001/health | jq '.' 2>/dev/null || curl -s http://localhost:8001/health
else
    echo -e "${RED}❌ FastAPI Wrapper 不可用${NC}"
fi

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}💡 提示:${NC}"
echo "  - 查看日志: ./scripts/logs.sh"
echo "  - 查看 vLLM 日志: ./scripts/logs.sh vllm-server"
echo "  - 查看 Wrapper 日志: ./scripts/logs.sh vllm-wrapper"
echo -e "${BLUE}============================================${NC}"
