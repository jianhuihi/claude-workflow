# Claude Workflow

Claude Code 工作流配置管理，支持 Claude Pro 和 claude-gemini 两个环境。

## 安装

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/claude-workflow.git ~/.claude-workflow

# 运行安装
~/.claude-workflow/install.sh
```

## 更新

```bash
cd ~/.claude-workflow
git pull
./install.sh
```

## 包含内容

### 工作流 (CLAUDE.md)
8 阶段开发工作流：规划 → 编码 → 代码审查 → 测试 → 简化 → MR审查 → 创建MR → 发布

### Agents
- `code-reviewer` - 代码审查专家
- `code-simplifier` - 代码简化专家
- `codex-reviewer` - MR 前最终审查
- `test-runner` - 测试运行专家

### Hooks
- `create-feature-branch.sh` - Plan Mode 退出后自动创建 feature 分支

## 目录结构

```
claude-workflow/
├── install.sh              # 安装脚本
├── shared/
│   ├── CLAUDE.md          # 工作流指南
│   ├── agents/            # Agent 定义
│   ├── skills/            # Skills
│   └── hooks/             # Hook 脚本
└── settings/
    └── settings.local.json # Hooks 配置
```
