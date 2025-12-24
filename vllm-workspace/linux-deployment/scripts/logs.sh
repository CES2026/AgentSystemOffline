#!/bin/bash

BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}📋 查看服务日志${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

if [ -z "$1" ]; then
    echo "查看所有服务日志..."
    echo "使用 Ctrl+C 退出"
    echo ""
    docker-compose logs -f
else
    echo "查看 $1 服务日志..."
    echo "使用 Ctrl+C 退出"
    echo ""
    docker-compose logs -f "$1"
fi
