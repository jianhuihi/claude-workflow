#!/bin/bash
# Plan Mode 退出后自动创建 feature 分支

# 检查是否在 git 仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    exit 0
fi

# 只在 main/master 分支时创建新分支
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
    exit 0
fi

# 生成分支名
date_prefix=$(date +%m%d)
branch_name="feature/${date_prefix}-task"

# 检查分支是否已存在，如果存在则添加序号
counter=1
original_name="$branch_name"
while git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; do
    branch_name="${original_name}-${counter}"
    ((counter++))
done

# 创建并切换
git checkout -b "$branch_name" 2>/dev/null && \
    echo "✅ Created branch: $branch_name" >&2

exit 0
