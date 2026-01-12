# Claude Code 工作流

## 快速命令

| 命令 | 用途 |
|------|------|
| `/review` | 代码审查 |
| `/test` | 运行测试 |
| `/mr-check` | MR 前检查 |

---

## 任务分类

### Easy - 直接执行
简单修复、小改动 → 直接让 Claude 处理

### Medium - Plan Mode
1. `Shift+Tab` 两次进入 Plan Mode
2. 对齐方案后退出（自动创建 feature 分支）
3. Auto-accept 实现

### Hard - 人工引导
复杂架构变更 → 分步骤指导，Claude 辅助

---

## 开发流程

```
Plan Mode → 编码 → /review → /test → /mr-check → glab mr create
```

### 自动化
- **退出 Plan Mode**: 自动创建 `feature/MMDD-task` 分支
- **编码完成后**: Claude 自动调用 code-simplifier 简化代码

---

## 代码规范

- ES 模块优先
- 显式返回类型
- 避免嵌套三元
- 清晰性 > 简洁性

---

## Git 命令

```bash
glab mr create    # 创建 MR
glab mr list      # 列出 MR
glab mr merge     # 合并 MR
```
