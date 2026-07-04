# 技术知识库索引系统

## 索引文件

- **INDEX.md** - 人类可读的 Markdown 索引，包含分类、标签、摘要
- **INDEX.json** - 机器可读的 JSON 索引，包含完整元数据
- **build_index.py** - 索引生成脚本
- **update_index.sh** - 自动更新钩子脚本

## Agent 使用指南

### 快速查找文档

```bash
# 1. 直接阅读索引（推荐）
read ~/Public/tech-knowledge/INDEX.md

# 2. 按关键词搜索
grep -i "redis" ~/Public/tech-knowledge/INDEX.md
grep -i "websocket" ~/Public/tech-knowledge/INDEX.md

# 3. 按标签查找
grep -A 5 "#### \`concurrency\`" ~/Public/tech-knowledge/INDEX.md

# 4. 按分类浏览
grep -A 20 "#### llm-ops" ~/Public/tech-knowledge/INDEX.md
```

### 典型场景

**场景 1: 用户问"有没有类似的经验"**

```bash
# 先读索引，找相关文档
read ~/Public/tech-knowledge/INDEX.md

# 找到后阅读完整文档
read ~/Public/tech-knowledge/debugging/redis-cas-data-pollution.md
```

**场景 2: 排查问题前搜索已知案例**

```bash
# 用 grep 快速过滤
grep -i "websocket\|channel\|goroutine" ~/Public/tech-knowledge/INDEX.md
```

**场景 3: 验证 LLM API 中转站**

```bash
# 直接定位到 llm-ops 分类
read ~/Public/tech-knowledge/llm-ops/verify-api-proxy.md
```

## 文档贡献指南

### 新增文档时的元数据格式

```markdown
---
tags: [category, tech-stack, problem-type]
date: YYYY-MM-DD
project: 项目名（可选）
---

# 文档标题

## 现象
## 根因
## 修复
## 模式抽象
```

### 推荐的标签体系

| 维度 | 标签示例 |
|------|---------|
| 技术栈 | `go`, `python`, `redis`, `postgres`, `websocket` |
| 问题类型 | `concurrency`, `performance`, `debugging`, `architecture` |
| 解决方案 | `fallback`, `backpressure`, `error-recovery`, `caching` |
| 特定领域 | `llm`, `grpc`, `http`, `database` |

### 更新索引

```bash
# 手动重建索引
cd ~/Public/tech-knowledge
python3 build_index.py

# 或者运行自动更新脚本（会检查变化并提交）
./update_index.sh
```

## 自动化：集成到 Stop Hook

在 `~/.claude/settings.json` 中添加（可选）：

```json
{
  "hooks": {
    "Stop": [
      {
        "command": "~/Public/tech-knowledge/update_index.sh",
        "description": "自动更新技术知识库索引"
      }
    ]
  }
}
```

这样每次 Claude Code session 结束时，如果知识库有变化，索引会自动更新。

## 索引结构说明

### INDEX.md 结构

```
1. 快速检索
   - 按分类（architecture / concurrency / debugging 等）
   - 按标签（所有标签的反向索引）
2. 全部文档（按时间倒序）
   - 完整元数据 + 摘要
```

### INDEX.json 结构

```json
{
  "generated_at": "ISO timestamp",
  "total_docs": 9,
  "documents": [
    {
      "path": "llm-ops/verify-api-proxy.md",
      "title": "LLM API 中转站验证方案",
      "tags": ["llm", "api", "verification"],
      "date": "2026-06-25",
      "project": null,
      "summary": "...",
      "category": "llm-ops"
    }
  ]
}
```

## 维护说明

- 索引每次运行 `build_index.py` 时完全重建（不是增量）
- 扫描所有 `*.md` 文件（排除 `README.md` 和 `INDEX.md`）
- 从 frontmatter 提取 tags/date/project
- 从正文提取标题和前 200 字摘要
- 按分类和标签自动分组

## 示例输出

```
🔍 扫描知识库: /Users/a1/Public/tech-knowledge
📚 找到 9 篇文档
✅ 生成 Markdown 索引: INDEX.md
✅ 生成 JSON 索引: INDEX.json
✅ 索引生成完成
```

现在其他 agent 可以通过阅读 `INDEX.md` 快速发现所有已沉淀的技术经验。
