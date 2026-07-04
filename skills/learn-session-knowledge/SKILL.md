---
name: learn-session-knowledge
description: Use when a user asks to learn, remember, capture lessons, record reusable workflow knowledge, preserve a session discovery, or make future agents able to reuse current work.
---

# Learn Session Knowledge

## 核心原则

先找当前项目自己的沉淀协议；只有项目没有协议时，才使用本 skill 的 fallback 规则。沉淀只记录未来 agent 需要复用、且无法从代码或 git 历史直接看出的知识。

## 协议读取顺序

1. 读取当前项目的 `docs/rules/learning-protocol.md`。
2. 如果不存在，检查项目 `AGENTS.md`、`CLAUDE.md`、`WORKSPACE.md`、`workspace.yaml` 中是否指向沉淀协议或长期记忆规则。
3. 如果项目协议存在，以项目协议为唯一规则来源，不再套用 fallback。
4. 如果项目协议不存在，使用下方 fallback。

## Fallback 触发条件

满足任一条件才沉淀：

- 为理解一条链路读了 3 个以上文件。
- 排查完 bug 并定位到根因。
- 发现外部依赖、平台、浏览器、CI、登录态、权限等 failure mode。
- 理清模块职责边界、状态流转或关键分支。
- 为回答问题做了大量搜索、源码阅读或实验。
- 踩到非显而易见、下个 agent 可能再踩的坑。
- 发现可跨项目复用的工具使用方式或环境约束。

如果都不满足，直接回复：`本次无需沉淀`。

## 归属判断

判断标准：换一个人接手同类任务，他需要知道这个吗？

| 类型 | 写入位置 | 例子 |
| --- | --- | --- |
| 项目级知识 | 相关代码同级 README 或项目约定文档 | 调用链、字段含义、部署排查 playbook |
| 跨项目流程 | 共享知识库或 `skills/<name>/SKILL.md` | GitHub 浏览器写文件、learn 工作流 |
| Codex/session memory | 记忆工具；没有持久记忆工具时在最终回复给出摘要 | 用户偏好、账号访问习惯、agent 行为纠偏 |

两者都有时，项目文件只写代码/系统相关结论；个人排查路径、工具习惯、用户偏好放 memory 或共享 skill。

## 执行流程

1. 确认目标目录的 git 基线：`git status --short --branch`。如果 dirty，只在用户要求或任务相关范围内新增/修改文件。
2. 读取协议和附近 README，避免重复已有规则。
3. 回顾本次会话，按触发条件判断是否值得沉淀。
4. 决定归属和文件路径。
5. 写入前明确不记录临时会话 ID、未验证猜测、工具输出流水账。
6. 写入内容保持短、可执行、可复用。
7. 写入后验证文件存在、格式正确，并说明路径和为什么满足沉淀条件。

## 项目级沉淀格式

优先放在相关代码附近，例如：

```text
internal/liveroom/logic/README_shutdown.md
src/pages/live-room/README_reconnect_flow.md
```

按需使用这些章节，不要填空话：

```markdown
# 主题

## 调用链
## 关联文件
## 边界条件
## 已知问题
## 排查手法
```

## 知识库 Markdown 格式

共享知识库文章使用 frontmatter：

```markdown
---
tags: [skill, workflow]
date: YYYY-MM-DD
project: optional-project
---

# 标题

## 现象
## 根因
## 修复
## 模式抽象
```

## Skill 格式

可复用 agent 技能放在：

```text
skills/<skill-name>/SKILL.md
```

`SKILL.md` 必须包含：

- `name`: 小写字母、数字、短横线。
- `description`: 只写触发条件，以 `Use when...` 开头；不要把执行流程塞进 description。
- 正文：核心约束、工作流、失败模式、验证方式。

## 不要记录

- 一次性的 session id、临时浏览器 profile、临时端口。
- 代码本身能直接读懂的逻辑。
- 尚未确认的猜测。
- `git log` / `git blame` 能直接查到的信息。
- 已经写在项目规则文件里的稳定规则。
- 纯流水账、长命令输出、没有复用价值的过程叙述。

## 常见错误

- 只写“Check for `docs/rules/learning-protocol.md`”，却没有说明协议优先级、fallback、归属规则和不记录清单。
- 把跨项目流程写进单个业务项目，导致其他 agent 找不到。
- 在 dirty 仓库里顺手改无关文件。
- 直接改 `AGENTS.md` / `CLAUDE.md`，除非用户明确要求维护稳定规则。
- 把 skill 写成故事，而不是未来 agent 可以执行的操作指南。
