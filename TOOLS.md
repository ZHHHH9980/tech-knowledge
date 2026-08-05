**简体中文** | [English](./TOOLS.en.md)

# 可选工具与环境配置

本文件收纳依赖具体账号、CLI、目录结构或本地工具链的规则，不由 `CLAUDE.md` 自动导入。仅在环境匹配时选择所需章节，或在个人配置中显式添加 `@TOOLS.md`。

## GitLab 与 `glab`

- GitLab 访问使用 `glab` CLI，不使用无法通过组织登录流程的通用网页抓取工具。
- 查看 MR diff：`glab mr diff <id> --repo <group/project>`。
- 提 MR 前运行 `glab mr list --repo <group/project>` 查看历史 MR，推断正确的 target branch。
- 使用 `glab mr create` 创建 MR，title 和 description 清晰描述本次改动。

## 飞书与 `lark-cli`

- 飞书文档只用 `lark-cli` 读取，不使用 WebFetch 或浏览器自动化。
- 遇到 `*.feishu.cn/wiki/*`、`*.feishu.cn/docx/*` 等链接时，先执行：

```bash
npx @larksuite/cli docs +fetch --doc "<URL>" --format pretty
```

- CLI 报错时先排查登录态和子命令，不退回 Chrome DevTools、Playwright 或要求用户粘贴文档内容。

## Codex、Agent 与搜索派发

- 长耗时排查、只读审查和第二意见类任务，优先考虑交给合适的 Codex 插件处理，但不把它变成强制自动化流程。
- 本会话已读过的文件和已有结论不重复搜索，直接引用上下文。
- 已知文件路径与符号名的定位、单文件读取、`git log -1` 等单点查询直接执行。
- 跨多文件找实现、理清调用链、扫描大段日志、汇总多个 MR 或 commit，以及关键词不确定的探索性搜索，交给低成本探索 Agent。
- 派发时要求只返回文件路径、行号和一句话结论，不返回大段原始代码或日志。

## RTK

- Shell 命令默认使用 `rtk` 前缀，以压缩命令输出：

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

- `rg`、`find`、`grep`、`glab` 等命令的输出截断由 RTK hook 处理。
- 常用诊断命令：

```bash
rtk --version
rtk gain
rtk gain --history
which rtk
```

- 需要查看未过滤原始输出时使用 `rtk proxy <cmd>`。

## Memory Workflow

- 新任务开始时，如果 `claude-mem` 可用，先按仓库、模块、文件路径、错误码或需求关键词搜索相似历史。
- 默认只查看前 5 条结果，先总结成 3–6 条简短要点，再进入实现或排查。
- 只有在索引结果高度相关时，才展开完整 observation；优先使用搜索结果和 timeline，而不是直接拉全文。
- 只把可复用的信息沉淀回记忆：决策、已验证修复、关键 gotcha、有效命令、明确约束和未完成事项。

## 本地参考资料

- 详细格式模板和参考指南位于 `~/Documents/claude-workflow/refs/`，由对应 hook 在需要时注入，不预加载。
- `~/Public/tech-knowledge/` 是跨项目技术经验库。遇到相关问题时直接读取对应文档；重建索引：

```bash
cd ~/Public/tech-knowledge && python3 build_index.py
```

当前索引包括：

- `llm-ops/verify-api-proxy.md`：LLM API 中转站验证。
- `architecture/llm-layered-fallback.md`：LLM 分层 Fallback。
- `architecture/preflight-routing-dynamic-tools.md`：Preflight 分类路由与动态工具集。
- `architecture/llm-tool-calling-fault-tolerance.md`：Tool 参数容错与 FC Loop 恢复。
- `architecture/design-ban-identifier-inference.md`：禁止标识符推断与隐式兜底。
- `concurrency/websocket-channel-backpressure.md`：WebSocket 背压处理。
- `concurrency/turn-lock-prelock-multi-tab.md`：多 Tab 竞态保护。
- `debugging/redis-cas-data-pollution.md`：Redis 数据污染导致 CAS 失败。
- `debugging/downstream-api-contract-test.md`：下游 API Contract Test。

## 网络调试工具

- 不执行会修改系统网络设置的命令，包括 `w2 proxy`、`networksetup -set*proxy` 以及 VPN、DNS、路由相关命令。
- Whistle 只提供规则文本或修改 Whistle 自身规则；浏览器代理由用户配置。
