# 技术知识库索引

最后更新: 2026-07-04 16:03
文档总数: 15

## 快速检索

### 按分类

#### architecture (4 篇)

- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md) `architecture go llm fallback resilience` *2026-06-12*
  现象 生产环境中 LLM API 存在多种故障模式： - Provider 级故障（Vertex AI 区域性不可用） - Model 级故障（claude-opus 过载，sonnet 可用） - 不可恢复错误（context 取消、请求格式错误） 如果只做简单重试，会在不可恢复错误上浪费时间，或在 Provider 故障时不知道切换。 根因 LLM 调用的错误类型需要分层处理： 1. 不可重试...

- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md) `architecture go orchestrator state-machine pipeline` *2026-06-12*
  现象 AI Agent 的不同调用场景需要不同的 Tool 集合和系统提示词： - 普通对话：全量 Tool 可用 - 引用模式：只开放特定 Asset 的 Tool - 直接生成：跳过对话，直接调用 Tool 如果用 if-else 硬编码，每加一种模式就要改编排层核心逻辑。 根因 Agent 的"策略"是多维度的——它不只影响 System Prompt，还影响 Tool 定义、参数必需性、 ...

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md) `architecture go llm tool-calling error-recovery` *2026-06-12*
  现象 LLM Function Calling 在生产中有两类典型故障： 1. 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 2. 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 1. LLM 的结构...

- [设计禁令：标识符推断与兜底策略](./architecture/design-ban-identifier-inference.md)
  禁止从标识符推断业务属性 ID、key 名、文件名是身份标识，不是数据源。禁止用正则或字符串匹配从标识符中提取业务含义。 规则 - 业务属性（product_id、category、is_xxx 等）必须通过显式字段声明 - 如果需要关联，在数据结构里加字段；如果来源是外部调用，通过参数显式传入 - 最差的设计也应该是一个 is_product: true 的 flag，而不是靠正则匹配 ID 格...

#### concurrency (2 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md) `concurrency go websocket backpressure` *2026-06-12*
  现象 WebSocket 长连接场景下，如果 LLM 流式输出速度 > 客户端消费速度（弱网、Tab 切后台）， 服务端 write buffer 无限增长，最终 OOM 或导致其他连接的推送延迟。 根因 直接在业务 goroutine 中调用 conn.WriteMessage 存在两个问题： 1. WriteMessage 有锁，多个 goroutine 并发写会阻塞 2. 没有容量控制，消息...

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md) `concurrency go mutex session multi-tab` *2026-06-12*
  现象 用户在多个浏览器 Tab 打开同一个编辑器 Session，同时发送消息。 两个 Turn 并发执行时： - LLM 读到的 AssetPool 状态可能已过时 - 两个 Turn 同时写入 Transcript 导致消息乱序 - 资产生成互相覆盖 根因 Session 状态（AssetPool、Memory、Transcript）是共享可变状态。 FC Loop 内部有多次读写（读状态→调...

#### debugging (3 篇)

- [Redis 数据污染导致 CAS 永久失败](./debugging/redis-cas-data-pollution.md)
  场景 CAS Compare-And-Swap 乐观锁通过 Lua 脚本在 Redis 中做字符串比较： 问题 redis-cli -x SET key < file 或 echo value | redis-cli -x SET key 写入的值会带换行符。 echo 默认追加 \n，-x 从 stdin 读取时保留所有字节。 导致 CAS 比较："386" == "386\n" → 永远失败。...

- [下游 API 调用的 Contract Test](./debugging/downstream-api-contract-test.md)
  问题 重构、清理代码时，容易无意中删除或遗漏传给下游服务的关键参数。普通单元测试只验证"我的逻辑对不对"，不验证"我发出去的 request 长什么样"。 案例 2026-06 soulslive-be：重构 host config 时清理了一段"看起来多余"的 cvi_config 默认注入代码，导致 CreateIVISession gRPC 请求丢失 max_duration_seconds...

- [骨架屏 CLS：`min-h-full` + `justify-end` 在动态高度容器中引发布局抖动](./debugging/skeleton-cls-min-h-full-justify-end.md)
  现象 聊天页面骨架屏使用 min-h-full flex-col justify-end 让占位气泡贴底显示。页面加载时骨架屏出现后往上跳 8-12px。 根因 骨架屏所在的滚动容器（overflow-y-auto flex-1）高度由外层 flex 布局动态分配。当组件树中任何兄弟/祖先元素触发 cascading setState（比如初始化 effect 重置一批状态），会导致容器 offs...

#### engineering (1 篇)

- [LinkedIn Code Review 最佳实践](./engineering/linkedin-code-review-practices.md)
  来源 - URL: https://thenewstack.io/linkedin-code-review/ - 作者: Szczepan Faber LinkedIn Development Tools Tech Lead - 时间: 2017-09 - 背景: LinkedIn 完成 100 万次 code review 后的经验总结；2011 年起强制全员 CR 核心观点 组织层面收益 1....

#### frontend (1 篇)

- [useLayoutEffect 用于 DOM 位置操作](./frontend/useLayoutEffect-scroll-positioning.md)
  问题 React 中渲染列表后需要滚动到底部（聊天、日志、feed），用 useEffect 执行 el.scrollTop = el.scrollHeight 会导致一帧闪烁：用户先看到列表顶部，再跳到底部。 根因 React 渲染周期： useEffect 在 paint 之后执行。如果列表很长（50+ 条消息，渲染 > 100ms），中间那帧用户看到的是 scrollTop=0（顶部），造成...

#### llm-ops (1 篇)

- [LLM API 中转站验证方案](./llm-ops/verify-api-proxy.md)
  问题背景 第三方 LLM API 中转站（代理服务）可能存在的问题： - 声称是 GPT-4/Claude Opus，实际调用更便宜的小模型 - Token 计数造假，多收费 - 缓存旧响应，不是实时调用 - 记录用户 prompts（隐私风险） 验证维度矩阵 | 维度 | 检测目标 | 成本 | 可靠性 | |------|---------|------|--------| | 模型自我认知 ...

#### root (1 篇)

- [技术知识库索引系统](./INDEX_GUIDE.md)
  索引文件 - INDEX.md - 人类可读的 Markdown 索引，包含分类、标签、摘要 - INDEX.json - 机器可读的 JSON 索引，包含完整元数据 - build_index.py - 索引生成脚本 - update_index.sh - 自动更新钩子脚本 Agent 使用指南 快速查找文档 典型场景 场景 1: 用户问"有没有类似的经验" 场景 2: 排查问题前搜索已知案例 ...

#### skills (2 篇)

- [Learn Session Knowledge](./skills/learn-session-knowledge/SKILL.md)
  核心原则 先找当前项目自己的沉淀协议；只有项目没有协议时，才使用本 skill 的 fallback 规则。沉淀只记录未来 agent 需要复用、且无法从代码或 git 历史直接看出的知识。 协议读取顺序 1. 读取当前项目的 docs/rules/learning-protocol.md。 2. 如果不存在，检查项目 AGENTS.md、CLAUDE.md、WORKSPACE.md、worksp...

- [GitHub Browser Create Files](./skills/github-browser-create-files/SKILL.md)
  Hard Constraints - Do not use git push, GitHub write APIs, or direct repository upload controls. - Do not click Upload files. - Do not use Playwright setInputFiles or inputtype="file". - Use GitHub we...

### 按标签

#### `architecture` (3 篇)

- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md)
- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `backpressure` (1 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)

#### `concurrency` (2 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)
- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `error-recovery` (1 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `fallback` (1 篇)

- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md)

#### `go` (5 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)
- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)
- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md)
- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `llm` (2 篇)

- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `multi-tab` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `mutex` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `orchestrator` (1 篇)

- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md)

#### `pipeline` (1 篇)

- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md)

#### `resilience` (1 篇)

- [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md)

#### `session` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `state-machine` (1 篇)

- [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md)

#### `tool-calling` (1 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `websocket` (1 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)

## 全部文档（按时间）

### [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md) `concurrency go websocket backpressure` *2026-06-12*

**分类**: concurrency
 | **项目**: 7verse-agent

现象 WebSocket 长连接场景下，如果 LLM 流式输出速度 > 客户端消费速度（弱网、Tab 切后台）， 服务端 write buffer 无限增长，最终 OOM 或导致其他连接的推送延迟。 根因 直接在业务 goroutine 中调用 conn.WriteMessage 存在两个问题： 1. WriteMessage 有锁，多个 goroutine 并发写会阻塞 2. 没有容量控制，消息...

---

### [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md) `concurrency go mutex session multi-tab` *2026-06-12*

**分类**: concurrency
 | **项目**: 7verse-agent

现象 用户在多个浏览器 Tab 打开同一个编辑器 Session，同时发送消息。 两个 Turn 并发执行时： - LLM 读到的 AssetPool 状态可能已过时 - 两个 Turn 同时写入 Transcript 导致消息乱序 - 资产生成互相覆盖 根因 Session 状态（AssetPool、Memory、Transcript）是共享可变状态。 FC Loop 内部有多次读写（读状态→调...

---

### [LLM 调用的分层 Fallback 策略](./architecture/llm-layered-fallback.md) `architecture go llm fallback resilience` *2026-06-12*

**分类**: architecture
 | **项目**: 7verse-agent

现象 生产环境中 LLM API 存在多种故障模式： - Provider 级故障（Vertex AI 区域性不可用） - Model 级故障（claude-opus 过载，sonnet 可用） - 不可恢复错误（context 取消、请求格式错误） 如果只做简单重试，会在不可恢复错误上浪费时间，或在 Provider 故障时不知道切换。 根因 LLM 调用的错误类型需要分层处理： 1. 不可重试...

---

### [Preflight 分类路由 + 动态 Tool 集合](./architecture/preflight-routing-dynamic-tools.md) `architecture go orchestrator state-machine pipeline` *2026-06-12*

**分类**: architecture
 | **项目**: 7verse-agent

现象 AI Agent 的不同调用场景需要不同的 Tool 集合和系统提示词： - 普通对话：全量 Tool 可用 - 引用模式：只开放特定 Asset 的 Tool - 直接生成：跳过对话，直接调用 Tool 如果用 if-else 硬编码，每加一种模式就要改编排层核心逻辑。 根因 Agent 的"策略"是多维度的——它不只影响 System Prompt，还影响 Tool 定义、参数必需性、 ...

---

### [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md) `architecture go llm tool-calling error-recovery` *2026-06-12*

**分类**: architecture
 | **项目**: 7verse-agent

现象 LLM Function Calling 在生产中有两类典型故障： 1. 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 2. 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 1. LLM 的结构...

---

### [技术知识库索引系统](./INDEX_GUIDE.md)

**分类**: root

索引文件 - INDEX.md - 人类可读的 Markdown 索引，包含分类、标签、摘要 - INDEX.json - 机器可读的 JSON 索引，包含完整元数据 - build_index.py - 索引生成脚本 - update_index.sh - 自动更新钩子脚本 Agent 使用指南 快速查找文档 典型场景 场景 1: 用户问"有没有类似的经验" 场景 2: 排查问题前搜索已知案例 ...

---

### [useLayoutEffect 用于 DOM 位置操作](./frontend/useLayoutEffect-scroll-positioning.md)

**分类**: frontend

问题 React 中渲染列表后需要滚动到底部（聊天、日志、feed），用 useEffect 执行 el.scrollTop = el.scrollHeight 会导致一帧闪烁：用户先看到列表顶部，再跳到底部。 根因 React 渲染周期： useEffect 在 paint 之后执行。如果列表很长（50+ 条消息，渲染 > 100ms），中间那帧用户看到的是 scrollTop=0（顶部），造成...

---

### [Redis 数据污染导致 CAS 永久失败](./debugging/redis-cas-data-pollution.md)

**分类**: debugging

场景 CAS Compare-And-Swap 乐观锁通过 Lua 脚本在 Redis 中做字符串比较： 问题 redis-cli -x SET key < file 或 echo value | redis-cli -x SET key 写入的值会带换行符。 echo 默认追加 \n，-x 从 stdin 读取时保留所有字节。 导致 CAS 比较："386" == "386\n" → 永远失败。...

---

### [下游 API 调用的 Contract Test](./debugging/downstream-api-contract-test.md)

**分类**: debugging

问题 重构、清理代码时，容易无意中删除或遗漏传给下游服务的关键参数。普通单元测试只验证"我的逻辑对不对"，不验证"我发出去的 request 长什么样"。 案例 2026-06 soulslive-be：重构 host config 时清理了一段"看起来多余"的 cvi_config 默认注入代码，导致 CreateIVISession gRPC 请求丢失 max_duration_seconds...

---

### [骨架屏 CLS：`min-h-full` + `justify-end` 在动态高度容器中引发布局抖动](./debugging/skeleton-cls-min-h-full-justify-end.md)

**分类**: debugging

现象 聊天页面骨架屏使用 min-h-full flex-col justify-end 让占位气泡贴底显示。页面加载时骨架屏出现后往上跳 8-12px。 根因 骨架屏所在的滚动容器（overflow-y-auto flex-1）高度由外层 flex 布局动态分配。当组件树中任何兄弟/祖先元素触发 cascading setState（比如初始化 effect 重置一批状态），会导致容器 offs...

---

### [设计禁令：标识符推断与兜底策略](./architecture/design-ban-identifier-inference.md)

**分类**: architecture

禁止从标识符推断业务属性 ID、key 名、文件名是身份标识，不是数据源。禁止用正则或字符串匹配从标识符中提取业务含义。 规则 - 业务属性（product_id、category、is_xxx 等）必须通过显式字段声明 - 如果需要关联，在数据结构里加字段；如果来源是外部调用，通过参数显式传入 - 最差的设计也应该是一个 is_product: true 的 flag，而不是靠正则匹配 ID 格...

---

### [LLM API 中转站验证方案](./llm-ops/verify-api-proxy.md)

**分类**: llm-ops

问题背景 第三方 LLM API 中转站（代理服务）可能存在的问题： - 声称是 GPT-4/Claude Opus，实际调用更便宜的小模型 - Token 计数造假，多收费 - 缓存旧响应，不是实时调用 - 记录用户 prompts（隐私风险） 验证维度矩阵 | 维度 | 检测目标 | 成本 | 可靠性 | |------|---------|------|--------| | 模型自我认知 ...

---

### [LinkedIn Code Review 最佳实践](./engineering/linkedin-code-review-practices.md)

**分类**: engineering

来源 - URL: https://thenewstack.io/linkedin-code-review/ - 作者: Szczepan Faber LinkedIn Development Tools Tech Lead - 时间: 2017-09 - 背景: LinkedIn 完成 100 万次 code review 后的经验总结；2011 年起强制全员 CR 核心观点 组织层面收益 1....

---

### [Learn Session Knowledge](./skills/learn-session-knowledge/SKILL.md)

**分类**: skills

核心原则 先找当前项目自己的沉淀协议；只有项目没有协议时，才使用本 skill 的 fallback 规则。沉淀只记录未来 agent 需要复用、且无法从代码或 git 历史直接看出的知识。 协议读取顺序 1. 读取当前项目的 docs/rules/learning-protocol.md。 2. 如果不存在，检查项目 AGENTS.md、CLAUDE.md、WORKSPACE.md、worksp...

---

### [GitHub Browser Create Files](./skills/github-browser-create-files/SKILL.md)

**分类**: skills

Hard Constraints - Do not use git push, GitHub write APIs, or direct repository upload controls. - Do not click Upload files. - Do not use Playwright setInputFiles or inputtype="file". - Use GitHub we...

---
