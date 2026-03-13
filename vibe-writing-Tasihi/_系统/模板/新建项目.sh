#!/bin/bash
# Vibe Writing - 新建项目脚本
# 用法：./新建项目.sh "项目名称"

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo "用法: $0 \"项目名称\""
    exit 1
fi

PROJECT_NAME="$1"
TEMPLATE_DIR="_系统/模板/新项目模板"
PROJECT_DIR="项目/$PROJECT_NAME"
CURRENT_DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}→ 创建新项目: $PROJECT_NAME${NC}"

# 检查模板目录
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "错误: 模板目录不存在: $TEMPLATE_DIR"
    exit 1
fi

# 创建项目目录
echo -e "${GREEN}  ✓ 创建目录结构${NC}"
mkdir -p "$PROJECT_DIR/知识卡片"
mkdir -p "$PROJECT_DIR/输出卡片"
mkdir -p "$PROJECT_DIR/白板备份"

# 复制模板文件
echo -e "${GREEN}  ✓ 复制模板文件${NC}"
cp "$TEMPLATE_DIR/项目信息.md" "$PROJECT_DIR/项目信息.md"
cp "$TEMPLATE_DIR/初始文档.md" "$PROJECT_DIR/初始文档.md"
cp "$TEMPLATE_DIR/内容白板.canvas.template" "$PROJECT_DIR/内容白板.canvas"

# 替换占位符
echo -e "${GREEN}  ✓ 替换占位符${NC}"
sed -i "s/{{项目名称}}/$PROJECT_NAME/g" "$PROJECT_DIR/项目信息.md"
sed -i "s/{{项目名称}}/$PROJECT_NAME/g" "$PROJECT_DIR/初始文档.md"
sed -i "s/{{创建日期}}/$CURRENT_DATE/g" "$PROJECT_DIR/项目信息.md"

# 清理剩余占位符
sed -i "s/{{目标读者}}/待填写/g" "$PROJECT_DIR/项目信息.md"
sed -i "s/{{核心主题}}/待填写/g" "$PROJECT_DIR/项目信息.md"
sed -i "s/{{项目定位描述}}/待填写/g" "$PROJECT_DIR/项目信息.md"

sed -i "s/{{主题背景描述}}/待填写/g" "$PROJECT_DIR/初始文档.md"
sed -i "s/{{核心问题1}}/待填写/g" "$PROJECT_DIR/初始文档.md"
sed -i "s/{{核心问题2}}/待填写/g" "$PROJECT_DIR/初始文档.md"
sed -i "s/{{核心问题3}}/待填写/g" "$PROJECT_DIR/初始文档.md"

echo ""
echo -e "${GREEN}✓ 项目创建完成！${NC}"
echo ""
echo "下一步："
echo "  1. 编辑 $PROJECT_DIR/初始文档.md，填写主题背景和问题"
echo "  2. 启动 Claude，说出你的主题"
echo "  3. 开始对话，生成知识卡片"
