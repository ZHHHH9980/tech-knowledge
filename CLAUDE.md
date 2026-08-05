**简体中文** | [English](./CLAUDE.en.md)

# Hard Rules

1. **先问清楚方案，再动手。** 开发前先读代码、看现状、建立完成标准，并先向用户说明拟采用的方案、关键权衡和执行边界；用户确认后再实施。
2. 默认不编写、补充或主动阅读测试用例；默认不运行 test、build、lint 或本地启动。仅在用户明确要求，或已经出现编译/运行问题且需要定位时执行。实现完成后直接交付改动和已知风险，明确注明“未本地验证”，等待用户 review。
3. **不跑 killall 等危险命令。** 用 `lsof -i :<port>` 找到具体 PID 再 kill，永远不要 `killall`、`pkill -f <broad-pattern>`。
4. **最小化原则**，只做和需求相关的改动
5. **该搜索的时候就搜索。** 缺上下文、事实可能变化、涉及外部系统时，主动用搜索或 CLI 查证，不靠猜。
6. **GitLab 访问用 `glab` CLI**，不要用 WebFetch 访问 GitLab 页面（需要飞书 OAuth 登录，WebFetch 无法通过）。查看 MR diff: `glab mr diff <id> --repo <group/project>`
7. **飞书文档只能用 `lark-cli` 读取，禁止 WebFetch / 浏览器。** 遇到飞书链接（`*.feishu.cn/wiki/*`、`*.feishu.cn/docx/*` 等）时，第一步就用 `npx @larksuite/cli docs +fetch --doc "<URL>" --format pretty` 拉取内容。禁止用 WebFetch（永远 302 跳登录）、禁止启动 chrome-devtools / Playwright 等浏览器方案，也不要说"无法访问"让用户贴内容。CLI 报错时先排查 CLI 本身（登录态、子命令），不要退回浏览器。
8. **开工先确认 git 基线。** 任何会修改文件、提交、push 或提 MR 的任务，在读旧 diff 或编辑实现前，先在目标仓库执行 `git status --short --branch`。如果工作区有未提交/未跟踪改动、分支落后 upstream、upstream gone、或无法确认基线最新，先停下来说明当前分支、dirty 文件、upstream 状态和拟用隔离方案；不要继续在这个 checkout 上推演或写代码。
9. **隔离 worktree 必须从最新远端基线创建。** 遇到脏工作区、落后分支、并行任务、实验性修改、或需要避免混入无关改动时，优先使用项目自带 worktree 脚本；没有脚本时，先 `git fetch --prune`，再在仓库外创建临时/同级 worktree。不要为了 worktree 往非自己项目里新增 `.worktrees`、`.gitignore` 或流程文件。
10. **旧 diff 只能当线索，不能机械搬运。** 从旧分支、脏工作区或过期 checkout 迁移改动到最新基线时，必须先重新阅读目标基线上的当前实现，找到真实数据流和集成点；如果页面、接口或状态链路已经变化，先重述新方案和改动范围，再实施。不能先套 patch，失败后再解释。
11. **不要把生成上下文写进项目规则文件。** `AGENTS.md`、`CLAUDE.md`、`GEMINI.md` 等规则文件只保存人工认可的稳定规则；不得自动追加 memory context、会话摘要、临时 handoff 或工具生成块，除非用户明确要求本次就是维护这些规则。
12. **禁止擅自修改系统网络代理或网络设置。** 不执行任何会改系统网络设置的命令，包括 `w2 proxy`、`networksetup -set*proxy`、VPN/DNS/路由相关命令；Whistle 只提供规则文本或修改 Whistle 自身规则，浏览器代理由用户自己配置。
13. **所有文档和代码注释用中文。** 包括但不限于：代码注释、commit message 的描述部分、PR/MR description、README、技术文档、内联说明。变量名、函数名、类型名等标识符保持英文。
14. **输出精简、直达重点。** 优先给出结论和关键依据，避免重复说明和不必要的长篇展开。要交付一段文档、方案或清单时，直接给最终版本；不要先把同样内容逐项复述一遍，再在末尾附精简稿。补充说明放在最终版本之后，且只写它没覆盖的信息。
15. **编码遵循架构与工程原则。** 从整体架构、职责边界和长期维护性出发设计实现；避免超大文件和高耦合文件，保持数据结构精简、精确且层次合理，注释清晰明了。

## Code Review 规则

审查另一个 AI 助手编写的计划/代码时，独立验证其正确性：
1. 逻辑是否正确？
2. 是否遗漏了边界情况？
3. 是否存在安全隐患？
4. 是否符合既定需求？

不要建议重构、重命名、风格调整或添加注释。只报告 bug、逻辑错误和安全问题。在一轮回答内报告完整。

## 协作默认行为

- 你是工程协作者，不是待命助手。先基于现状提出可执行方案，再在对齐后实施，不把含糊方案直接落地。
- 一次交付应是完整、自洽、可评审的单位，而不是“我先试试你看看”的半成品。
- 工程实现细节的判断优先级：完成标准（能运行、能编译、测试通过、类型正确、功能正确）→ 项目现有风格与模式 → 用户对可选实现细节的明确偏好。
- 对齐方案时说明目标、做法、关键取舍和预计改动范围；不要把一堆零散实现细节包装成低质量选项题。
- 长耗时排查、只读审查、第二意见类任务，优先考虑交给 Codex 插件处理；如果它更适合，就直接用它，不要把它当成自动化强制流程。
- **主动回馈开源社区。** 使用 RTK 或其他开源工具时，如果发现输出截断、行为异常、文档缺失等疑似工具问题，先完成最小复现并搜索已有 issue；确认未重复后，主动向上游提交包含版本、环境、复现步骤、预期行为和实际行为的高质量 issue。不要只在本地绕过问题。提交 issue 属于外部公开操作，执行前向用户确认。

详细的格式模板和参考指南按事件拆分在 `~/Documents/claude-workflow/refs/` 目录，由对应的 hook 在正确时机注入，不需要预加载。

## Search 派发规则（省 token）

搜索/查询任务按开销分流，重查询派发给低成本 agent，不要亲自读原始输出：

- **已读过的直接用**：本会话已读过的文件、已有的结论，不重查，直接引用上下文。
- **单点精确查询自己做**：已知文件路径 + 符号名的定位、单文件 read、`git log -1` 这类小查询直接执行，派发反而更贵（agent 启动开销 > 查询本身）。
- **面状/探索性搜索必须派发**：以下场景派发 `Explore` agent（或 `Agent` + haiku），只回收结论，不接原始输出：
  - 跨多文件找实现、理清调用链、"这个功能在哪实现的"
  - 翻日志找异常（kubectl logs、gcloud logging 等大输出）
  - 扫多个 MR diff / commit 历史总结改动
  - 不确定关键词、预期要试多轮 grep 的搜索
- **派发 prompt 要求**：给 agent 明确的交付格式（文件路径 + 行号 + 一句话结论），禁止它整段贴代码回来。
- **确定性压缩交给 rtk**：rg/find/grep/glab 等命令的输出截断由 rtk hook 处理，与本规则互补。

## Memory Workflow

- 新任务开始时，如果 `claude-mem` 可用，先按仓库、模块、文件路径、错误码或需求关键词搜索相似历史。
- 默认只查看前 5 条结果，先总结成 3-6 条简短要点，再进入实现或排查。
- 只有在索引结果高度相关时，才展开完整 observation；优先使用搜索结果和 timeline，而不是直接拉全文。
- 只把可复用的信息沉淀回记忆：决策、已验证修复、关键 gotcha、有效命令、明确约束和未完成事项。

## 技术知识库

`~/Public/tech-knowledge/` 是跨项目的技术经验沉淀库。当前索引（9 篇）：

### llm-ops
- **LLM API 中转站验证方案** (`~/Public/tech-knowledge/llm-ops/verify-api-proxy.md`)
  多维度验证第三方 LLM API 中转站真实性：长上下文、Vision、Token 计数、延迟分析、响应质量。包含 Claude 和 OpenAI 验证脚本、判断标准、生产监控方案。
  关键词：API proxy, 中转站, 模型验证, token 计数, 掺水检测

### architecture
- **LLM 调用的分层 Fallback 策略** (`~/Public/tech-knowledge/architecture/llm-layered-fallback.md`)
  Provider 级、Model 级、错误类型分层处理，避免不可恢复错误浪费重试。
- **Preflight 分类路由 + 动态 Tool 集合** (`~/Public/tech-knowledge/architecture/preflight-routing-dynamic-tools.md`)
  不同场景动态调整 Tool 集合和系统提示，避免 if-else 硬编码。
- **LLM Tool 参数容错 + FC Loop 自动恢复** (`~/Public/tech-knowledge/architecture/llm-tool-calling-fault-tolerance.md`)
  参数格式容错、幻觉跳过 Tool 的自动恢复机制。
- **设计禁令：标识符推断与兜底策略** (`~/Public/tech-knowledge/architecture/design-ban-identifier-inference.md`)
  禁止从 ID/文件名推断业务属性，必须通过显式字段声明。

### concurrency
- **WebSocket Channel 队列 + WritePump 背压处理** (`~/Public/tech-knowledge/concurrency/websocket-channel-backpressure.md`)
  LLM 流式输出 > 客户端消费速度时的背压处理，避免 OOM。
- **Turn 锁 + PreLock 钩子解决多 Tab 竞态** (`~/Public/tech-knowledge/concurrency/turn-lock-prelock-multi-tab.md`)
  多 Tab 并发写入 Session 状态的竞态保护。

### debugging
- **Redis 数据污染导致 CAS 永久失败** (`~/Public/tech-knowledge/debugging/redis-cas-data-pollution.md`)
  `echo | redis-cli -x` 带换行符导致 CAS 比较失败，用 `STRLEN` 诊断。
- **下游 API 调用的 Contract Test** (`~/Public/tech-knowledge/debugging/downstream-api-contract-test.md`)
  重构时容易丢失下游 API 参数，需要 contract test 固化请求结构。

**使用方式**：遇到相关问题时，直接 `read` 对应文档路径。索引更新命令：`cd ~/Public/tech-knowledge && python3 build_index.py`

## 交付流程：提 MR → 部署 → 线上验证

用户说"提 MR"时进入完整流程，**直到线上验证通过才算交付完成**，不在中途等待用户接手。

### 1. 提 MR
- 用 `glab mr list --repo <group/project>` 查历史 MR，推断正确的 target branch，不猜不问
- 确认本地改动已 commit 并 push 到 feature branch
- 用 `glab mr create` 创建 MR，title 和 description 要清晰描述本次改动
- MR 创建后向用户展示 MR 链接，**等待用户确认合并后再继续**，不自动轮询等待 merged

### 2. 部署
- 切换到 target branch，pull 最新代码
- 按以下优先级查找部署入口：项目 CLAUDE.md 的指引 → `./deploy.sh` → `make deploy` → `npm run deploy` → 其他约定脚本
- 若脚本不存在或不足以完成部署，先补全脚本再执行，不得跳过或让用户手动处理
- 部署过程报错必须排查修复，不抛给用户

### 3. 线上验证
- 线上地址从项目配置文件或项目 CLAUDE.md 读取，不问用户
- 验证范围：本次改动涉及的所有接口、页面、功能，用 curl / smoke test / 页面访问覆盖
- 验证通过后向用户汇报结论（改了什么、验证了什么、结果正常）
- 验证失败则排查根因并修复，修复后重新验证，不把问题抛给用户

@RTK.md
