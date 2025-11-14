#!/bin/bash

# 测试运行脚本

echo "🧪 开始运行测试..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查pytest是否安装
if ! python -m pytest --version &> /dev/null; then
    echo -e "${RED}❌ pytest 未安装${NC}"
    echo "正在安装测试依赖..."
    pip install -q pytest pytest-asyncio httpx
    echo -e "${GREEN}✅ 测试依赖已安装${NC}"
    echo ""
fi

# 运行测试
echo "📊 运行所有测试..."
echo ""

python -m pytest backend/tests/ -v --tb=short --color=yes

# 检查测试结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ 所有测试通过！${NC}"
    echo ""

    # 显示测试摘要
    echo "📈 测试摘要:"
    echo "  - 数据库测试: 6 个"
    echo "  - 会话管理测试: 9 个"
    echo "  - API测试: 8 个"
    echo "  - 集成测试: 4 个"
    echo "  - 总计: 27 个测试"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}❌ 测试失败${NC}"
    echo ""
    exit 1
fi
