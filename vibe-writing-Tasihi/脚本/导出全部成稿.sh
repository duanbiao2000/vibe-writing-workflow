#!/bin/bash
# Vibe Writing - 导出所有最终成稿
# 用法：./脚本/导出全部成稿.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}→ 导出所有项目的最终成稿${NC}"
echo ""

EXPORT_DIR="exports"
mkdir -p "$EXPORT_DIR"

COUNT=0

# 查找所有项目目录
for PROJECT_DIR in 项目/*/; do
    PROJECT_NAME=$(basename "$PROJECT_DIR")

    # 查找最终成稿文件
    DRAFT_FILE=$(find "$PROJECT_DIR" -name "最终成稿-*.md" -type f 2>/dev/null | head -1)

    if [ -n "$DRAFT_FILE" ]; then
        DRAFT_BASENAME=$(basename "$DRAFT_FILE")
        EXPORT_PATH="$EXPORT_DIR/$DRAFT_BASENAME"

        cp "$DRAFT_FILE" "$EXPORT_PATH"
        echo -e "${GREEN}✓${NC} $PROJECT_NAME → $DRAFT_BASENAME"
        COUNT=$((COUNT + 1))
    fi
done

echo ""
echo -e "${GREEN}✓ 导出完成！共 $COUNT 个文件${NC}"
echo "目录: $EXPORT_DIR"
