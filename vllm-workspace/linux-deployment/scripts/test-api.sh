#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}🧪 测试 vLLM API${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

BASE_URL="http://localhost:8001"

# 测试健康检查
echo -e "${BLUE}1. 健康检查 (GET /health)${NC}"
curl -s "$BASE_URL/health" | jq '.' || curl -s "$BASE_URL/health"
echo ""
echo ""

# 测试模型列表
echo -e "${BLUE}2. 模型列表 (GET /models)${NC}"
curl -s "$BASE_URL/models" | jq '.' || curl -s "$BASE_URL/models"
echo ""
echo ""

# 测试对话接口
echo -e "${BLUE}3. 对话测试 (POST /chat)${NC}"
echo -e "${YELLOW}发送请求: '你好，请做一个简短的自我介绍'${NC}"
echo ""

curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好，请做一个简短的自我介绍（20字以内）"}
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }' | jq '.' || curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "你好，请做一个简短的自我介绍（20字以内）"}
    ],
    "max_tokens": 100,
    "temperature": 0.7
  }'

echo ""
echo ""

# 测试流式接口
echo -e "${BLUE}4. 流式对话测试 (POST /chat with stream=true)${NC}"
echo -e "${YELLOW}发送请求: '数到5'${NC}"
echo ""

curl -s -X POST "$BASE_URL/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [
      {"role": "user", "content": "请从1数到5，每个数字用空格分开"}
    ],
    "max_tokens": 50,
    "temperature": 0.7,
    "stream": true
  }'

echo ""
echo ""
echo -e "${GREEN}✅ API 测试完成${NC}"
echo ""
