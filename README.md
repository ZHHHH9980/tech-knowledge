# 技术知识库

日常开发中沉淀的技术经验，由 Claude Code Stop Hook 自动辅助生成。

## 分类

| 目录 | 领域 |
|------|------|
| `Agent/` | Agent 架构、工程实践、安全、生态与岗位学习路线 |
| `concurrency/` | 并发、锁、竞态、协程 |
| `networking/` | 网络协议、HTTP、WebSocket、RPC |
| `database/` | 数据库设计、索引、事务、迁移 |
| `frontend/` | 前端框架、渲染、状态管理 |
| `devops/` | CI/CD、容器、部署、监控 |
| `architecture/` | 设计模式、架构决策、系统设计 |
| `debugging/` | 调试技巧、踩坑记录、排查方法 |
| `llm-ops/` | LLM API 运维、模型验证、中转站评估 |
| [`skills/`](skills/README.md) | 按 FE、BE、技术方案及工作流选择技能 |

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

## 沉淀前检查

- 只记录已验证且可复用的结论；先搜索已有文章，优先更新已有材料。
- 项目专属代码路径、接口与排障经验放项目附近的文档；临时会话事实不写入长期规则。
- 跨项目内容按已有分类存放，说明适用场景、根因或决策、操作方法、失败模式与验证方式。
- 新增或修改后核对内容与导航；修改规则文件或发布到远端仍遵循本次授权。

## 外部阅读索引

### 数据库设计

[Database design basics（数据库设计基础）— Microsoft Support](https://support.microsoft.com/en-us/access/database-design-basics)

内容：从需求整理、表与字段划分，到主键、表关系、中间表和第一至第三范式，并用样例数据检验设计。

适用场景：关系型数据库建模入门，以及表结构设计前的基础复习。原文以 Access 桌面数据库为例。
