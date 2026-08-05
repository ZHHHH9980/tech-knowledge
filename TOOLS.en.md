[简体中文](./TOOLS.md) | **English**

# Optional Tool and Environment Configuration

This file contains rules tied to specific accounts, CLIs, directory layouts, or local toolchains. `CLAUDE.en.md` does not import it automatically. Select only the sections that match the environment, or explicitly add `@TOOLS.en.md` to a personal configuration.

## GitLab and `glab`

- Access GitLab with the `glab` CLI instead of generic page-fetching tools that cannot complete the organization's login flow.
- Inspect an MR diff with `glab mr diff <id> --repo <group/project>`.
- Before opening an MR, run `glab mr list --repo <group/project>` to inspect prior MRs and infer the correct target branch.
- Create the MR with `glab mr create`, using a clear title and description.

## Feishu and `lark-cli`

- Read Feishu documents only with `lark-cli`; do not use WebFetch or browser automation.
- For URLs such as `*.feishu.cn/wiki/*` and `*.feishu.cn/docx/*`, first run:

```bash
npx @larksuite/cli docs +fetch --doc "<URL>" --format pretty
```

- If the CLI fails, diagnose its login state and subcommand usage instead of falling back to Chrome DevTools, Playwright, or asking the user to paste the document.

## Codex, Agents, and Search Delegation

- For long-running investigations, read-only reviews, and second opinions, prefer an appropriate Codex plugin when it is a better fit, but do not turn it into a mandatory automation step.
- Reuse files and conclusions already available in the current conversation instead of searching again.
- Handle precise lookups such as a known file and symbol, a single-file read, or `git log -1` directly.
- Delegate broad searches across files, call-chain mapping, large log scans, multi-MR or commit summaries, and exploratory searches with uncertain keywords to a low-cost exploration agent.
- Require delegated results to contain only file paths, line numbers, and one-sentence conclusions rather than large raw code or log excerpts.

## RTK

- Prefix shell commands with `rtk` by default to compress command output:

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

- Let RTK hooks handle truncated output from commands such as `rg`, `find`, `grep`, and `glab`.
- Common diagnostics:

```bash
rtk --version
rtk gain
rtk gain --history
which rtk
```

- Use `rtk proxy <cmd>` when unfiltered raw output is required.

## Memory Workflow

- At the start of a new task, if `claude-mem` is available, search for related history using the repository, module, file path, error code, or requirement keywords.
- Inspect only the first five results by default, summarize them into three to six short points, and then begin implementation or investigation.
- Expand a full observation only when the index result is highly relevant. Prefer search results and the timeline over fetching the entire record.
- Store only reusable information: decisions, verified fixes, important gotchas, effective commands, explicit constraints, and unfinished work.

## Local References

- Detailed formatting templates and reference guides live under `~/Documents/claude-workflow/refs/` and are injected by the appropriate hook when needed; do not preload them.
- `~/Public/tech-knowledge/` stores reusable technical experience across projects. Read the relevant document directly when needed; rebuild its index with:

```bash
cd ~/Public/tech-knowledge && python3 build_index.py
```

The current index includes:

- `llm-ops/verify-api-proxy.md`: LLM API proxy verification.
- `architecture/llm-layered-fallback.md`: layered fallback for LLM calls.
- `architecture/preflight-routing-dynamic-tools.md`: preflight routing and dynamic tool sets.
- `architecture/llm-tool-calling-fault-tolerance.md`: tool-argument tolerance and FC loop recovery.
- `architecture/design-ban-identifier-inference.md`: banning identifier inference and implicit fallbacks.
- `concurrency/websocket-channel-backpressure.md`: WebSocket backpressure handling.
- `concurrency/turn-lock-prelock-multi-tab.md`: multi-tab race protection.
- `debugging/redis-cas-data-pollution.md`: Redis contamination causing CAS failure.
- `debugging/downstream-api-contract-test.md`: downstream API contract tests.

## Network Debugging Tools

- Do not run commands that modify system networking, including `w2 proxy`, `networksetup -set*proxy`, or VPN, DNS, and routing commands.
- For Whistle, only provide rule text or edit Whistle's own rules; the user configures the browser proxy.
