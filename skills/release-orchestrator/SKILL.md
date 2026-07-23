---
name: release-orchestrator
description: 按发布依赖顺序逐个编排 MR、数据库 migration、GitLab pipeline/job、发布后验证和当前 Feature 的本地 worktree 清理，并在冲突、关键操作与删除前暂停等待用户处理或确认。用于 Feature 开始或继续 Dev、UAT、Prod 发布，决定下一个可合并 MR，处理发布冲突，观察部署状态，执行数据库迁移交接，完成上线验证，或在发布结束后清理 Feature worktree 等场景。默认一次只向用户交付一个当前可执行的 MR；不执行代码 review，也不重新审计开发期间已经维护的发布依赖。
---

# Release Orchestrator

把已经开发完成的 Feature 安全地逐步发布。先在内部建立完整依赖图，再一次只交付一个当前可执行的 MR；前序发布和验证没有完成时，不推进后续 MR。

## 入口边界

把以下内容视为已在开发阶段完成：

- 代码 review、测试和必要修复。
- 配置与发布依赖的完整性审查。
- Feature 的开发依赖或发布依赖文档维护。
- 最终 feat 分支作为功能代码真相源。

不要调用其他 code review skill，不要重复执行结构审查，也不要从头重审代码与发布依赖。读取现有文档只是为了确定发布节点、顺序、前置条件、验证方式和回滚方式。

若入口材料明确存在阻断项、信息互相矛盾或无法确定目标 Feature、仓库、分支、环境，暂停发布并只询问解决当前阻断所需的信息。不要自行补写业务结论。

## 核心不变量

1. **一次只交付一个 MR。** 可以展示完整发布顺序，但只把当前满足前置条件的一个 MR 交给用户操作。多个 MR 同时 ready 时也保持串行，除非用户明确要求并行。
2. **前序验证通过后再给后序 MR。** MR 合并或 pipeline 成功不等于节点完成；必须完成该节点对应的 migration、部署和功能验证。
3. **所有冲突先与用户对齐。** 未得到针对本次冲突解决方案的明确确认前，不解决冲突后 commit/push，不更新 MR，也不把 MR 描述为可合并。
4. **关键步骤交给用户。** MR merge、manual pipeline/job、数据库 migration job、Prod 部署、流量切换和回滚默认由用户操作。
5. **授权不顺延。** 同意解决冲突不等于同意 push；同意 push 不等于同意创建 MR；同意合并 MR 不等于同意触发或重跑 Job。
6. **先说明间接影响。** 若 merge 或 push 会自动触发 migration、部署或其他 pipeline，必须在请用户操作前明确说明。
7. **以实时状态为准。** 发布文档描述预期，GitLab、运行环境和验证结果描述实际状态。每次推进前重新读取当前状态，不沿用过期结论。
8. **验证失败立即冻结下游。** 不自动重试 Job，不跳过失败节点，不继续给出下一个 MR。
9. **验证完成后清理当前 Feature worktree。** 只删除当前 Feature 的已确认 clean worktree，不跨 Feature，不删除主 clone 或分支，不使用 `--force`。

## 操作权限

### 可直接执行的只读操作

- 读取全局、workspace、Feature 和仓库规则。
- 读取 Feature 入口、依赖文档、CI 配置和部署说明。
- `git fetch --prune` 后检查分支、提交、祖先关系和本地 dry-run 冲突。
- 使用 `glab` 查询 MR、diff、冲突状态、pipeline、job 和日志。
- 查询部署状态、健康检查、日志、监控和只读数据。
- 使用项目已有的测试凭证执行安全的接口或页面验证。

只读查询若会暴露 token、Secret、Cookie 或其他敏感值，避免打印敏感内容。

### 必须先取得本次明确确认的操作

- 解决冲突并 commit。
- push 分支。
- 创建、更新或关闭 MR。
- 重试、取消或新建 pipeline/job。
- 删除当前 Feature 的本地 worktree。
- 任何未被项目规则明确归为只读或准备类的 GitLab 写操作。

执行前展示精确仓库、分支、MR、动作和影响。用户只授权点名动作，不扩大解释。

### 默认由用户亲自操作

- 合并 MR。
- 点击 manual migration/deploy job。
- 执行生产发布、流量切换或回滚。
- 项目规则指定的其他人工关键链路。

若用户明确要求 Agent 代做某个动作，仍先服从 workspace 的人工边界；规则允许时只执行被点名的单个动作，完成后停止，不顺延到下一步。

## 建立发布依赖图

先读取适用规则和真实入口：

1. 全局与 workspace 的 `AGENTS.md`、`CLAUDE.md` 或同类规则。
2. `workspace.yaml` 或同类仓库、环境、分支索引。
3. Feature 的 `index.md`、开发依赖或发布依赖文档。
4. 涉及仓库当前的 CI 配置、部署脚本和 GitLab 实际状态。

将每个 MR、migration、基础设施准备、配置生效、部署和验证建模为独立节点。为每个节点记录：

- 仓库、环境、source/target branch、MR 和 commit SHA。
- 前置节点与完成证据。
- merge/push 后会自动触发的 pipeline 或部署。
- 需要用户操作的按钮或 Job。
- 验证方式、成功标准和回滚方式。
- 状态：`pending`、`ready`、`waiting-user`、`observing`、`verifying`、`verified` 或 `blocked`。

按显式依赖生成有向无环图，不机械照抄文档中的编号。常见顺序仅作为检查线索：

```text
基础设施 / Secret / IAM
→ 向后兼容的数据库 migration
→ 依赖新 schema 的服务
→ 网关或对外 API
→ 前端 / 客户端
→ Feature flag、入口或流量开放
```

若实际依赖不同，以 Feature 文档、代码契约和当前 CI 行为为准。删除旧列、收紧约束等破坏性数据库清理通常应拆为后续发布节点，不与依赖旧结构的服务同时推进。

对 Dev、UAT、Prod 分别应用 workspace 的分支和环境规则。不得为省步骤把环境分支合回最终 feat，也不得绕过最终 feat 在环境分支独立修复。

## 逐个 MR 推进

### 1. 选择唯一的下一个 MR

只有同时满足以下条件时，才将 MR 标记为 `ready`：

- 所有前置节点均为 `verified`。
- source/target branch 符合 workspace 分支治理。
- source 包含本次应发布的准确 commit。
- 发布依赖中没有作用于该节点的未解决阻断项。
- 当前 pipeline、环境和 MR 状态没有相互矛盾。
- 冲突检查通过。

即使多个节点满足条件，也只选择依赖图中最靠前的一个。其余节点保留为 `pending`，不同时要求用户操作。

若无法识别当前最早节点的 MR，只询问该节点所需的链接、编号或分支；不要同时向用户索取后续 MR。先完成当前节点的信息确认、合并、部署和验证，再收集下一个节点的信息。

### 2. 执行双重冲突检查

在把 MR 交给用户前：

1. `git fetch --prune` 获取 source 和 target 最新状态。
2. 使用不修改工作树的方式检查 source 合入 target 的结果。
3. MR 已存在时，再查询 GitLab 当前的冲突与可合并状态。
4. 临近用户合并前重新检查一次，避免 target 更新后使用旧结论。

发现任何冲突时立即将节点标为 `blocked`，输出：

- 冲突文件和冲突区域对应的职责。
- source 与 target 各自的意图。
- 属于机械冲突，还是业务、数据、配置、migration 等语义冲突。
- 推荐解决方式、会保留和舍弃什么、可能影响哪些环境。
- 需要用户确认的唯一问题。

所有冲突都先对齐。即使判断为机械冲突，也不要自行解决后发出。语义意图不明确时不得猜测，不得用“两个版本都保留”掩盖决策。

用户确认解决方案后，只处理已确认的冲突；重新执行测试和双重冲突检查。commit、push 或更新 MR 仍分别遵守操作权限。

### 3. 只交付一张当前 MR 卡片

每次等待用户合并时使用以下结构：

```markdown
当前步骤：<序号>/<总数> — <节点名称>

- 仓库：<project>
- MR：<链接与编号>
- 分支：<source> → <target>
- Commit：<SHA>
- 为什么现在合：<已验证的前置节点>
- 合并后的自动影响：<自动 pipeline / migration / deploy；没有则写无>
- 需要你操作：<一个精确动作>
- 操作后预期：<可观测结果>
- 停止条件：<失败或异常时不要继续什么>
```

不要在同一张卡片中附带第二个 MR 的合并请求。可以在发布顺序摘要中显示后续节点，但明确标记为“尚未轮到”。

### 4. 等待用户完成关键步骤

给出当前 MR 卡片后停止推进。用户明确表示已完成操作后，再只读确认：

- MR 是否真的 merged，以及 merged commit。
- 是否触发了预期 pipeline/job。
- 是否出现未预期的 pipeline、部署或分支变化。

状态不明确时保持 `waiting-user` 或 `blocked`，不要假定操作成功。

### 5. 观察并验证当前节点

MR 合并后按实际 CI 行为处理：

- 自动 Job：主动观察直至终态；失败时收集错误证据并冻结下游。
- Manual Job：只把当前必须点击的一个 Job 交给用户，说明名称、环境、前置条件和影响；等待点击后再观察。
- 无部署动作：确认预期产物或分支状态后执行节点验证。

#### 数据库节点

数据库 MR 必须在依赖新 schema 的 service MR 之前完成：

1. 确认数据库 MR 已合并到正确目标。
2. 确认 migration pipeline/job 对正确环境执行。
3. 若 Job 需要人工点击，把准确 Job 交给用户。
4. 确认 Job 成功且 migration 实际 applied，而不只确认 pipeline 创建成功。
5. 按依赖文档验证预期 schema、表、列、索引或 seed；优先使用只读查询。
6. 记录 migration 版本、pipeline/job 链接和验证证据。

只有数据库节点为 `verified` 后，才交付依赖它的 service MR。

#### 服务节点

确认部署的是预期 commit，并验证：

- pipeline 与目标服务部署状态。
- Pod、实例或进程健康，无 crash loop 或持续错误。
- 相关接口、消息消费或后台任务可用。
- 本次 Feature 的最小关键链路通过。

#### 前端或客户端节点

确认部署产物对应预期 commit，并验证：

- 目标环境页面或应用可访问。
- 关键入口、请求和错误态正常。
- 与已验证后端契约一致。

验证涉及写操作时，只使用 workspace 指定测试账号和隔离数据；生产环境避免不可逆业务写入。

### 6. 推进下一节点

当前节点验证通过后：

1. 标记为 `verified` 并记录证据。
2. 重新读取 GitLab 和环境状态。
3. 重新计算依赖图中唯一的下一个 `ready` MR。
4. 对该 MR 重新执行冲突检查。
5. 再交付一张新的当前 MR 卡片。

不要因为完整发布计划已经获得认可，就跳过后续 MR 的实时检查与用户操作。

## 发布后清理 Feature worktree

所有发布节点和功能验证均通过后，把 worktree 清理作为最后一个节点。完成清理前可以说明“功能发布已验证”，但不要宣告整个发布流程已关闭。

### 1. 锁定清理范围

只清理当前 Feature 的 worktree，默认范围为当前 workspace 下：

```text
features/<feature>/ref/*
```

从各仓库主 clone 执行 `git worktree list --porcelain`，用 Git 实际登记结果解析规范化绝对路径。不要用未解析变量、宽泛 glob 或目录名猜测目标。

明确排除：

- `repos/` 下的仓库主 clone 或任何 primary working tree。
- 其他 Feature 的 worktree。
- 当前 Feature 之外的临时或个人 worktree。
- 本地分支和远端分支；删除 worktree 不等于删分支。

如果项目结构不同，依据 workspace 和 Feature 规则确定等价的 Feature 专属路径。无法证明某个 worktree 属于当前 Feature 时，不删除。

### 2. 执行删除前检查

对每个目标 worktree 记录仓库、绝对路径、branch、HEAD 和状态，并执行：

- 检查 tracked、staged、unstaged 和 untracked 文件。
- 确认没有未提交或未跟踪改动。
- 确认发布未处于失败恢复、回滚或补丁处理中。
- 确认执行命令的当前目录不在待删除 worktree 内。

发现任一 dirty worktree 时立即阻断整个清理：

- 列出精确路径和 dirty 文件摘要。
- 不 stash、不丢弃、不搬运改动。
- 不使用 `git worktree remove --force`、`rm -rf` 或其他绕过保护的命令。
- 等待用户决定如何处理后再重新检查。

### 3. 请求一次精确删除确认

删除前向用户展示：

```markdown
发布验证已完成，等待清理当前 Feature worktree。

- Feature：<feature>
- 待删除数量：<N>
- 路径：
  - <absolute-path> — <repo> / <branch> / <HEAD>
- 保留内容：仓库主 clone、本地分支、远端分支、其他 Feature worktree
- 需要你确认：是否删除以上列出的 clean worktree？
```

该确认只覆盖清单中的精确路径。确认后新增发现的 worktree 不在授权范围内，必须重新展示并确认。

### 4. 安全删除并复核

用户确认后，从对应仓库主 clone 逐个执行：

```text
git worktree remove <absolute-path>
```

不要添加 `--force`。任一删除失败时停止，不改用文件系统强删。

删除后重新执行 `git worktree list --porcelain` 并检查目标路径，确认：

- 已确认的 Feature worktree 均不再登记且目录已移除。
- 主 clone、分支和其他 Feature worktree 仍然存在。
- 没有因清理产生新的异常状态。

最终汇报已删除路径、保留内容和任何未能删除的阻断项。

## 失败与回退

遇到以下情况立即冻结下游：

- 冲突未解决或 target 又发生变化。
- MR source/target 不符合分支治理。
- 前置 migration、配置、部署或验证未完成。
- pipeline/job 失败、取消、卡住或执行环境不确定。
- 实际部署 commit 与预期不一致。
- 健康检查、接口、页面或关键业务链路失败。
- 发现未记录的额外服务、migration 或人工依赖。

先给出根因证据、影响范围和推荐下一步。不要自动重试、回滚、跳过或切换方案。

若需要代码修复，遵循最终 feat 的修复流转，修复进入最终 feat 后再重新生成对应环境节点。不要直接在 Dev/UAT 环境分支修业务问题。

## 完成标准

只有同时满足以下条件才宣告发布完成：

- 依赖图中本次范围的所有节点均为 `verified`。
- 所有 MR、pipeline、job 和实际部署 commit 可追溯。
- 数据库 migration 已确认 applied。
- 目标环境健康检查通过。
- 本次 Feature 的接口、页面和关键业务链路验证通过。
- 没有被忽略的阻断项或尚待用户点击的动作。
- 当前 Feature 的本地 worktree 已按确认清理，且主 clone、分支和其他 Feature worktree 均保留。

最终汇报：

- 实际发布顺序。
- 每个节点的 MR、commit、pipeline/job 和环境结果。
- 完成的数据库、服务、前端与业务验证。
- 未执行或明确排除的范围。
- 回滚锚点及仍需观察的风险。
- 已删除的 Feature worktree 路径，以及明确保留的主 clone 和分支。

不要只用“pipeline 绿色”作为发布完成结论。
