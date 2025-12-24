#!/bin/bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🔄 重启 vLLM 服务${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo "停止服务..."
docker-compose down

echo ""
echo "启动服务..."
docker-compose up -d

echo ""
echo -e "${GREEN}✅ 服务重启完成${NC}"
echo ""

./scripts/health-check.sh
