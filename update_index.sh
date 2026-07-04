#!/bin/bash
# 技术知识库索引自动更新钩子
# 用法: 在 ~/.claude/settings.json 的 Stop hook 中调用

set -e

TECH_KB="$HOME/Public/tech-knowledge"
INDEX_SCRIPT="$TECH_KB/build_index.py"

# 检查知识库是否存在
if [ ! -d "$TECH_KB" ]; then
    echo "⚠️  技术知识库不存在: $TECH_KB"
    exit 0
fi

# 检查是否有索引脚本
if [ ! -f "$INDEX_SCRIPT" ]; then
    echo "⚠️  索引脚本不存在: $INDEX_SCRIPT"
    exit 0
fi

# 检查知识库内容是否有变化
cd "$TECH_KB"

# 如果是 git 仓库，检查是否有新提交
if [ -d .git ]; then
    if git diff --quiet HEAD -- "*.md" 2>/dev/null; then
        # echo "✅ 知识库无变化，跳过索引更新"
        exit 0
    fi
fi

# 重建索引
echo "🔄 检测到知识库变化，重建索引..."
python3 "$INDEX_SCRIPT"

# 如果是 git 仓库，自动提交索引更新
if [ -d .git ]; then
    git add INDEX.md INDEX.json
    if ! git diff --cached --quiet; then
        git commit -m "chore: 更新索引 (auto)" --no-verify
        echo "✅ 索引已提交"
    fi
fi

echo "✅ 索引更新完成"
