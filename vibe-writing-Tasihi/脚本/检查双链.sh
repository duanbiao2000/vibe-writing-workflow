#!/bin/bash
# Vibe Writing - 检查失效双链
# 用法：./脚本/检查双链.sh

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}→ 检查 Obsidian 双链失效情况${NC}"
echo ""

FOUND_BROKEN=0

# 递归检查所有 .md 文件中的双链
find "项目" -name "*.md" -type f | while read -r file; do
    # 提取所有双链 [[...]]
    grep -o '\[\[[^]]*\]\]' "$file" 2>/dev/null | while read -r link; do
        # 提取链接路径（移除 [[ ]] 和显示文本部分）
        link_path=$(echo "$link" | sed 's/\[\[//' | sed 's/\]\]//' | cut -d'|' -f1)

        # 跳过外部链接
        if [[ "$link_path" == http* ]]; then
            continue
        fi

        # 查找目标文件
        target_file=$(find "项目" -name "${link_path}.md" -o -name "${link_path}" 2>/dev/null | head -1)

        if [ -z "$target_file" ]; then
            echo -e "${RED}✗${NC} 失效链接: $link_path"
            echo "  来源: $file"
            FOUND_BROKEN=1
        fi
    done
done

echo ""

if [ $FOUND_BROKEN -eq 0 ]; then
    echo -e "${GREEN}✓ 没有发现失效的双链${NC}"
else
    echo -e "${YELLOW}⚠ 发现失效的双链，请修复${NC}"
    echo ""
    echo "常见原因："
    echo "  1. 文件被重命名或删除"
    echo "  2. 链接路径错误"
    echo "  3. 大小写不匹配"
fi
