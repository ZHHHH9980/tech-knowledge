# LinkedIn Code Review 最佳实践

## 来源

- URL: https://thenewstack.io/linkedin-code-review/
- 作者: Szczepan Faber (LinkedIn Development Tools Tech Lead)
- 时间: 2017-09
- 背景: LinkedIn 完成 100 万次 code review 后的经验总结；2011 年起强制全员 CR

## 核心观点

### 组织层面收益

1. **标准化** — 全公司统一工具和流程，任何人能给任何团队 review/贡献代码
2. **反馈文化** — CR 成为日常后，工程师对所有工作领域的反馈都更开放
3. **晋升依据** — 高质量 CR 提供工程能力的客观证据

### 7 条 Reviewer 行为准则

| # | 原则 | 关键点 |
|---|------|--------|
| 1 | 先理解"为什么" | 每个提交必须有设计概述说明动机；无法从代码推断意图时要求补充 |
| 2 | 给正面反馈 | 好代码要说出来，不只挑问题；正面反馈会传染 |
| 3 | 评论自解释 | 宁可过度解释；"reduces duplication" 优于 "fix this" |
| 4 | 尊重付出 | 即使代码需要返工，也要认可努力；最好的尊重是高质量的反馈 |
| 5 | 对自己有用才留 | 格式问题交给自动化工具，无用评论直接删 |
| 6 | 验证 testing done | 深度与变更影响成正比；新条件分支需单测覆盖 |
| 7 | 不要吹毛求疵 | 重要问题不能被琐碎建议淹没；过多评论拖慢节奏 |

### 核心结论

> 当每个工程师意识到"别人会读我的代码"和"我得处理 review 意见"时，代码质量自然上升。高质量 review 会传染。

## 适用场景

- 制定团队 CR 规范时作为参考框架
- AI agent 执行 code review 时的行为指导
- 新人 onboarding CR 文化培训

## 已落地

- `~/.claude/rules/common/code-review.md` → Reviewer Conduct section
- `~/.claude/rules/zh/code-review.md` → 审查者行为准则 section
