# 开发工作流指南

## 推荐工作流程

### 1. 规划阶段
- 使用 Plan Mode 确认实现方案
- 明确需求和验收标准
- 设计技术方案

### 2. 编码阶段
- 按计划实现功能
- 保持小步提交
- 编写必要的测试

### 3. 代码审查阶段
编码完成后运行：
> 请运行 code-reviewer agent 审查我刚才的代码改动

### 4. 调试测试阶段
- 修复审查发现的问题
- 运行测试确保通过
- 本地验证功能正常

### 5. 代码简化阶段
测试通过后运行：
> 请运行 code-simplifier agent 看看代码能否简化

### 6. MR 前审查阶段
准备提交 MR 前运行：
> 请运行 codex-reviewer agent 做最终检查

### 7. 创建 MR
- 使用 `glab mr create` 创建 Merge Request
- 等待 CI 检查
- 处理 Review 意见

### 8. 合并发布
- 审查通过后合并
- 打包验证
- 发布上线

---

## Agent 触发命令

| 触发方式 | 说明 | 使用时机 |
|---------|------|---------|
| `请运行 code-reviewer` | 代码审查 | 编码完成后 |
| `请运行 code-simplifier` | 代码简化 | 测试通过后 |
| `请运行 codex-reviewer` | MR 前最终审查 | 创建 MR 前 |
| `请运行 test-runner` | 运行测试 | 需要运行测试时 |

---

## GitLab 命令

| 命令 | 说明 |
|------|------|
| `glab mr create` | 创建 Merge Request |
| `glab mr list` | 列出 MR |
| `glab mr view` | 查看 MR 详情 |
| `glab mr merge` | 合并 MR |

---

## 代码风格

- 优先使用 ES 模块
- 函数需要显式返回类型
- 避免嵌套三元运算符
- 选择清晰性优于简洁性
