# Skills 导航

按任务选择入口。FE、BE 的实现评审与技术方案评审分开；以下仅整理已有能力，不表示覆盖完整功能、安全、性能或可访问性审查。

| 分类 | Skill | 现有范围 |
|---|---|---|
| FE 实现 | [frontend-review](frontend-review/SKILL.md) | 组件与 hook 归属、JSX/Tailwind、文件边界与抽象；明确要求修改时沿用实现清单 |
| BE 实现 | [backend-review](backend-review/SKILL.md) | 结构与发布依赖、Go 可读性、共享依赖消费点、ID 精度；按需读取参考材料 |
| 方案 | [tech-design-data-review](tech-design-data-review/SKILL.md) | 交互、接口、请求预算、分页、SQL/索引、容量、推送隔离与频控 |
| 方案编写 | [architecture-decision-rfc](architecture-decision-rfc/SKILL.md) | 方案比较、架构决策与迁移计划 |
| 工程计划 | [plan-eng-review](plan-eng-review/SKILL.md) | 已有 gstack 工程评审，依赖相应 gstack 环境 |
| 发布 | [release-orchestrator](release-orchestrator/SKILL.md) | 发布依赖顺序、环境状态、验证与清理 |
| 网页写入 | [github-web-publish](github-web-publish/SKILL.md) | GitHub 网页编辑、创建、上传及提交核验 |
| 行为优化 | [improving-agent-behavior](improving-agent-behavior/SKILL.md) | Agent 样本评估、获批优化与复测 |

## 原入口去向

| 原入口 | 当前归属 |
|---|---|
| frontend-cr | frontend-review，保留原前端结构与实现约定 |
| code-structure-review（两处） | backend-review 的结构参考；适用的通用原则同时归入 FE |
| review/code-structure-review/go/go-code-readability-review | backend-review/references/go-readability.md |
| general-code-review、generate-code-review | backend-review/references/dependency-and-identifiers.md |
| tech-design-review、review/tech-design-data-review | tech-design-data-review，合并各自独有检查 |
| github-browser-create-files | github-web-publish 的“明确禁止上传”条件流程 |
| learn-session-knowledge | 撤掉独立技能；基础沉淀要求见根目录 README |

旧入口不保留可被发现的 SKILL.md 副本。独立安装时复制整个技能目录，包含其 references 与 agents；FE 的共享依赖、ID 与配置专项复用 BE 参考材料，使用这些维度时须同时安装 frontend-review 与 backend-review；已有安装需按上表更新，仓库整理不会自动修改本机安装。
