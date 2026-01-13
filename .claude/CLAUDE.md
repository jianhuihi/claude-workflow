# claude-workflow 开发指南

此项目用于管理 Claude Code 的工作流配置（commands、agents、skills、hooks）。

## 组件类型

| 类型 | 位置 | 格式 |
|------|------|------|
| Command | `shared/commands/*.md` | Markdown prompt |
| Agent | `shared/agents/*.md` | Markdown prompt |
| Skill | `shared/skills/*/SKILL.md` | YAML frontmatter + Markdown |
| Hook | `shared/hooks/*.sh` | Shell 脚本 |

## 创建组件

### 创建 Command
直接创建 `shared/commands/<name>.md`，内容为 Claude 执行的 prompt。

### 创建 Agent
直接创建 `shared/agents/<name>.md`，内容为 Agent 的系统提示。

### 创建 Skill
使用 skill-creator 初始化：
```bash
python3 shared/skills/skill-creator/scripts/init_skill.py <name> --path shared/skills
```
然后编辑 `shared/skills/<name>/SKILL.md`。

### 创建 Hook
1. 创建 `shared/hooks/<name>.sh`
2. 在 `settings/settings.local.json` 中配置触发条件

## 发布流程

开发完成后，运行 `/publish` 一键完成：
1. 扫描组件，更新 README.md
2. Git commit
3. 运行 install.sh（安装到 ~/.claude 和 claude-gemini）
4. Git push

## 手动操作

如果需要手动操作：
```bash
# 安装到本地 Claude 环境
./install.sh

# 提交并推送
git add . && git commit -m "描述" && git push
```
