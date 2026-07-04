---
name: learn-session-knowledge
description: Use when a user asks to learn, remember, capture lessons, record reusable workflow knowledge, or make future agents able to reuse a discovery from the current session.
---

# Learn Session Knowledge

## Core Rule

Use the project's learning protocol first. If none exists, record only knowledge that another agent would need and cannot trivially recover from code or git history.

## Workflow

1. Check for `docs/rules/learning-protocol.md`.
2. If absent, scan project `AGENTS.md`, `CLAUDE.md`, and workspace docs for learning rules.
3. Decide whether the session produced reusable knowledge:
   - root cause of a non-obvious failure
   - external-system failure mode
   - workflow or environment trap likely to recur
   - reusable process that future agents should follow
4. Pick the right home:
   - project-specific knowledge: write near the related code or docs
   - cross-project process: write to a shared knowledge repo or skill folder
   - user preference only: summarize for memory, not project docs
5. Avoid `AGENTS.md` / `CLAUDE.md` unless the user explicitly asks to maintain stable rules there.
6. Keep the entry short, factual, and verified. Do not record guesses or temporary session IDs.

## Entry Shape

For knowledge-base Markdown, use:

```markdown
---
tags: [skill, workflow]
date: YYYY-MM-DD
project: optional-project
---

# Title

## Context
## Workflow
## Failure Modes
## Verification
```

For reusable agent skills, create `skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter plus concise operational instructions.

## Common Mistakes

- Writing a full session narrative instead of a reusable rule.
- Duplicating content already present in project rules.
- Recording unverified assumptions.
- Forgetting to check whether the target repo is dirty before adding local files.
- Putting cross-project workflow knowledge inside a single product repo where future agents will not find it.
