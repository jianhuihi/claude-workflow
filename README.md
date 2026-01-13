# Claude Workflow

Claude Code 工作流配置管理，支持 Claude Pro 和 claude-gemini 两个环境。

## 安装

```bash
# 克隆仓库
git clone https://github.com/jianhuihi/claude-workflow.git ~/.claude-workflow

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

### Commands（用户主动触发）
| 命令 | 说明 |
|------|------|
| `/review` | 代码审查 |
| `/test` | 运行测试 |
| `/mr-check` | MR 前最终审查 |

### Agents（Claude 自动调用）
| Agent | 说明 |
|-------|------|
| `code-simplifier` | Claude 完成编码后自动简化代码 |

### Skills（功能扩展）
| Skill | 说明 |
|-------|------|
| `skill-creator` | 快速创建和打包新的 Skill |
| `agent-browser` | 浏览器自动化（基于 Playwright） |

### Hooks（事件自动触发）
| Hook | 说明 |
|------|------|
| `create-feature-branch.sh` | 退出 Plan Mode 后自动创建 feature 分支 |

## 目录结构

```
claude-workflow/
├── install.sh              # 安装脚本
├── shared/
│   ├── CLAUDE.md          # 工作流指南
│   ├── commands/          # 斜杠命令（用户触发）
│   │   ├── review.md
│   │   ├── test.md
│   │   └── mr-check.md
│   ├── agents/            # 子代理（Claude 调用）
│   │   └── code-simplifier.md
│   ├── skills/            # Skills
│   └── hooks/             # Hook 脚本
└── settings/
    └── settings.local.json # Hooks 配置
```

## 设计理念

| 类型 | 触发者 | 适用场景 |
|------|--------|----------|
| Commands | 用户主动 `/xxx` | 频繁重复的内循环操作 |
| Agents | Claude 自动调用 | 复杂/需要隔离的任务 |
| Hooks | 事件自动触发 | 流程自动化 |
