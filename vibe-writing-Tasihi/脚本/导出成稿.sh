#!/bin/bash
# Vibe Writing - 导出最终成稿脚本
# 用法：./脚本/导出成稿.sh "项目名称"

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 \"项目名称\""
    echo ""
    echo "示例:"
    echo "  $0 \"Claude和GPT的区别\""
    echo "  $0 \"每日写作重塑大脑\""
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="项目/$PROJECT_NAME"
EXPORT_DIR="exports"

# 检查项目目录
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠ 项目不存在: $PROJECT_NAME${NC}"
    exit 1
fi

echo -e "${BLUE}→ 导出项目: $PROJECT_NAME${NC}"

# 创建导出目录
mkdir -p "$EXPORT_DIR"

# 查找最终成稿文件
DRAFT_FILE=$(find "$PROJECT_DIR" -name "最终成稿-*.md" -type f | head -1)

if [ -z "$DRAFT_FILE" ]; then
    echo -e "${YELLOW}⚠ 未找到最终成稿文件${NC}"
    echo "请确保项目中有 '最终成稿-xxx.md' 文件"
    exit 1
fi

# 获取文件名
DRAFT_BASENAME=$(basename "$DRAFT_FILE")
EXPORT_PATH="$EXPORT_DIR/$DRAFT_BASENAME"

# 复制文件
cp "$DRAFT_FILE" "$EXPORT_PATH"

echo -e "${GREEN}✓ 导出成功！${NC}"
echo ""
echo "文件位置: $EXPORT_PATH"
echo ""
echo "其他操作:"
echo "  - 转换为 PDF: pandoc \"$EXPORT_PATH\" -o \"${EXPORT_PATH%.md}.pdf\""
echo "  - 转换为 HTML: pandoc \"$EXPORT_PATH\" -o \"${EXPORT_PATH%.md}.html\""
