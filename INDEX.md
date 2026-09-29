# 技术知识库索引

最后更新: 2026-09-29 20:07
文档总数: 49

## 快速检索

### 按分类

#### Agent (13 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md) `agent career jd-analysis evaluation reliability rag` *2026-07-18*
  > 这不是一份“Agent 技术大全”。它回答的是另一个问题：目标岗位现在反复要求什么、哪些能力必须形成工程证据、哪些热门概念暂时不值得投入。 13.1 为什么从 JD 开始 常规学习路线容易把 Function Calling、RAG、MCP、Memory、多 Agent 和各种框架依次列一遍，却没有说明优先级。岗位导向学习需要同时看三个信号： 1. 市场频率：多少份当前 JD 把它列为职责或硬...

- [02 · Agent 使用与构建的最佳实践](./Agent/02-agent-best-practices.md)
  > 目标读者：既用现成 Agent（Claude Code / Cursor），也自己在写 Agent 的开发者。本章总结的都是从 Claude Code 泄漏源码、Anthropic 博客、OpenAI Harness Engineering、Hermes 源码里交叉验证过的做法。 2.1 心法：三句话记牢 1. 上下文是你能写出的最值钱代码。模型能力很快会变，你写的规约、工具描述、skill ...

- [04 · Hermes Agent 实现原理](./Agent/04-hermes-agent-internals.md)
  > Hermes Agent（nousresearch/hermes-agent）是 NousResearch 开源的 Python Agent 框架，在 2025-2026 出圈靠的是"不是又一个 Agent，而是真的在做代理操作系统"这个定位。这一章的价值在于：它完全开源可读，和 Claude Code（闭源但泄漏）形成完美对照，你可以在 Hermes 源码里验证第 02/03 章提到的设计决...

- [05 · OpenClaw 实现原理 + 安全问题 + 沙盒](./Agent/05-openclaw-internals-security.md)
  > OpenClaw（openclaw/openclaw）是 Steipete（PSPDFKit 创始人）发起的开源桌面 AI 助手，2025 下半年到 2026 一路涨到 360K star，成为开源 Agent 顶流。但它同时也是过去一年里被安全社区"锤"得最狠的项目 —— 因为它展示了一件事：工程能力很强的团队，用 AI 高速写代码，仍然可能得到一个"默认裸奔"的安全架构。1 5.1 项目概...

- [10 · Agent 安全与攻防（威胁建模 / 注入 / OWASP / 沙盒）](./Agent/10-agent-security-threats.md)
  > 2024–2026 是 AI 安全事件井喷的两年：从 M365 Copilot 的间接注入、ChatGPT Connectors 的数据外带、Cursor MCP 的 rule injection，到豆包手机 INJECT_EVENTS 争议，再到 OpenClaw 默认不安全的公开羞辱 —— Agent 安全不再是学术话题。这一章系统过一遍威胁模型、真实事件和防御架构。 10.1 威胁模型全...

- [11 · Coding Agent 军备竞赛横向对比](./Agent/11-coding-agent-landscape.md)
  > 2025–2026 是 "Coding Agent 军备竞赛年"：Anthropic Claude Code 从 CLI 长成 IDE + 云端三形态、Cursor 估值破百亿、OpenAI Codex CLI 回归、Microsoft Copilot Workspace 转 agentic、国内腾讯 Codebuddy / 阿里 Qoder / 字节 TRAE 同台登场。选型焦虑从"用不用 ...

- [01 · Agent 知识体系与设计结构](./Agent/01 · Agent 知识体系与设计结构.md)
  > 本章是整套文档的"地图"。读完你应该能：用统一词汇描述一个 Agent、知道主流架构谱系的来龙去脉、看见一个陌生 Agent 项目能迅速拆出它的五大件。 1.1 Agent 是什么 —— 一句话到一张图 LLM Agent 的最通俗定义：能自己决定"下一步干什么"的 LLM 驱动程序。更工程化的说法来自 Anthropic 2025 年那篇《Building Effective Agents》...

- [03 · Claude Code 泄漏源码分析](./Agent/03-claude-code-leak-analysis.md)
  > 2026-03-31，Anthropic 在发布 Claude Code v2.1.88 时误把 cli.js.map（压缩前源码映射，60MB）一起推到了 npm。社区在第一时间镜像下载并反编译 —— 51.2 万行 TypeScript、1903 个文件、4756 个模块。这是工业级 Agent 史上最大规模的"事故级"开源，比起读博客学架构，这直接把一家头部 AI Lab 最好的 Age...

- [07 · Token 压缩 · 长期记忆 · 移动侧 · 多 Agent](./Agent/07-token-memory-multi-agent.md)
  > 这四个主题其实都在回答同一个问题："怎么让 Agent 跑得更久 / 记得更多 / 动得更稳"。本章横向对比。 7.1 Token 压缩策略全景 四个流派 四种不是互斥，主流系统都是组合拳。 六个代表实现的横向表 | 方案 | 流派 | 触发 | 保留策略 | 特色 | | --- | --- | --- | --- | --- | | Claude Code 6 层 | 1+2+4 | ms...

- [06 · 豆包手机 OS：原理 / 安全 / 交互](./Agent/06-doubao-phone-os.md)
  > 2025-12-01，字节跳动联手中兴子品牌努比亚发布 努比亚 M153 豆包手机（3499 元，首批 3 万台 24 小时售罄），被广泛认为是"全球首款系统级 AI Agent 手机"。上市一周后多个国民级 App 连夜封禁它，一度成为 2025 年末中国科技圈最戏剧性的事件 —— 技术上它代表了系统级 GUI Agent 的上限，商业/合规上它暴露了移动 Agent 面临的全部挑战。123...

- [09 · AI 开发模式：SDD / Harness / Vibe / Context Engineering](./Agent/09-ai-dev-paradigms.md)
  > "我每天要和 AI 一起写代码" 的个人开发者，理应知道这条范式演进的主线。本章把 2023→2026 出现的几种主流 AI 编程范式摆在一起，说清它们解决什么、什么时候用、有什么局限。 9.1 三代工程范式演进 | 代际 | 核心动作 | 代表工具 | 优势 | 局限 | | --- | --- | --- | --- | --- | | Prompt Engineering | 调措辞、F...

- [08 · AI 新概念补充（MCP / Benchmark / Obs / RAG 2.0 / CUA / UX / 推理）](./Agent/08-new-ai-concepts.md)
  > 2024–2026 在 Agent 领域涌现出一批新概念。这一章把你在别的文档里碰到"这词什么意思" 时需要的名词解释、关键出处、一句话价值判断集中在一起。 8.1 MCP（Model Context Protocol）深潜 一句话定义 > MCP 把 "LLM 接工具" 这件事抽象成 JSON-RPC 协议，让一个 MCP Server 能被多个 Client（Claude Desktop ...

- [12 · 中国 Agent 生态全景](./Agent/12-china-agent-ecosystem.md)
  > 2024–2026 的中国 AI 厂商有一个共同动作：从"做模型" 切到"做 Agent"。因为模型差距开始收敛（Qwen/GLM/DeepSeek 已经追上），而应用层（Agent）才是最后能差异化的地方。本章盘点主要玩家、标志性产品、技术路线、以及和海外头部的对标关系。 12.1 玩家象限 12.2 标志性产品技术剖析 | 产品 | 定位 | 技术亮点 | 模型底座 | 可用性 | | -...

#### architecture (3 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md) `architecture go llm tool-calling error-recovery` *2026-06-12*
  现象 LLM Function Calling 在生产中有两类典型故障： 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 LLM 的结构化输出质量不是 1...

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md) `architecture go llm tool-calling error-recovery` *2026-06-12*
  现象 LLM Function Calling 在生产中有两类典型故障： 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 LLM 的结构化输出质量不是 1...

- [设计禁令：标识符推断与兜底策略](./architecture/design-ban-identifier-inference.md)
  禁止从标识符推断业务属性 ID、key 名、文件名是身份标识，不是数据源。禁止用正则或字符串匹配从标识符中提取业务含义。 规则 业务属性（product_id、category、is_xxx 等）必须通过显式字段声明 如果需要关联，在数据结构里加字段；如果来源是外部调用，通过参数显式传入 最差的设计也应该是一个 is_product: true 的 flag，而不是靠正则匹配 ID 格式 事故案例...

#### concurrency (2 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md) `concurrency go websocket backpressure` *2026-06-12*
  现象 WebSocket 长连接场景下，如果 LLM 流式输出速度 > 客户端消费速度（弱网、Tab 切后台）， 服务端 write buffer 无限增长，最终 OOM 或导致其他连接的推送延迟。 根因 直接在业务 goroutine 中调用 conn.WriteMessage 存在两个问题： WriteMessage 有锁，多个 goroutine 并发写会阻塞 没有容量控制，消息堆积无感知 ...

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md) `concurrency go mutex session multi-tab` *2026-06-12*
  现象 用户在多个浏览器 Tab 打开同一个编辑器 Session，同时发送消息。 两个 Turn 并发执行时： LLM 读到的 AssetPool 状态可能已过时 两个 Turn 同时写入 Transcript 导致消息乱序 资产生成互相覆盖 根因 Session 状态（AssetPool、Memory、Transcript）是共享可变状态。 FC Loop 内部有多次读写（读状态→调LLM→执行...

#### database (1 篇)

- [GORM 链式 Where 里的 OR 组缺外层括号：一条 UPDATE 污染全表](./database/gorm-where-or-group-missing-parens.md)
  症状 - 一条本应只更新 1 行的 UPDATE，实际更新了几百行（本例 318 行）。 - 受影响的行有共同特征：它们都满足 OR 分支的条件，而与目标主键无关。 - 上游看起来"没成功"：调用方按 RowsAffected != 1 判定失败并走了回滚/重排分支，但脏数据已经写进事务并提交。故障表现成"任务未完成"，掩盖了"数据已污染"。 - 单元测试全绿。 根因 GORM 的链式 Where...

#### debugging (5 篇)

- [Redis 数据污染导致 CAS 永久失败](./debugging/redis-cas-data-pollution.md)
  场景 CAS Compare-And-Swap 乐观锁通过 Lua 脚本在 Redis 中做字符串比较： 问题 redis-cli -x SET key < file 或 echo value | redis-cli -x SET key 写入的值会带换行符。 echo 默认追加 \n，-x 从 stdin 读取时保留所有字节。 导致 CAS 比较："386" == "386\n" → 永远失败。...

- [根因](./debugging/问题排查.md)
  Redis key char:live_room:room_content:v2:catalog_version 值被污染为 "386\n"（带换行符），CAS Lua 脚本做字符串比较永远失败。来源是某次手动 echo 386 | redis-cli -x SET ...，echo 默认追加 \n。 排查过程中犯的错误 1. 无脑怀疑代码逻辑 — 假设是 retry 逻辑 bug、version...

- [你正在审查另一个 AI 助手编写的计划/代码。你的任务是独立验证其正确性。](./debugging/CoreReviewer.md)
  1. 逻辑是否正确？ 2. 是否遗漏了边界情况？ 3. 是否存在安全隐患？ 4. 是否符合既定需求？ 不要建议重构、重命名、风格调整或添加注释。只报告 bug、逻辑错误和安全问题。 在一轮回答内报告完整

- [下游 API 调用的 Contract Test](./debugging/downstream-api-contract-test.md)
  问题 重构、清理代码时，容易无意中删除或遗漏传给下游服务的关键参数。普通单元测试只验证"我的逻辑对不对"，不验证"我发出去的 request 长什么样"。 案例 2026-06 soulslive-be：重构 host config 时清理了一段"看起来多余"的 cvi_config 默认注入代码，导致 CreateIVISession gRPC 请求丢失 max_duration_seconds...

- [骨架屏 CLS：`min-h-full` + `justify-end` 在动态高度容器中引发布局抖动](./debugging/skeleton-cls-min-h-full-justify-end.md)
  现象 聊天页面骨架屏使用 min-h-full flex-col justify-end 让占位气泡贴底显示。页面加载时骨架屏出现后往上跳 8-12px。 根因 骨架屏所在的滚动容器（overflow-y-auto flex-1）高度由外层 flex 布局动态分配。当组件树中任何兄弟/祖先元素触发 cascading setState（比如初始化 effect 重置一批状态），会导致容器 offs...

#### devops (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md) `frontend asset-delivery caching cdn object-storage reverse-proxy devops troubleshooting` *2026-08-02*
  定位 前端资源问题经常表现为“每一层看起来都正常，但用户仍拿到旧内容或错误内容”： - 数据接口已经返回新数据，公网 HTML 或固定站点文件仍是旧版本。 - 对象存储的正文和 metadata 已更新，公网响应头仍保留旧缓存策略。 - CDN 缓存清理已经成功，下一次回源后又缓存了错误版本。 - 动态渲染服务已经上线，请求却仍落到静态站点。 - 远程构建任务已创建，CI 因无法读取日志而显示失败...

#### engineering (1 篇)

- [LinkedIn Code Review 最佳实践](./engineering/linkedin-code-review-practices.md)
  来源 - URL: https://thenewstack.io/linkedin-code-review/ - 作者: Szczepan Faber LinkedIn Development Tools Tech Lead - 时间: 2017-09 - 背景: LinkedIn 完成 100 万次 code review 后的经验总结；2011 年起强制全员 CR 核心观点 组织层面收益 1....

#### frontend (4 篇)

- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md) `frontend manifest deployment ssr caching gcs release` *2026-08-07*
  1. 问题不只是“文件有没有上传” 现代前端构建会生成带内容 hash 的 JavaScript、CSS、图片和字体。HTML 或 SSR 服务端产物不会在运行时自动寻找“最新资源”，而是在构建时绑定某一组确定的 hash URL。 因此，一个可工作的前端版本不是若干独立文件，而是一个完整 release： 只要其中一部分来自另一轮构建，就会出现版本偏斜：HTML 可以正常返回，首屏 SSR 也可...

- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md) `frontend nginx http caching cache-control cdn debugging` *2026-08-07*
  1. 典型现象 一次前端发布短暂删除了带 hash 的资源，浏览器请求资源时收到 404。资源随后重新上传，直接请求已经返回 200，但部分用户仍持续看到： DevTools 可能显示 from disk cache。这时源站已经恢复，用户仍失败的原因是浏览器缓存了先前的 404。 问题不在“浏览器为什么缓存”，而在出口错误地把 404 标记成了可长期公开缓存的响应，例如： must-revali...

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md) `nextjs ssr rsc hydration frontend deployment caching` *2026-08-03*
  1. 定位 Next.js 已经把 React SSR 的底层调用闭环起来。日常使用 App Router 时，工程师通常不需要自己调用 renderToString、renderToPipeableStream 或 hydrateRoot。 但框架代劳不等于生产边界消失。上线后仍然要回答四个问题： 1. 首次请求由谁生成 HTML？ 2. 哪些代码只在服务端运行，哪些代码会进入浏览器？ 3. 构...

- [useLayoutEffect 用于 DOM 位置操作](./frontend/useLayoutEffect-scroll-positioning.md)
  问题 React 中渲染列表后需要滚动到底部（聊天、日志、feed），用 useEffect 执行 el.scrollTop = el.scrollHeight 会导致一帧闪烁：用户先看到列表顶部，再跳到底部。 根因 React 渲染周期： useEffect 在 paint 之后执行。如果列表很长（50+ 条消息，渲染 > 100ms），中间那帧用户看到的是 scrollTop=0（顶部），造成...

#### llm-ops (1 篇)

- [LLM API 中转站验证方案](./llm-ops/verify-api-proxy.md)
  问题背景 第三方 LLM API 中转站（代理服务）可能存在的问题： - 声称是 GPT-4/Claude Opus，实际调用更便宜的小模型 - Token 计数造假，多收费 - 缓存旧响应，不是实时调用 - 记录用户 prompts（隐私风险） 验证维度矩阵 | 维度 | 检测目标 | 成本 | 可靠性 | |------|---------|------|--------| | 模型自我认知 ...

#### root (4 篇)

- [Optional Tool and Environment Configuration](./TOOLS.en.md)
  简体中文./TOOLS.md | English Optional Tool and Environment Configuration This file contains rules tied to specific accounts, CLIs, directory layouts, or local toolchains. CLAUDE.en.md does not import it a...

- [技术知识库索引系统](./INDEX_GUIDE.md)
  索引文件 - INDEX.md - 人类可读的 Markdown 索引，包含分类、标签、摘要 - INDEX.json - 机器可读的 JSON 索引，包含完整元数据 - build_index.py - 索引生成脚本 - update_index.sh - 自动更新钩子脚本 Agent 使用指南 快速查找文档 典型场景 场景 1: 用户问"有没有类似的经验" 场景 2: 排查问题前搜索已知案例 ...

- [Hard Rules](./CLAUDE.en.md)
  简体中文./CLAUDE.md | English > Optional tool- and environment-specific rules live in TOOLS.en.md./TOOLS.en.md. The core rules do not import tool configuration automatically; reference it explicitly only ...

- [可选工具与环境配置](./TOOLS.md)
  简体中文 | English./TOOLS.en.md 可选工具与环境配置 本文件收纳依赖具体账号、CLI、目录结构或本地工具链的规则，不由 CLAUDE.md 自动导入。仅在环境匹配时选择所需章节，或在个人配置中显式添加 @TOOLS.md。 GitLab 与 glab - GitLab 访问使用 glab CLI，不使用无法通过组织登录流程的通用网页抓取工具。 - 查看 MR diff：gla...

#### skills (14 篇)

- [Agent 行为评测与优化](./skills/improving-agent-behavior/SKILL.md)
  核心原则 执行 Execute → Evaluate → Optimize → Re-evaluate。历史轨迹已有 Execute 产物时，从 Evaluate 开始。 把评测与修改分开：先用证据测评并与用户讨论，再获得针对精确修改清单的确认，最后修改和复测。 <HARD-GATE> 在完成 Eval、讨论方案并获得用户对精确修改清单的明确确认前，不得修改任何规则、Skill、测试、业务代码或外...

- [BE 后端评审](./skills/backend-review/SKILL.md)
  本技能整理已有后端结构、Go 可读性、消费点覆盖与 ID 精度规则。默认只读，不因评审而修改代码或发布；按用户给定的范围选用模块，不把所有专项强制执行一遍。 选择已有检查模块 | 用户任务或改动证据 | 读取材料 | 交付 | |---|---|---| | 结构、职责、规则分叉、状态所有权、隐藏副作用或配置发布依赖 | 结构评审references/structure.md | 结构发现、配置发...

- [GitHub Web Publish](./skills/github-web-publish/SKILL.md)
  通过当前可用的 Computer Use 能力操作已连接且已登录的 Chrome，在 GitHub 网页中编辑、创建或上传仓库文件，并完成网页提交与结果验证。 硬性边界 - 只使用 GitHub 网页提供的 Edit、Create new file、Upload files 和 Commit changes 等界面完成远程写入。 - 使用当前环境提供的 Computer Use 接口并遵守它当轮返...

- [FE 前端评审](./skills/frontend-review/SKILL.md)
  保持前端变更可读、可评审，并按职责划分。优先使用清晰的领域名称，避免在大组件中堆积内联实现。默认只读；用户明确要求实现或重构时，使用文末已有的实现清单。 评审前定位 评审或编辑前先确认： - 框架和项目现有约定。 - 本次涉及的文件和行数。 - 改动属于页面级功能、复用 UI、数据转换、样式调整还是有状态行为。 - 检查实际调用关系，确定新增或抽取的组件、hook 所属的最小范围，并统计该范围内已...

- [《[项目名] 架构评估》](./skills/architecture-decision-rfc/template.md)
  0. 背景与范围 - 背景： - 当前痛点： - 目标： - 非目标： - 关键约束（时间/人力/兼容/成本）： - PRD： - Figma 文件及相关页面/节点： - 现有实现证据： - Figma 适用性（已读取/证据不足/不适用及理由）： - PRD、Figma、Tech Design、现有实现的冲突与决策： 1. 问题陈述 1.1 架构范式差异 - 当前范式： - 新需求范式： - 冲突...

- [架构评估自检清单](./skills/architecture-decision-rfc/checklist.md)
  输入证据与交互 - 是否判断本方案是否影响用户可见页面或交互 - 适用时是否实际读取相关 Figma 页面、节点、原型连线和注释，而非只看截图 - 不适用时是否记录“Figma 不适用”及理由 - Figma 缺失或无法访问时，是否将方案完整性标记为证据不足 - 是否覆盖主路径、loading、空态、成功、失败、重试、取消和重复操作 - 是否将关键交互映射到接口、字段、状态所有者、后端副作用及幂等...

- [架构评估与决策](./skills/architecture-decision-rfc/SKILL.md)
  用于把“想法讨论”收敛为“可执行方案”。 使用方式 1. 收集输入：背景、现状、目标、约束、非目标、时间窗口、PRD、Figma 和现有实现。 2. 判断是否涉及用户可见页面或交互： - 适用时实际读取相关 Figma 页面、节点、原型连线和注释，提取状态、动作、异常分支和数据需求。 - 无法找到或访问 Figma 时，将其列为阻塞方案完整性的待确认项，不凭经验补全。 - 纯基础设施或无 UI 变...

- [zsh-compatible: use find instead of glob to avoid NOMATCH error](./skills/plan-eng-review/SKILL.md)
  <!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly --> <!-- Regenerate: bun run gen:skill-docs --> Preamble run first If PROACTIVE is "false", do not proactively suggest gstack skills AND d...

- [Release Orchestrator](./skills/release-orchestrator/SKILL.md)
  把已经开发完成的 Feature 安全地逐步发布。先在内部建立完整依赖图，再一次只交付一个当前可执行的 MR；前序发布和验证没有完成时，不推进后续 MR。 入口边界 把以下内容视为已在开发阶段完成： - 代码 review、测试和必要修复。 - 配置与发布依赖的完整性审查。 - Feature 的开发依赖或发布依赖文档维护。 - 最终 feat 分支作为功能代码真相源。 不要调用其他 code r...

- [技术方案交互、接口与数据评审](./skills/tech-design-data-review/SKILL.md)
  基于 Figma 交互、实际接口、请求预算、耗时证据、调用路径、SQL、DDL、索引和容量证据给出可执行的评审结论。不要只复述 Tech Design，也不要把个人偏好包装成 Finding。 评审边界 - 默认只读评审；除非用户明确要求，否则不要修改代码、文档、数据库或远端状态。 - 优先检查用户给出的 PRD、Figma、Tech Design、MR/PR 和代码；缺少材料时再搜索关联实现。 ...

- [Go 代码可读性](./skills/backend-review/references/go-readability.md)
  执行只读审核。除非用户明确要求修改，否则不要编辑被审代码。 审核边界 只报告本次变更新增或明显加剧的问题。阅读足够的调用者、类型定义和测试来理解变更，但不要把审核扩张为历史代码清理。 本层只回答“代码是否容易被准确理解和安全修改”。以下内容只记录为待进入其他审核层的风险，不在没有证据时下结论： - 业务逻辑是否正确。 - 是否存在数据竞争、死锁或内存模型问题。 - 性能、容量和资源消耗是否满足目标...

- [代码结构评审](./skills/backend-review/references/structure.md)
  实现完成后的结构体检，只读。除非用户明确要求，不改被审代码。 关注结构和可维护性：规则有没有分叉、状态归谁管、抽象值不值、体量是否失控、配置有没有漏登记。 不猎 bug（那是 code review / 安全评审的活），不追覆盖率数字，不提格式化偏好。 审查重构时同时比较变更前后，核对规则实现数量、状态所有者、调用跳转、可变状态入口和契约是否收敛。用户要求判断重构目标时可以说明仍存缺口，但不将未加...

- [消费点覆盖与标识符完整性](./skills/backend-review/references/dependency-and-identifiers.md)
  对被多处消费的依赖做覆盖面体检，对跨边界标识符做精度完整性检查。只读；除非用户明确要求，不改被审代码。 根据 diff 回答适用的问题： - 依赖覆盖：这次改造是否覆盖了该依赖的全部消费点；没覆盖的是否是有意保留。 - 标识符完整性：标识符从生产到消费是否保持逐位一致，是否可能因浮点数或隐式类型转换映射到另一主体。 本模块不查结构好坏（结构由同包 structure.md 覆盖），不做与上述两类风...

- [Agent 行为 Eval 量表](./skills/improving-agent-behavior/references/evaluation-rubric.md)
  使用边界 只评价样本中可见的消息、工具操作和产物。先还原当时 Agent 能知道什么，再判断行为；不要依据隐藏推理、后来补充的信息或最终结果反推当时必然犯错。 样本不完整时标记未知。除非表达方式造成误解、延迟或范围漂移，否则不评价个人风格。 评分 对每个维度给出 0～4 分并引用证据： - 4：行为完整可靠，没有实质缺口。 - 3：总体正确，存在轻微但不影响主目标的缺口。 - 2：部分正确，但有明...

### 按标签

#### `agent` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `architecture` (2 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `asset-delivery` (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)

#### `backpressure` (1 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)

#### `cache-control` (1 篇)

- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `caching` (4 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)
- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)
- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)
- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `career` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `cdn` (2 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)
- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `concurrency` (2 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)
- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `debugging` (1 篇)

- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `deployment` (2 篇)

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)
- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)

#### `devops` (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)

#### `error-recovery` (2 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `evaluation` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `frontend` (4 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)
- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)
- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)
- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `gcs` (1 篇)

- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)

#### `go` (4 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)
- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `http` (1 篇)

- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `hydration` (1 篇)

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)

#### `jd-analysis` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `llm` (2 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `manifest` (1 篇)

- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)

#### `multi-tab` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `mutex` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `nextjs` (1 篇)

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)

#### `nginx` (1 篇)

- [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md)

#### `object-storage` (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)

#### `rag` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `release` (1 篇)

- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)

#### `reliability` (1 篇)

- [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md)

#### `reverse-proxy` (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)

#### `rsc` (1 篇)

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)

#### `session` (1 篇)

- [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md)

#### `ssr` (2 篇)

- [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md)
- [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md)

#### `tool-calling` (2 篇)

- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md)
- [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md)

#### `troubleshooting` (1 篇)

- [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md)

#### `websocket` (1 篇)

- [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md)

## 全部文档（按时间）

### [Manifest 驱动的前端静态资源与 SSR 发布](./frontend/manifest-driven-frontend-release.md) `frontend manifest deployment ssr caching gcs release` *2026-08-07*

**分类**: frontend

1. 问题不只是“文件有没有上传” 现代前端构建会生成带内容 hash 的 JavaScript、CSS、图片和字体。HTML 或 SSR 服务端产物不会在运行时自动寻找“最新资源”，而是在构建时绑定某一组确定的 hash URL。 因此，一个可工作的前端版本不是若干独立文件，而是一个完整 release： 只要其中一部分来自另一轮构建，就会出现版本偏斜：HTML 可以正常返回，首屏 SSR 也可...

---

### [404 负缓存：为什么静态资源恢复后用户仍然打不开页面](./frontend/http-negative-caching-nginx.md) `frontend nginx http caching cache-control cdn debugging` *2026-08-07*

**分类**: frontend

1. 典型现象 一次前端发布短暂删除了带 hash 的资源，浏览器请求资源时收到 404。资源随后重新上传，直接请求已经返回 200，但部分用户仍持续看到： DevTools 可能显示 from disk cache。这时源站已经恢复，用户仍失败的原因是浏览器缓存了先前的 404。 问题不在“浏览器为什么缓存”，而在出口错误地把 404 标记成了可长期公开缓存的响应，例如： must-revali...

---

### [Next.js SSR 生产运行模型与交付边界](./frontend/nextjs-ssr-production-model.md) `nextjs ssr rsc hydration frontend deployment caching` *2026-08-03*

**分类**: frontend

1. 定位 Next.js 已经把 React SSR 的底层调用闭环起来。日常使用 App Router 时，工程师通常不需要自己调用 renderToString、renderToPipeableStream 或 hydrateRoot。 但框架代劳不等于生产边界消失。上线后仍然要回答四个问题： 1. 首次请求由谁生成 HTML？ 2. 哪些代码只在服务端运行，哪些代码会进入浏览器？ 3. 构...

---

### [前端资源交付链路与多层缓存排障](./devops/frontend-resource-delivery-troubleshooting.md) `frontend asset-delivery caching cdn object-storage reverse-proxy devops troubleshooting` *2026-08-02*

**分类**: devops

定位 前端资源问题经常表现为“每一层看起来都正常，但用户仍拿到旧内容或错误内容”： - 数据接口已经返回新数据，公网 HTML 或固定站点文件仍是旧版本。 - 对象存储的正文和 metadata 已更新，公网响应头仍保留旧缓存策略。 - CDN 缓存清理已经成功，下一次回源后又缓存了错误版本。 - 动态渲染服务已经上线，请求却仍落到静态站点。 - 远程构建任务已创建，CI 因无法读取日志而显示失败...

---

### [13 · 从 JD 反推 Agent 工程师学习路线](./Agent/13-jd-driven-agent-engineering.md) `agent career jd-analysis evaluation reliability rag` *2026-07-18*

**分类**: Agent

> 这不是一份“Agent 技术大全”。它回答的是另一个问题：目标岗位现在反复要求什么、哪些能力必须形成工程证据、哪些热门概念暂时不值得投入。 13.1 为什么从 JD 开始 常规学习路线容易把 Function Calling、RAG、MCP、Memory、多 Agent 和各种框架依次列一遍，却没有说明优先级。岗位导向学习需要同时看三个信号： 1. 市场频率：多少份当前 JD 把它列为职责或硬...

---

### [WebSocket Channel 队列 + WritePump 背压处理](./concurrency/websocket-channel-backpressure.md) `concurrency go websocket backpressure` *2026-06-12*

**分类**: concurrency
 | **项目**: 7verse-agent

现象 WebSocket 长连接场景下，如果 LLM 流式输出速度 > 客户端消费速度（弱网、Tab 切后台）， 服务端 write buffer 无限增长，最终 OOM 或导致其他连接的推送延迟。 根因 直接在业务 goroutine 中调用 conn.WriteMessage 存在两个问题： WriteMessage 有锁，多个 goroutine 并发写会阻塞 没有容量控制，消息堆积无感知 ...

---

### [Turn 锁 + PreLock 钩子解决多 Tab 竞态](./concurrency/turn-lock-prelock-multi-tab.md) `concurrency go mutex session multi-tab` *2026-06-12*

**分类**: concurrency
 | **项目**: 7verse-agent

现象 用户在多个浏览器 Tab 打开同一个编辑器 Session，同时发送消息。 两个 Turn 并发执行时： LLM 读到的 AssetPool 状态可能已过时 两个 Turn 同时写入 Transcript 导致消息乱序 资产生成互相覆盖 根因 Session 状态（AssetPool、Memory、Transcript）是共享可变状态。 FC Loop 内部有多次读写（读状态→调LLM→执行...

---

### [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-layered-fallback.md) `architecture go llm tool-calling error-recovery` *2026-06-12*

**分类**: architecture
 | **项目**: 7verse-agent

现象 LLM Function Calling 在生产中有两类典型故障： 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 LLM 的结构化输出质量不是 1...

---

### [LLM Tool 参数容错 + FC Loop 自动恢复](./architecture/llm-tool-calling-fault-tolerance.md) `architecture go llm tool-calling error-recovery` *2026-06-12*

**分类**: architecture
 | **项目**: 7verse-agent

现象 LLM Function Calling 在生产中有两类典型故障： 参数格式不稳定：同一个 Tool 的 string_array 参数，LLM 有时返回 "a","b"，有时返回 "a, b" 字符串 幻觉跳过 Tool：LLM 声称"已完成"但实际从未调用必要的 Tool（如 generate_visual） 这两类问题导致用户看到残缺的生成结果。 根因 LLM 的结构化输出质量不是 1...

---

### [Optional Tool and Environment Configuration](./TOOLS.en.md)

**分类**: root

简体中文./TOOLS.md | English Optional Tool and Environment Configuration This file contains rules tied to specific accounts, CLIs, directory layouts, or local toolchains. CLAUDE.en.md does not import it a...

---

### [技术知识库索引系统](./INDEX_GUIDE.md)

**分类**: root

索引文件 - INDEX.md - 人类可读的 Markdown 索引，包含分类、标签、摘要 - INDEX.json - 机器可读的 JSON 索引，包含完整元数据 - build_index.py - 索引生成脚本 - update_index.sh - 自动更新钩子脚本 Agent 使用指南 快速查找文档 典型场景 场景 1: 用户问"有没有类似的经验" 场景 2: 排查问题前搜索已知案例 ...

---

### [Hard Rules](./CLAUDE.en.md)

**分类**: root

简体中文./CLAUDE.md | English > Optional tool- and environment-specific rules live in TOOLS.en.md./TOOLS.en.md. The core rules do not import tool configuration automatically; reference it explicitly only ...

---

### [可选工具与环境配置](./TOOLS.md)

**分类**: root

简体中文 | English./TOOLS.en.md 可选工具与环境配置 本文件收纳依赖具体账号、CLI、目录结构或本地工具链的规则，不由 CLAUDE.md 自动导入。仅在环境匹配时选择所需章节，或在个人配置中显式添加 @TOOLS.md。 GitLab 与 glab - GitLab 访问使用 glab CLI，不使用无法通过组织登录流程的通用网页抓取工具。 - 查看 MR diff：gla...

---

### [GORM 链式 Where 里的 OR 组缺外层括号：一条 UPDATE 污染全表](./database/gorm-where-or-group-missing-parens.md)

**分类**: database

症状 - 一条本应只更新 1 行的 UPDATE，实际更新了几百行（本例 318 行）。 - 受影响的行有共同特征：它们都满足 OR 分支的条件，而与目标主键无关。 - 上游看起来"没成功"：调用方按 RowsAffected != 1 判定失败并走了回滚/重排分支，但脏数据已经写进事务并提交。故障表现成"任务未完成"，掩盖了"数据已污染"。 - 单元测试全绿。 根因 GORM 的链式 Where...

---

### [useLayoutEffect 用于 DOM 位置操作](./frontend/useLayoutEffect-scroll-positioning.md)

**分类**: frontend

问题 React 中渲染列表后需要滚动到底部（聊天、日志、feed），用 useEffect 执行 el.scrollTop = el.scrollHeight 会导致一帧闪烁：用户先看到列表顶部，再跳到底部。 根因 React 渲染周期： useEffect 在 paint 之后执行。如果列表很长（50+ 条消息，渲染 > 100ms），中间那帧用户看到的是 scrollTop=0（顶部），造成...

---

### [Redis 数据污染导致 CAS 永久失败](./debugging/redis-cas-data-pollution.md)

**分类**: debugging

场景 CAS Compare-And-Swap 乐观锁通过 Lua 脚本在 Redis 中做字符串比较： 问题 redis-cli -x SET key < file 或 echo value | redis-cli -x SET key 写入的值会带换行符。 echo 默认追加 \n，-x 从 stdin 读取时保留所有字节。 导致 CAS 比较："386" == "386\n" → 永远失败。...

---

### [根因](./debugging/问题排查.md)

**分类**: debugging

Redis key char:live_room:room_content:v2:catalog_version 值被污染为 "386\n"（带换行符），CAS Lua 脚本做字符串比较永远失败。来源是某次手动 echo 386 | redis-cli -x SET ...，echo 默认追加 \n。 排查过程中犯的错误 1. 无脑怀疑代码逻辑 — 假设是 retry 逻辑 bug、version...

---

### [你正在审查另一个 AI 助手编写的计划/代码。你的任务是独立验证其正确性。](./debugging/CoreReviewer.md)

**分类**: debugging

1. 逻辑是否正确？ 2. 是否遗漏了边界情况？ 3. 是否存在安全隐患？ 4. 是否符合既定需求？ 不要建议重构、重命名、风格调整或添加注释。只报告 bug、逻辑错误和安全问题。 在一轮回答内报告完整

---

### [下游 API 调用的 Contract Test](./debugging/downstream-api-contract-test.md)

**分类**: debugging

问题 重构、清理代码时，容易无意中删除或遗漏传给下游服务的关键参数。普通单元测试只验证"我的逻辑对不对"，不验证"我发出去的 request 长什么样"。 案例 2026-06 soulslive-be：重构 host config 时清理了一段"看起来多余"的 cvi_config 默认注入代码，导致 CreateIVISession gRPC 请求丢失 max_duration_seconds...

---

### [骨架屏 CLS：`min-h-full` + `justify-end` 在动态高度容器中引发布局抖动](./debugging/skeleton-cls-min-h-full-justify-end.md)

**分类**: debugging

现象 聊天页面骨架屏使用 min-h-full flex-col justify-end 让占位气泡贴底显示。页面加载时骨架屏出现后往上跳 8-12px。 根因 骨架屏所在的滚动容器（overflow-y-auto flex-1）高度由外层 flex 布局动态分配。当组件树中任何兄弟/祖先元素触发 cascading setState（比如初始化 effect 重置一批状态），会导致容器 offs...

---

### [02 · Agent 使用与构建的最佳实践](./Agent/02-agent-best-practices.md)

**分类**: Agent

> 目标读者：既用现成 Agent（Claude Code / Cursor），也自己在写 Agent 的开发者。本章总结的都是从 Claude Code 泄漏源码、Anthropic 博客、OpenAI Harness Engineering、Hermes 源码里交叉验证过的做法。 2.1 心法：三句话记牢 1. 上下文是你能写出的最值钱代码。模型能力很快会变，你写的规约、工具描述、skill ...

---

### [04 · Hermes Agent 实现原理](./Agent/04-hermes-agent-internals.md)

**分类**: Agent

> Hermes Agent（nousresearch/hermes-agent）是 NousResearch 开源的 Python Agent 框架，在 2025-2026 出圈靠的是"不是又一个 Agent，而是真的在做代理操作系统"这个定位。这一章的价值在于：它完全开源可读，和 Claude Code（闭源但泄漏）形成完美对照，你可以在 Hermes 源码里验证第 02/03 章提到的设计决...

---

### [05 · OpenClaw 实现原理 + 安全问题 + 沙盒](./Agent/05-openclaw-internals-security.md)

**分类**: Agent

> OpenClaw（openclaw/openclaw）是 Steipete（PSPDFKit 创始人）发起的开源桌面 AI 助手，2025 下半年到 2026 一路涨到 360K star，成为开源 Agent 顶流。但它同时也是过去一年里被安全社区"锤"得最狠的项目 —— 因为它展示了一件事：工程能力很强的团队，用 AI 高速写代码，仍然可能得到一个"默认裸奔"的安全架构。1 5.1 项目概...

---

### [10 · Agent 安全与攻防（威胁建模 / 注入 / OWASP / 沙盒）](./Agent/10-agent-security-threats.md)

**分类**: Agent

> 2024–2026 是 AI 安全事件井喷的两年：从 M365 Copilot 的间接注入、ChatGPT Connectors 的数据外带、Cursor MCP 的 rule injection，到豆包手机 INJECT_EVENTS 争议，再到 OpenClaw 默认不安全的公开羞辱 —— Agent 安全不再是学术话题。这一章系统过一遍威胁模型、真实事件和防御架构。 10.1 威胁模型全...

---

### [11 · Coding Agent 军备竞赛横向对比](./Agent/11-coding-agent-landscape.md)

**分类**: Agent

> 2025–2026 是 "Coding Agent 军备竞赛年"：Anthropic Claude Code 从 CLI 长成 IDE + 云端三形态、Cursor 估值破百亿、OpenAI Codex CLI 回归、Microsoft Copilot Workspace 转 agentic、国内腾讯 Codebuddy / 阿里 Qoder / 字节 TRAE 同台登场。选型焦虑从"用不用 ...

---

### [01 · Agent 知识体系与设计结构](./Agent/01 · Agent 知识体系与设计结构.md)

**分类**: Agent

> 本章是整套文档的"地图"。读完你应该能：用统一词汇描述一个 Agent、知道主流架构谱系的来龙去脉、看见一个陌生 Agent 项目能迅速拆出它的五大件。 1.1 Agent 是什么 —— 一句话到一张图 LLM Agent 的最通俗定义：能自己决定"下一步干什么"的 LLM 驱动程序。更工程化的说法来自 Anthropic 2025 年那篇《Building Effective Agents》...

---

### [03 · Claude Code 泄漏源码分析](./Agent/03-claude-code-leak-analysis.md)

**分类**: Agent

> 2026-03-31，Anthropic 在发布 Claude Code v2.1.88 时误把 cli.js.map（压缩前源码映射，60MB）一起推到了 npm。社区在第一时间镜像下载并反编译 —— 51.2 万行 TypeScript、1903 个文件、4756 个模块。这是工业级 Agent 史上最大规模的"事故级"开源，比起读博客学架构，这直接把一家头部 AI Lab 最好的 Age...

---

### [07 · Token 压缩 · 长期记忆 · 移动侧 · 多 Agent](./Agent/07-token-memory-multi-agent.md)

**分类**: Agent

> 这四个主题其实都在回答同一个问题："怎么让 Agent 跑得更久 / 记得更多 / 动得更稳"。本章横向对比。 7.1 Token 压缩策略全景 四个流派 四种不是互斥，主流系统都是组合拳。 六个代表实现的横向表 | 方案 | 流派 | 触发 | 保留策略 | 特色 | | --- | --- | --- | --- | --- | | Claude Code 6 层 | 1+2+4 | ms...

---

### [06 · 豆包手机 OS：原理 / 安全 / 交互](./Agent/06-doubao-phone-os.md)

**分类**: Agent

> 2025-12-01，字节跳动联手中兴子品牌努比亚发布 努比亚 M153 豆包手机（3499 元，首批 3 万台 24 小时售罄），被广泛认为是"全球首款系统级 AI Agent 手机"。上市一周后多个国民级 App 连夜封禁它，一度成为 2025 年末中国科技圈最戏剧性的事件 —— 技术上它代表了系统级 GUI Agent 的上限，商业/合规上它暴露了移动 Agent 面临的全部挑战。123...

---

### [09 · AI 开发模式：SDD / Harness / Vibe / Context Engineering](./Agent/09-ai-dev-paradigms.md)

**分类**: Agent

> "我每天要和 AI 一起写代码" 的个人开发者，理应知道这条范式演进的主线。本章把 2023→2026 出现的几种主流 AI 编程范式摆在一起，说清它们解决什么、什么时候用、有什么局限。 9.1 三代工程范式演进 | 代际 | 核心动作 | 代表工具 | 优势 | 局限 | | --- | --- | --- | --- | --- | | Prompt Engineering | 调措辞、F...

---

### [08 · AI 新概念补充（MCP / Benchmark / Obs / RAG 2.0 / CUA / UX / 推理）](./Agent/08-new-ai-concepts.md)

**分类**: Agent

> 2024–2026 在 Agent 领域涌现出一批新概念。这一章把你在别的文档里碰到"这词什么意思" 时需要的名词解释、关键出处、一句话价值判断集中在一起。 8.1 MCP（Model Context Protocol）深潜 一句话定义 > MCP 把 "LLM 接工具" 这件事抽象成 JSON-RPC 协议，让一个 MCP Server 能被多个 Client（Claude Desktop ...

---

### [12 · 中国 Agent 生态全景](./Agent/12-china-agent-ecosystem.md)

**分类**: Agent

> 2024–2026 的中国 AI 厂商有一个共同动作：从"做模型" 切到"做 Agent"。因为模型差距开始收敛（Qwen/GLM/DeepSeek 已经追上），而应用层（Agent）才是最后能差异化的地方。本章盘点主要玩家、标志性产品、技术路线、以及和海外头部的对标关系。 12.1 玩家象限 12.2 标志性产品技术剖析 | 产品 | 定位 | 技术亮点 | 模型底座 | 可用性 | | -...

---

### [设计禁令：标识符推断与兜底策略](./architecture/design-ban-identifier-inference.md)

**分类**: architecture

禁止从标识符推断业务属性 ID、key 名、文件名是身份标识，不是数据源。禁止用正则或字符串匹配从标识符中提取业务含义。 规则 业务属性（product_id、category、is_xxx 等）必须通过显式字段声明 如果需要关联，在数据结构里加字段；如果来源是外部调用，通过参数显式传入 最差的设计也应该是一个 is_product: true 的 flag，而不是靠正则匹配 ID 格式 事故案例...

---

### [LLM API 中转站验证方案](./llm-ops/verify-api-proxy.md)

**分类**: llm-ops

问题背景 第三方 LLM API 中转站（代理服务）可能存在的问题： - 声称是 GPT-4/Claude Opus，实际调用更便宜的小模型 - Token 计数造假，多收费 - 缓存旧响应，不是实时调用 - 记录用户 prompts（隐私风险） 验证维度矩阵 | 维度 | 检测目标 | 成本 | 可靠性 | |------|---------|------|--------| | 模型自我认知 ...

---

### [LinkedIn Code Review 最佳实践](./engineering/linkedin-code-review-practices.md)

**分类**: engineering

来源 - URL: https://thenewstack.io/linkedin-code-review/ - 作者: Szczepan Faber LinkedIn Development Tools Tech Lead - 时间: 2017-09 - 背景: LinkedIn 完成 100 万次 code review 后的经验总结；2011 年起强制全员 CR 核心观点 组织层面收益 1....

---

### [Agent 行为评测与优化](./skills/improving-agent-behavior/SKILL.md)

**分类**: skills

核心原则 执行 Execute → Evaluate → Optimize → Re-evaluate。历史轨迹已有 Execute 产物时，从 Evaluate 开始。 把评测与修改分开：先用证据测评并与用户讨论，再获得针对精确修改清单的确认，最后修改和复测。 <HARD-GATE> 在完成 Eval、讨论方案并获得用户对精确修改清单的明确确认前，不得修改任何规则、Skill、测试、业务代码或外...

---

### [BE 后端评审](./skills/backend-review/SKILL.md)

**分类**: skills

本技能整理已有后端结构、Go 可读性、消费点覆盖与 ID 精度规则。默认只读，不因评审而修改代码或发布；按用户给定的范围选用模块，不把所有专项强制执行一遍。 选择已有检查模块 | 用户任务或改动证据 | 读取材料 | 交付 | |---|---|---| | 结构、职责、规则分叉、状态所有权、隐藏副作用或配置发布依赖 | 结构评审references/structure.md | 结构发现、配置发...

---

### [GitHub Web Publish](./skills/github-web-publish/SKILL.md)

**分类**: skills

通过当前可用的 Computer Use 能力操作已连接且已登录的 Chrome，在 GitHub 网页中编辑、创建或上传仓库文件，并完成网页提交与结果验证。 硬性边界 - 只使用 GitHub 网页提供的 Edit、Create new file、Upload files 和 Commit changes 等界面完成远程写入。 - 使用当前环境提供的 Computer Use 接口并遵守它当轮返...

---

### [FE 前端评审](./skills/frontend-review/SKILL.md)

**分类**: skills

保持前端变更可读、可评审，并按职责划分。优先使用清晰的领域名称，避免在大组件中堆积内联实现。默认只读；用户明确要求实现或重构时，使用文末已有的实现清单。 评审前定位 评审或编辑前先确认： - 框架和项目现有约定。 - 本次涉及的文件和行数。 - 改动属于页面级功能、复用 UI、数据转换、样式调整还是有状态行为。 - 检查实际调用关系，确定新增或抽取的组件、hook 所属的最小范围，并统计该范围内已...

---

### [《[项目名] 架构评估》](./skills/architecture-decision-rfc/template.md)

**分类**: skills

0. 背景与范围 - 背景： - 当前痛点： - 目标： - 非目标： - 关键约束（时间/人力/兼容/成本）： - PRD： - Figma 文件及相关页面/节点： - 现有实现证据： - Figma 适用性（已读取/证据不足/不适用及理由）： - PRD、Figma、Tech Design、现有实现的冲突与决策： 1. 问题陈述 1.1 架构范式差异 - 当前范式： - 新需求范式： - 冲突...

---

### [架构评估自检清单](./skills/architecture-decision-rfc/checklist.md)

**分类**: skills

输入证据与交互 - 是否判断本方案是否影响用户可见页面或交互 - 适用时是否实际读取相关 Figma 页面、节点、原型连线和注释，而非只看截图 - 不适用时是否记录“Figma 不适用”及理由 - Figma 缺失或无法访问时，是否将方案完整性标记为证据不足 - 是否覆盖主路径、loading、空态、成功、失败、重试、取消和重复操作 - 是否将关键交互映射到接口、字段、状态所有者、后端副作用及幂等...

---

### [架构评估与决策](./skills/architecture-decision-rfc/SKILL.md)

**分类**: skills

用于把“想法讨论”收敛为“可执行方案”。 使用方式 1. 收集输入：背景、现状、目标、约束、非目标、时间窗口、PRD、Figma 和现有实现。 2. 判断是否涉及用户可见页面或交互： - 适用时实际读取相关 Figma 页面、节点、原型连线和注释，提取状态、动作、异常分支和数据需求。 - 无法找到或访问 Figma 时，将其列为阻塞方案完整性的待确认项，不凭经验补全。 - 纯基础设施或无 UI 变...

---

### [zsh-compatible: use find instead of glob to avoid NOMATCH error](./skills/plan-eng-review/SKILL.md)

**分类**: skills

<!-- AUTO-GENERATED from SKILL.md.tmpl — do not edit directly --> <!-- Regenerate: bun run gen:skill-docs --> Preamble run first If PROACTIVE is "false", do not proactively suggest gstack skills AND d...

---

### [Release Orchestrator](./skills/release-orchestrator/SKILL.md)

**分类**: skills

把已经开发完成的 Feature 安全地逐步发布。先在内部建立完整依赖图，再一次只交付一个当前可执行的 MR；前序发布和验证没有完成时，不推进后续 MR。 入口边界 把以下内容视为已在开发阶段完成： - 代码 review、测试和必要修复。 - 配置与发布依赖的完整性审查。 - Feature 的开发依赖或发布依赖文档维护。 - 最终 feat 分支作为功能代码真相源。 不要调用其他 code r...

---

### [技术方案交互、接口与数据评审](./skills/tech-design-data-review/SKILL.md)

**分类**: skills

基于 Figma 交互、实际接口、请求预算、耗时证据、调用路径、SQL、DDL、索引和容量证据给出可执行的评审结论。不要只复述 Tech Design，也不要把个人偏好包装成 Finding。 评审边界 - 默认只读评审；除非用户明确要求，否则不要修改代码、文档、数据库或远端状态。 - 优先检查用户给出的 PRD、Figma、Tech Design、MR/PR 和代码；缺少材料时再搜索关联实现。 ...

---

### [Go 代码可读性](./skills/backend-review/references/go-readability.md)

**分类**: skills

执行只读审核。除非用户明确要求修改，否则不要编辑被审代码。 审核边界 只报告本次变更新增或明显加剧的问题。阅读足够的调用者、类型定义和测试来理解变更，但不要把审核扩张为历史代码清理。 本层只回答“代码是否容易被准确理解和安全修改”。以下内容只记录为待进入其他审核层的风险，不在没有证据时下结论： - 业务逻辑是否正确。 - 是否存在数据竞争、死锁或内存模型问题。 - 性能、容量和资源消耗是否满足目标...

---

### [代码结构评审](./skills/backend-review/references/structure.md)

**分类**: skills

实现完成后的结构体检，只读。除非用户明确要求，不改被审代码。 关注结构和可维护性：规则有没有分叉、状态归谁管、抽象值不值、体量是否失控、配置有没有漏登记。 不猎 bug（那是 code review / 安全评审的活），不追覆盖率数字，不提格式化偏好。 审查重构时同时比较变更前后，核对规则实现数量、状态所有者、调用跳转、可变状态入口和契约是否收敛。用户要求判断重构目标时可以说明仍存缺口，但不将未加...

---

### [消费点覆盖与标识符完整性](./skills/backend-review/references/dependency-and-identifiers.md)

**分类**: skills

对被多处消费的依赖做覆盖面体检，对跨边界标识符做精度完整性检查。只读；除非用户明确要求，不改被审代码。 根据 diff 回答适用的问题： - 依赖覆盖：这次改造是否覆盖了该依赖的全部消费点；没覆盖的是否是有意保留。 - 标识符完整性：标识符从生产到消费是否保持逐位一致，是否可能因浮点数或隐式类型转换映射到另一主体。 本模块不查结构好坏（结构由同包 structure.md 覆盖），不做与上述两类风...

---

### [Agent 行为 Eval 量表](./skills/improving-agent-behavior/references/evaluation-rubric.md)

**分类**: skills

使用边界 只评价样本中可见的消息、工具操作和产物。先还原当时 Agent 能知道什么，再判断行为；不要依据隐藏推理、后来补充的信息或最终结果反推当时必然犯错。 样本不完整时标记未知。除非表达方式造成误解、延迟或范围漂移，否则不评价个人风格。 评分 对每个维度给出 0～4 分并引用证据： - 4：行为完整可靠，没有实质缺口。 - 3：总体正确，存在轻微但不影响主目标的缺口。 - 2：部分正确，但有明...

---
