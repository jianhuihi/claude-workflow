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

# 4. 安装 scripts 到 /usr/local/bin
if [ -d "$SOURCE_DIR/scripts" ]; then
    echo -e "${YELLOW}Installing scripts to /usr/local/bin...${NC}"
    for script in "$SOURCE_DIR/scripts/"*; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            # 如果已存在，跳过安装
            if [ -f "/usr/local/bin/$script_name" ]; then
                echo -e "${GREEN}  ✓ $script_name (已存在)${NC}"
            elif [ -w "/usr/local/bin" ]; then
                cp -f "$script" "/usr/local/bin/$script_name"
                chmod +x "/usr/local/bin/$script_name"
                echo -e "${GREEN}  ✓ $script_name${NC}"
            elif sudo -n true 2>/dev/null; then
                sudo cp -f "$script" "/usr/local/bin/$script_name"
                sudo chmod +x "/usr/local/bin/$script_name"
                echo -e "${GREEN}  ✓ $script_name${NC}"
            else
                echo -e "${RED}  ✗ $script_name (需要 sudo 权限)${NC}"
                echo -e "${YELLOW}    手动安装: sudo cp $script /usr/local/bin/${NC}"
            fi
        fi
    done
fi

# 5. 安装 superpowers 插件（通过官方插件系统）
install_superpowers() {
    local CLI_CMD=$1
    local NAME=$2

    if ! command -v "$CLI_CMD" &> /dev/null; then
        return 0
    fi

    echo -e "${YELLOW}Installing superpowers plugin for $NAME...${NC}"

    # 添加市场
    local marketplace_output
    marketplace_output=$($CLI_CMD plugin marketplace add obra/superpowers-marketplace 2>&1) || true
    if echo "$marketplace_output" | grep -q "already installed"; then
        echo -e "${GREEN}  ✓ superpowers-marketplace (已存在)${NC}"
    elif echo "$marketplace_output" | grep -q "Successfully"; then
        echo -e "${GREEN}  ✓ Added superpowers-marketplace${NC}"
    else
        echo -e "${RED}  ✗ Failed to add marketplace${NC}"
    fi

    # 安装插件
    local plugin_output
    plugin_output=$($CLI_CMD plugin install superpowers@superpowers-marketplace 2>&1) || true
    if echo "$plugin_output" | grep -q "Successfully"; then
        echo -e "${GREEN}  ✓ superpowers plugin${NC}"
    else
        echo -e "${RED}  ✗ Failed to install superpowers plugin${NC}"
    fi
}

install_superpowers "claude" "Claude Pro"
install_superpowers "claude-gemini" "claude-gemini"

# 6. 检查 claude-gemini 环境
if [ ! -d "$GEMINI_DIR" ]; then
    if command -v claude-gemini &> /dev/null; then
        echo ""
        echo -e "${YELLOW}提示: 首次使用请运行 'claude-gemini' 初始化配置目录${NC}"
        echo -e "${YELLOW}      然后重新运行 install.sh 安装 claude-gemini 环境${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Installed components:"
echo "  - CLAUDE.md (工作流指南)"
echo "  - commands/ (/review, /test, /mr-check, /audit)"
echo "  - agents/ (code-simplifier)"
echo "  - skills/"
echo "  - hooks/ (create-feature-branch.sh)"
echo "  - scripts/ (claude-gemini)"
echo "  - superpowers plugin (/superpowers:brainstorm, /superpowers:write-plan)"
echo ""
echo "To update later: ~/.claude-workflow/install.sh"
echo "To sync local changes back: cd ~/.claude-workflow && git add . && git commit && git push"
