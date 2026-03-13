#!/bin/bash
# Vibe Writing - 归档项目脚本
# 用法：./脚本/归档项目.sh "项目名称"

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo "用法: $0 \"项目名称\""
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="项目/$PROJECT_NAME"
CURRENT_DATE=$(date +%Y-%m)
ARCHIVE_DIR="项目/_归档/$CURRENT_DATE"

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}✗ 项目不存在: $PROJECT_NAME${NC}"
    exit 1
fi

# 检查是否有最终成稿
DRAFT_FILE=$(find "$PROJECT_DIR" -name "最终成稿-*.md" -type f 2>/dev/null | head -1)
if [ -z "$DRAFT_FILE" ]; then
    echo -e "${YELLOW}⚠ 警告: 未找到最终成稿文件${NC}"
    read -p "确定要归档吗？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo -e "${BLUE}→ 归档项目: $PROJECT_NAME${NC}"
echo ""

# 创建归档目录
mkdir -p "$ARCHIVE_DIR"

# 移动项目
echo -e "${GREEN}✓${NC} 移动到: $ARCHIVE_DIR/$PROJECT_NAME"
mv "$PROJECT_DIR" "$ARCHIVE_DIR/$PROJECT_NAME"

echo ""
echo -e "${GREEN}✓ 归档完成！${NC}"
echo ""
echo "归档位置: $ARCHIVE_DIR/$PROJECT_NAME"
echo ""
echo "如需恢复，执行："
echo "  mv \"$ARCHIVE_DIR/$PROJECT_NAME\" \"项目/\""
