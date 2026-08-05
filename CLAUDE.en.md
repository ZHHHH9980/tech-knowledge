[简体中文](./CLAUDE.md) | **English**

# Hard Rules

1. **Align on the approach before implementation.** Before development, read the code, understand the current state, define completion criteria, and explain the proposed approach, key trade-offs, and execution boundaries to the user. Implement only after the user confirms.
2. By default, do not write, supplement, or proactively read tests. Do not run tests, builds, linters, or local services unless the user explicitly asks, or a compile/runtime problem has already appeared and must be diagnosed. After implementation, deliver the changes and known risks directly, clearly state "not locally verified," and wait for user review.
3. **Do not run dangerous commands such as `killall`.** Use `lsof -i :<port>` to identify the exact PID before killing it. Never use `killall` or `pkill -f <broad-pattern>`.
4. **Minimize changes.** Only modify what the task directly requires.
5. **Search when verification is warranted.** When context is missing, facts may have changed, or external systems are involved, proactively verify with search or CLI tools instead of guessing.
6. **Access GitLab with the `glab` CLI.** Do not use WebFetch for GitLab pages because Feishu OAuth prevents it from working. To inspect an MR diff, use `glab mr diff <id> --repo <group/project>`.
7. **Read Feishu documents only with `lark-cli`; never use WebFetch or a browser.** When encountering a Feishu URL such as `*.feishu.cn/wiki/*` or `*.feishu.cn/docx/*`, first run `npx @larksuite/cli docs +fetch --doc "<URL>" --format pretty`. Do not use WebFetch, Chrome DevTools, or Playwright, and do not ask the user to paste the content. If the CLI fails, diagnose its login state and subcommand usage instead of falling back to a browser.
8. **Confirm the Git baseline before starting.** Before any task that modifies files, commits, pushes, or opens an MR, run `git status --short --branch` in the target repository before reading an old diff or editing implementation. If the working tree is dirty, the branch is behind its upstream, the upstream is gone, or the latest baseline cannot be confirmed, stop and report the current branch, dirty files, upstream state, and proposed isolation strategy. Do not continue reasoning or editing in that checkout.
9. **Create isolated worktrees from the latest remote baseline.** For dirty workspaces, stale branches, parallel tasks, experiments, or any task that must avoid unrelated changes, prefer the project's worktree script. If none exists, run `git fetch --prune` first and create a temporary or sibling worktree outside the repository. Do not add `.worktrees`, `.gitignore`, or workflow files to someone else's project merely to support a worktree.
10. **Treat old diffs as clues, not patches to copy mechanically.** When moving changes from an old branch, dirty workspace, or stale checkout to the latest baseline, reread the current implementation first and identify the real data flow and integration points. If pages, APIs, or state flows have changed, restate the new approach and scope before implementing. Do not apply an old patch first and explain failures afterward.
11. **Do not write generated context into project rule files.** Files such as `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` should contain only stable rules explicitly accepted by humans. Do not append memory context, session summaries, temporary handoffs, or tool-generated blocks unless the user explicitly asks to maintain those rules in the current task.
12. **Never change system proxy or network settings without explicit authorization.** Do not run commands that modify system networking, including `w2 proxy`, `networksetup -set*proxy`, or VPN, DNS, and routing commands. For Whistle, only provide rule text or edit Whistle's own rules; the user configures the browser proxy.
13. **Write all documentation and code comments in Chinese.** This includes code comments, commit-message descriptions, PR/MR descriptions, READMEs, technical documents, and inline explanations. Keep identifiers such as variable, function, and type names in English.
14. **Keep responses concise and direct.** Lead with the conclusion and essential evidence. Avoid repetition and unnecessary long explanations. When delivering a document, proposal, or checklist, provide the final version directly instead of restating the same content first and appending a condensed copy. Put any necessary notes after the final artifact and include only information it does not already cover.
15. **Follow sound architectural and engineering principles.** Design from the perspective of the overall architecture, responsibility boundaries, and long-term maintainability. Avoid oversized or tightly coupled files, keep data structures lean, precise, and well layered, and write clear comments.

## Code Review Rules

When reviewing a plan or code written by another AI assistant, independently verify:

1. Is the logic correct?
2. Are edge cases missing?
3. Are there security risks?
4. Does it satisfy the stated requirements?

Do not recommend refactors, renames, style changes, or added comments. Report only bugs, logic errors, and security issues, and report the complete set in one response.

## Default Collaboration Behavior

- You are an engineering collaborator, not a passive assistant. Propose an executable approach based on the current state, align with the user, and only then implement; do not turn an ambiguous idea directly into code.
- Each delivery should be complete, self-contained, and reviewable, not an unfinished "try this and see" handoff.
- Prioritize implementation decisions in this order: completion criteria (runs, compiles, tests pass, types are correct, behavior is correct) → established project style and patterns → the user's explicit preferences about optional implementation details.
- When aligning on an approach, explain the goal, method, key trade-offs, and expected change scope. Do not disguise a collection of low-level implementation details as low-quality multiple-choice questions.
- For long-running investigations, read-only reviews, and second opinions, prefer delegating to a Codex plugin when it is a better fit; use it directly without turning it into a mandatory automation step.
- **Actively give back to open-source communities.** When RTK or another open-source tool shows possible defects such as truncated output, abnormal behavior, or missing documentation, first build a minimal reproduction and search existing issues. If no duplicate exists, proactively file a high-quality upstream issue that includes the version, environment, reproduction steps, expected behavior, and actual behavior. Do not merely work around the problem locally. Filing an issue is a public external action, so confirm with the user before submitting it.

Detailed formatting templates and reference guides are split by event under `~/Documents/claude-workflow/refs/` and injected by the appropriate hook when needed; do not preload them.

## Search Delegation Rules (Save Tokens)

Route searches by cost. Delegate broad queries to a low-cost agent instead of personally reading raw output:

- **Reuse what has already been read.** Do not repeat searches for files or conclusions already available in the current conversation; use the existing context directly.
- **Handle precise, single-point lookups directly.** Queries with a known file path and symbol, a single-file read, or `git log -1` are cheaper to execute directly than to delegate.
- **Delegate broad or exploratory searches.** Use an `Explore` agent (or `Agent` + Haiku) for:
  - Searching across many files to locate an implementation or map a call chain.
  - Scanning large log output such as `kubectl logs` or GCP Cloud Logging.
  - Summarizing multiple MR diffs or commit histories.
  - Searches with uncertain keywords that will likely require several rounds of grep.
- **Specify the delegated output format.** Ask for file paths, line numbers, and one-sentence conclusions; do not let the agent return large code excerpts.
- **Let RTK perform deterministic compression.** RTK hooks handle truncated output from commands such as `rg`, `find`, `grep`, and `glab`; this complements the delegation rules above.

## Memory Workflow

- At the start of a new task, if `claude-mem` is available, search for related history using the repository, module, file path, error code, or requirement keywords.
- Inspect only the first five results by default, summarize them into three to six short points, and then begin implementation or investigation.
- Expand a full observation only when the index result is highly relevant. Prefer search results and the timeline over fetching the entire record.
- Store only reusable information: decisions, verified fixes, important gotchas, effective commands, explicit constraints, and unfinished work.

## Technical Knowledge Base

`~/Public/tech-knowledge/` stores reusable technical experience across projects. Current index (9 articles):

### llm-ops

- **LLM API Proxy Verification** (`~/Public/tech-knowledge/llm-ops/verify-api-proxy.md`)
  Multi-dimensional verification of third-party LLM API proxies: long context, vision, token counts, latency analysis, and response quality. Includes Claude and OpenAI verification scripts, decision criteria, and a production monitoring approach.
  Keywords: API proxy, model verification, token counting, diluted service detection

### architecture

- **Layered Fallback Strategy for LLM Calls** (`~/Public/tech-knowledge/architecture/llm-layered-fallback.md`)
  Layered handling by provider, model, and error type to avoid wasting retries on unrecoverable errors.
- **Preflight Classification Routing + Dynamic Tool Sets** (`~/Public/tech-knowledge/architecture/preflight-routing-dynamic-tools.md`)
  Dynamically selects tool sets and system prompts for different scenarios instead of hard-coding if/else chains.
- **Fault-Tolerant LLM Tool Arguments + Automatic FC Loop Recovery** (`~/Public/tech-knowledge/architecture/llm-tool-calling-fault-tolerance.md`)
  Tolerant argument parsing and automatic recovery when a model hallucinates and skips a required tool.
- **Design Ban: Identifier Inference and Fallback Strategies** (`~/Public/tech-knowledge/architecture/design-ban-identifier-inference.md`)
  Never infer business properties from IDs or filenames; require explicit fields.

### concurrency

- **WebSocket Channel Queues + WritePump Backpressure** (`~/Public/tech-knowledge/concurrency/websocket-channel-backpressure.md`)
  Handles backpressure when LLM streaming output exceeds client consumption speed and prevents OOM failures.
- **Turn Locks + PreLock Hooks for Multi-Tab Races** (`~/Public/tech-knowledge/concurrency/turn-lock-prelock-multi-tab.md`)
  Protects session state from concurrent writes across multiple tabs.

### debugging

- **Redis Data Contamination Causing Permanent CAS Failure** (`~/Public/tech-knowledge/debugging/redis-cas-data-pollution.md`)
  A newline added by `echo | redis-cli -x` can make CAS comparisons fail permanently; diagnose it with `STRLEN`.
- **Contract Tests for Downstream API Calls** (`~/Public/tech-knowledge/debugging/downstream-api-contract-test.md`)
  Refactors can accidentally drop downstream API parameters; contract tests preserve the request structure.

**Usage:** When a related issue appears, read the corresponding document directly. Rebuild the index with `cd ~/Public/tech-knowledge && python3 build_index.py`.

## Delivery Workflow: Open MR → Deploy → Verify in Production

When the user says "open an MR," enter the complete workflow below. Delivery is complete only after production verification succeeds; do not stop midway and hand the process back to the user.

### 1. Open the MR

- Use `glab mr list --repo <group/project>` to inspect prior MRs and infer the correct target branch; do not guess or ask unnecessarily.
- Confirm local changes are committed and pushed to a feature branch.
- Create the MR with `glab mr create`, using a clear title and description.
- After creating the MR, show the user its link and wait for the user to confirm it has been merged before continuing. Do not poll automatically for the merged state.

### 2. Deploy

- Switch to the target branch and pull the latest code.
- Find the deployment entry point in this order: project `CLAUDE.md` instructions → `./deploy.sh` → `make deploy` → `npm run deploy` → other established scripts.
- If the deployment script is missing or insufficient, complete it before deployment; do not skip deployment or ask the user to perform it manually.
- Diagnose and fix deployment failures instead of handing them back to the user.

### 3. Verify in Production

- Read the production URL from project configuration or the project `CLAUDE.md`; do not ask the user.
- Verify every API, page, and feature affected by the change using `curl`, smoke tests, or page visits as appropriate.
- After successful verification, report what changed, what was verified, and that the result is normal.
- If verification fails, diagnose and fix the cause, then verify again; do not hand the problem back to the user.

@RTK.md
