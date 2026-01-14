# Claude Workflow

Claude Code 工作流配置管理，支持 Claude Pro 和 claude-gemini 两个环境。

## 安装

```bash
# 克隆仓库（包含 submodules）
git clone --recurse-submodules https://github.com/jianhuihi/claude-workflow.git ~/.claude-workflow

# 运行安装
~/.claude-workflow/install.sh
```

## 更新

```bash
cd ~/.claude-workflow
git pull --recurse-submodules
./install.sh
```

## 包含内容

### 工作流 (CLAUDE.md)
8 阶段开发工作流：规划 → 编码 → 代码审查 → 测试 → 简化 → MR审查 → 创建MR → 发布

### Commands（用户主动触发）
| 命令 | 说明 |
|------|------|
| `/audit` | 代码审计 |
| `/mr-check` | MR 前最终审查 |
| `/review` | 代码审查 |
| `/test` | 运行测试 |

### Agents（Claude 自动调用）
| Agent | 说明 |
|-------|------|
| `code-simplifier` | Claude 完成编码后自动简化代码 |

### Skills（功能扩展）
| Skill | 说明 |
|-------|------|
| `agent-browser` | 浏览器自动化（基于 Playwright） |
| `algorithmic-art` | 算法艺术生成 |
| `brand-guidelines` | 品牌设计指南 |
| `canvas-design` | Canvas 设计工具 |
| `doc-coauthoring` | 文档协作编写 |
| `docx` | Word 文档生成 |
| `frontend-design` | 前端 UI/UX 设计 |
| `internal-comms` | 内部沟通模板 |
| `mcp-builder` | MCP 协议构建器 |
| `pdf` | PDF 文件生成 |
| `planning-with-files` | 文件规划工具 |
| `pptx` | PowerPoint 演示文稿生成 |
| `skill-creator` | 快速创建和打包新的 Skill |
| `slack-gif-creator` | Slack GIF 生成器 |
| `theme-factory` | 主题样式工厂 |
| `web-artifacts-builder` | Web 组件构建器 |
| `webapp-testing` | Web 应用测试工具 |
| `xlsx` | Excel 表格生成 |

### Hooks（事件自动触发）
| Hook | 说明 |
|------|------|
| `create-feature-branch.sh` | 退出 Plan Mode 后自动创建 feature 分支 |

### Scripts（环境管理）
| 脚本 | 说明 |
|------|------|
| `claude-gemini` | Claude API 代理环境 wrapper（隔离 Pro 配置） |

### Plugins（第三方插件）
| 插件 | 说明 |
|------|------|
| `superpowers` | 完整的软件开发工作流（brainstorming, TDD, planning 等） |

## 目录结构

```
claude-workflow/
├── install.sh              # 安装脚本
├── scripts/                # 环境管理脚本
│   └── claude-gemini       # API 代理环境 wrapper
├── shared/
│   ├── CLAUDE.md          # 工作流指南
│   ├── commands/          # 斜杠命令（用户触发）
│   ├── agents/            # 子代理（Claude 调用）
│   ├── skills/            # Skills
│   ├── hooks/             # Hook 脚本
│   └── plugins/           # 第三方插件 (git submodules)
│       └── superpowers/   # 软件开发工作流
└── settings/
    └── settings.local.json # Hooks 配置
```

## 设计理念

| 类型 | 触发者 | 适用场景 |
|------|--------|----------|
| Commands | 用户主动 `/xxx` | 频繁重复的内循环操作 |
| Agents | Claude 自动调用 | 复杂/需要隔离的任务 |
| Hooks | 事件自动触发 | 流程自动化 |
