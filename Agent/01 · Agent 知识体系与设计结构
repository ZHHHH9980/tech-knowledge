# 01 · Agent 知识体系与设计结构

> 本章是整套文档的"地图"。读完你应该能：用统一词汇描述一个 Agent、知道主流架构谱系的来龙去脉、看见一个陌生 Agent 项目能迅速拆出它的五大件。

## 1.1 Agent 是什么 —— 一句话到一张图

LLM Agent 的最通俗定义：**能自己决定"下一步干什么"的 LLM 驱动程序**。更工程化的说法来自 Anthropic 2025 年那篇《Building Effective Agents》：

> An agent is a system where an LLM directs its own actions and tool use in a loop, based on environmental feedback. [1]

和 Workflow（固定流程、LLM 只做填空）的关键差别就是那个 "loop"：模型能看执行结果、改主意、换策略。

### Agent 的五大件

无论你看到的是 Claude Code、Hermes Agent、OpenClaw，还是豆包手机，拆开都逃不掉下面五件套。把任何一个 Agent 项目对着这张表过一遍，一般 10 分钟就能知道它强在哪、烂在哪。

| 组件 | 职责 | Claude Code 对应物 | Hermes 对应物 | 豆包手机对应物 |
| --- | --- | --- | --- | --- |
| **Planner / Reasoner** | 决定"下一步干什么" | LLM + `QueryEngine.run_turn()` [2] | LLM + `AIAgent.run_conversation()` [3] | 云侧大模型（思考/非思考双模式）[4] |
| **Memory** | 跨轮/跨会话的状态 | JSONL session + CLAUDE.md + memdir | SQLite+FTS5 `hermes_state.py` | Episodic + "全局记忆"特性 |
| **Tools** | 对外界做事的能力 | 43 个工具组、184 文件 [2] | 51 个注册工具（`registry.register`）[3] | 7 种系统动作：click/swipe/input/… [5] |
| **Executor / Sandbox** | 安全地把决策变现 | BashTool + permission ladder | Local/Docker/SSH/Daytona/Modal/OpenShell | 虚拟屏幕 + Auto Action 进程 |
| **Guardrail** | 止损 / 约束 | 三级权限 + 操作审批 | `check_fn` / `requires_env` 过滤 | 用户授权 + App 风控反制 |

### Agent 的心脏循环

最简的"心脏"图，所有 Agent 都长这样（感知 → 推理 → 行动 → 观察）：

```mermaid
flowchart LR
    U[User Input] --> P[Planner LLM]
    P -->|tool_call| T[Tool Executor]
    T --> O[Observation]
    O --> P
    P -->|final| R[Response to User]
    M[(Memory)] -.read.-> P
    P -.write.-> M
```

真正复杂的系统在这张基础图上做的事基本就四类：往 P 里塞更好的 Prompt、给 T 加更多工具和守卫、把 M 做分层、再给循环加出口条件（最大轮次 / 预算 / 压缩触发）。

## 1.2 主流架构谱系

2022–2026 年陆续出现了一批"Agent 架构"，但其实就是在上面那张心脏图上做变形。按出现顺序拉个表：

| 架构 | 提出时间 | 一句话定义 | 什么时候适合用 | 代表实现 |
| --- | --- | --- | --- | --- |
| **ReAct** | 2022-10 | Reason + Act 交替：思考一步 → 调一次工具 → 观察 → 再思考 [6] | 入门/大多数场景的默认 | LangChain ZeroShotAgent、OpenAI Function Calling |
| **Plan-and-Execute** | 2023-05 | 先全量规划再一步步执行，中途可 replan | 长任务、工具昂贵 | LangChain PlanAndExecute |
| **Reflexion** | 2023-03 | 执行失败 → 写 Self-Reflection → 重试 [7] | 有明确成败信号的任务（代码/游戏） | Reflexion 原论文仓库 |
| **Tree-of-Thoughts (ToT)** | 2023-05 | 把推理展开成一棵树，带回溯和剪枝 | 需要深搜（数学/24 点/规划） | princeton-nlp/tree-of-thought-llm |
| **LATS** | 2023-10 | ToT + MCTS + 价值评估，更像 AlphaZero | 长程、带反馈、可评分 | andyz245/LanguageAgentTreeSearch |
| **CodeAct** | 2024-02 | 把工具调用统一成写 Python 代码 | 数据密集、工具组合复杂 | xingyaoww/code-act、OpenDevin |
| **Agentic RAG** | 2024 起 | 在 RAG 循环里加"要不要再查一次"的决策 | 长文档问答、知识库助手 | Self-RAG、Corrective-RAG |
| **Harness Engineering** | 2026 起 | 把模型、会话、沙盒三层解耦，模型当"能换脑"的 CPU [8][9] | 长程自主任务、SaaS 级 Agent | Anthropic Managed Agents、OpenAI Codex |

### 两条互补的主线

如果嫌上面表太散，记住两条主线就够了：

1. **单 Agent 变聪明线**：Zero-shot → ReAct → Reflexion → ToT → LATS。核心是让 LLM 自己更擅长"推理 + 修正"。
2. **系统变结实线**：Function Calling → MCP → Harness Engineering。核心是把工程边界、沙盒、记忆、会话做扎实，让模型可以被替换升级。

2026 年的明显趋势是第二条线跑得更快 —— 因为模型本身的推理能力提升在减速，但工程落地还有大量红利。Anthropic 的 Managed Agents 博客里有一句话很精准："Harnesses encode assumptions about what Claude can't do on its own. However, those assumptions need to be frequently questioned because they can go stale as models improve."[8]

## 1.3 推理范式对比

把几个最常混淆的推理技术放一起对比：

| 范式 | 需要外部工具 | 需要多轮 | 代表 Prompt 结构 | 常见坑 |
| --- | --- | --- | --- | --- |
| **Chain-of-Thought (CoT)** | 否 | 否 | "Let's think step by step" | 只适合模型自己能算出来的问题 |
| **ReAct** | 是 | 是 | Thought → Action → Observation × N | 工具幻觉（编出不存在的工具名） |
| **Reflexion** | 可选 | 是（含失败重试） | Attempt → Feedback → Reflection → Retry | 要求任务有可验证的成败 |
| **Self-RAG / CRAG** | 是（检索） | 是 | Retrieve → Grade → Use/Rewrite | 评分模型本身不准 |
| **Test-time Scaling** (o1/R1) | 否 | 内部的，对外单轮 | 模型自己生成长 thinking | 推理 token 昂贵 |

## 1.4 工具调用的协议演进

| 时期 | 方式 | 典型问题 |
| --- | --- | --- |
| 2022 前 | 字符串模式匹配（"Action: search[...]"）| 模型输出不规范，正则容易挂 |
| 2023 | OpenAI Function Calling（JSON Schema） | schema 是调用方私有，跨应用复制粘贴 |
| 2024 | 各家 Function Calling 百花齐放 | 切换模型成本高 |
| 2025 起 | **MCP（Model Context Protocol）** | 成为事实标准；参见 08 章深潜 |

MCP 由 Anthropic 2024 年底开源，核心是把工具、资源、提示模板三件事标准化 [10]。到 2026 年，Claude Code、Cursor、Windsurf、ChatGPT Desktop、Codex CLI、Hermes 等主流 Agent 全部原生支持，一个 MCP 服务器能同时被多端调用 —— 这个生态价值最大。

## 1.5 设计结构地图

如果你要自己从 0 做一个 Agent，按下面这张优先级图建地基就不会跑偏（从下到上）：

```mermaid
flowchart BT
    L0[Model + API 调用] --> L1[ToolRegistry: 工具注册/schema/dispatch]
    L1 --> L2[AgentLoop: ReAct/Plan-Act + 终止条件]
    L2 --> L3[Prompt Layer: 静态/动态/Cache 边界]
    L2 --> L4[Memory Layer: 会话/长期/检索]
    L2 --> L5[Executor: Sandbox/Permission/审批]
    L3 --> L6[Context Compressor: 裁剪/摘要/pair 修复]
    L4 --> L6
    L5 --> L7[Observability: trace/cost/eval]
    L6 --> L8[Gateway: CLI/IDE/IM/API 多入口]
    L7 --> L8
```

一个常见误区是先去堆工具（L1 往上直接跳 L8），结果 L3/L4/L6/L7 全是缺的，随着对话变长系统立刻垮掉 —— 这是 2024 年大量 Agent demo 到 2025 年半死不活的主要原因。

## 1.6 阅读本系列的建议顺序

- 先看这一章建立词汇表
- 然后看 `03-claude-code-leak-analysis.md`（最成熟范本）
- 再看 `04-hermes-agent-internals.md`（开源可读的对照组）
- 需要把知识落地到"为什么要沙盒" → 读 `05-openclaw-internals-security.md` + `10-agent-security-threats.md`
- 关心工具选型 → 读 `11-coding-agent-landscape.md`
- 写自己的 Agent → 读 `02-agent-best-practices.md` + `07-token-memory-multi-agent.md` + `09-ai-dev-paradigms.md`

## 参考来源

访问日期：2026-04-18。

1. Anthropic Engineering. *Building Effective Agents*. https://www.anthropic.com/engineering/building-effective-agents
2. 子昕. 《Claude Code 源码意外泄露，我连夜拆了个底朝天：29 个子系统、6 层压缩、100+ 隐藏命令》. 技术栈 2026-04. https://jishuzhan.net/article/2039650796173266946
3. 袋鱼不重. 《我把 Hermes Agent 源码扒了个底朝天：它不是"又一个 AI Agent"，而是在认真造一套代理操作系统》. 技术栈 2026-04. https://jishuzhan.net/article/2043600744415297538
4. 《从豆包手机谈起：GUI 操控或许并非端侧智能的终局》. 搜狐 2026-04. https://www.sohu.com/a/968588095_827544
5. zai-org/Open-AutoGLM Issue #36 讨论. https://github.com/zai-org/Open-AutoGLM/issues/36
6. Yao S. et al. *ReAct: Synergizing Reasoning and Acting in Language Models*. 2022. https://arxiv.org/abs/2210.03629
7. Shinn N. et al. *Reflexion: Language Agents with Verbal Reinforcement Learning*. 2023. https://arxiv.org/abs/2303.11366
8. Anthropic Engineering. *Scaling Managed Agents: Decoupling the brain from the hands*. 2026-04-10. https://www.anthropic.com/engineering/managed-agents
9. Lopopolo R. *Harness engineering: using Codex in an agent-first world*. OpenAI 2026-02-11. https://openai.com/index/harness-engineering/
10. Model Context Protocol 官方文档. https://modelcontextprotocol.io
