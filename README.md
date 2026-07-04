# 技术知识库

日常开发中沉淀的技术经验，由 Claude Code Stop Hook 自动辅助生成。

## 分类

| 目录 | 领域 |
|------|------|
| `concurrency/` | 并发、锁、竞态、协程 |
| `networking/` | 网络协议、HTTP、WebSocket、RPC |
| `database/` | 数据库设计、索引、事务、迁移 |
| `frontend/` | 前端框架、渲染、状态管理 |
| `devops/` | CI/CD、容器、部署、监控 |
| `architecture/` | 设计模式、架构决策、系统设计 |
| `debugging/` | 调试技巧、踩坑记录、排查方法 |
| `llm-ops/` | LLM API 运维、模型验证、中转站评估 |
| `skills/` | 可复用 Agent 技能与跨项目工作流 |

## 文件格式

每篇文件使用 frontmatter + 固定结构：

```markdown
---
tags: [concurrency, go, race-condition]
date: 2026-06-12
project: 项目名（可选）
---

# 标题

## 现象
## 根因
## 修复
## 模式抽象
```

## 使用方式

本仓库通过 Claude Code 的 Stop Hook 自动维护。每次有价值的技术会话结束时，hook 会提示是否沉淀，确认后自动生成 Markdown 并 push。

### 沉淀标准

值得沉淀：
- 并发/竞态/死锁问题
- 架构设计权衡或模式选择
- 有意义的踩坑经验
- 性能优化的通用启发
- 框架/语言的非直觉行为
- 网络协议、数据库设计层面的技术决策

不沉淀：
- 纯业务逻辑变更
- 配置调整
- 简单 bug fix（拼写错误、少传参数）
- 纯 UI 调整
