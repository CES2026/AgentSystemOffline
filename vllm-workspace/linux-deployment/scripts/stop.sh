#!/bin/bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🛑 停止 vLLM 服务${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

docker-compose down

echo ""
echo -e "${GREEN}✅ 服务已停止${NC}"
echo ""
echo "如需完全清理（包括模型缓存），运行:"
echo "  docker-compose down -v"
echo ""
