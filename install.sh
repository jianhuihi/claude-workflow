#!/bin/bash
set -e

REPO_DIR="$HOME/.claude-workflow"
CLAUDE_DIR="$HOME/.claude"
GEMINI_DIR="$HOME/.config/claude-gemini/Claude"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Claude Workflow Installer${NC}"
echo "=========================="

# 获取脚本所在目录（支持从任意位置运行）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 如果从仓库目录运行，使用当前目录
if [ -f "$SCRIPT_DIR/shared/CLAUDE.md" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
else
    SOURCE_DIR="$REPO_DIR"
fi

# 1. 如果 ~/.claude-workflow 不存在且不是从那里运行，先复制过去
if [ "$SCRIPT_DIR" != "$REPO_DIR" ] && [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}Copying to ~/.claude-workflow...${NC}"
    cp -r "$SCRIPT_DIR" "$REPO_DIR"
    SOURCE_DIR="$REPO_DIR"
fi

# 2. 安装函数（物理复制）
install_to_dir() {
    local TARGET_DIR=$1
    local NAME=$2

    echo -e "${YELLOW}Installing to $NAME ($TARGET_DIR)...${NC}"

    # 创建必要目录
    mkdir -p "$TARGET_DIR/hooks"
    mkdir -p "$TARGET_DIR/agents"
    mkdir -p "$TARGET_DIR/skills"
    mkdir -p "$TARGET_DIR/commands"

    # 物理复制（覆盖已存在的文件）
    cp -f "$SOURCE_DIR/shared/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    cp -rf "$SOURCE_DIR/shared/commands/"* "$TARGET_DIR/commands/" 2>/dev/null || true
    cp -rf "$SOURCE_DIR/shared/agents/"* "$TARGET_DIR/agents/" 2>/dev/null || true
    cp -rf "$SOURCE_DIR/shared/skills/"* "$TARGET_DIR/skills/" 2>/dev/null || true
    cp -rf "$SOURCE_DIR/shared/hooks/"* "$TARGET_DIR/hooks/" 2>/dev/null || true

    # 处理 settings.local.json
    if [ -f "$TARGET_DIR/settings.local.json" ]; then
        # 已存在配置，用 jq 合并（保留现有 permissions，添加/更新 hooks）
        if command -v jq &> /dev/null; then
            echo -e "${YELLOW}  Merging settings.local.json...${NC}"
            jq -s '.[0] * .[1]' "$TARGET_DIR/settings.local.json" "$SOURCE_DIR/settings/settings.local.json" > /tmp/merged_settings.json
            mv /tmp/merged_settings.json "$TARGET_DIR/settings.local.json"
        else
            echo -e "${RED}  Warning: jq not installed, skipping settings merge${NC}"
            echo -e "${RED}  Run: brew install jq${NC}"
        fi
    else
        # 不存在，直接复制
        cp -f "$SOURCE_DIR/settings/settings.local.json" "$TARGET_DIR/settings.local.json"
    fi

    # 设置脚本可执行权限
    chmod +x "$TARGET_DIR/hooks/"*.sh 2>/dev/null || true

    echo -e "${GREEN}  ✓ $NAME installed${NC}"
}

# 3. 安装到两个环境
install_to_dir "$CLAUDE_DIR" "Claude Pro (~/.claude)"

if [ -d "$GEMINI_DIR" ]; then
    install_to_dir "$GEMINI_DIR" "claude-gemini"
else
    echo -e "${YELLOW}Skipping claude-gemini (directory not found)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Installed components:"
echo "  - CLAUDE.md (工作流指南)"
echo "  - commands/ (/review, /test, /mr-check)"
echo "  - agents/ (code-simplifier)"
echo "  - skills/"
echo "  - hooks/ (create-feature-branch.sh)"
echo ""
echo "To update later: ~/.claude-workflow/install.sh"
echo "To sync local changes back: cd ~/.claude-workflow && git add . && git commit && git push"
