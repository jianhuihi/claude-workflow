# 开发工作流指南

## 推荐工作流程

### 1. 规划阶段
- 使用 Plan Mode 确认实现方案（Shift+Tab 两次）
- 明确需求和验收标准
- 设计技术方案
- **退出 Plan Mode 后自动创建 feature 分支**

### 2. 编码阶段
- 按计划实现功能
- 保持小步提交
- 编写必要的测试

### 3. 代码审查阶段
编码完成后运行：
```
/review
```

### 4. 调试测试阶段
- 修复审查发现的问题
- 运行测试：
```
/test
```
- 本地验证功能正常

### 5. 代码简化阶段
测试通过后，Claude 会自动调用 code-simplifier 子代理简化代码。
也可以手动请求："请简化一下刚才的代码"

### 6. MR 前审查阶段
准备提交 MR 前运行：
```
/mr-check
```

### 7. 创建 MR
- 使用 `glab mr create` 创建 Merge Request
- 等待 CI 检查
- 处理 Review 意见

### 8. 合并发布
- 审查通过后合并
- 打包验证
- 发布上线

---

## 命令速查

### Commands（用户主动触发）

| 命令 | 说明 | 使用时机 |
|------|------|----------|
| `/review` | 代码审查 | 编码完成后 |
| `/test` | 运行测试 | 需要运行测试时 |
| `/mr-check` | MR 前最终审查 | 创建 MR 前 |

### Agents（Claude 自动调用）

| Agent | 说明 | 触发方式 |
|-------|------|----------|
| `code-simplifier` | 代码简化 | Claude 完成编码后自动调用 |

### Hooks（事件自动触发）

| Hook | 说明 | 触发事件 |
|------|------|----------|
| `create-feature-branch` | 自动创建 feature 分支 | 退出 Plan Mode |

---

## 任务分类

### Easy（一次完成）
- 简单修复、小功能
- 直接让 Claude 处理，auto-accept

### Medium（需要规划）
- 中等复杂度功能
- 使用 Plan Mode 对齐方案
- 确认后 auto-accept 实现

### Hard（需要引导）
- 复杂架构变更
- 分步骤指导 Claude
- 人工驾驶，Claude 辅助

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
