---
name: learn-session-knowledge
description: Use when the user asks to learn, remember, capture lessons, record reusable workflow knowledge, preserve session discoveries, update a knowledge base, or make future agents reuse current work.
---

# Learn Session Knowledge

## Job

Turn a finished or interrupted session into reusable knowledge. Do not write a diary. Produce an artifact that another agent can use without seeing the original chat.

## First 3 Minutes

If this skill includes `scripts/inspect-learning-context.sh`, run it from the target project root:

```bash
bash skills/learn-session-knowledge/scripts/inspect-learning-context.sh .
```

If the script is not available, run these checks manually:

```bash
pwd
git status --short --branch 2>/dev/null || true
if [ -f docs/rules/learning-protocol.md ]; then
  sed -n '1,260p' docs/rules/learning-protocol.md
else
  echo "missing docs/rules/learning-protocol.md; inspect entrypoint files next"
fi
for f in AGENTS.md CLAUDE.md WORKSPACE.md WORKSPACE.markdown workspace.yaml workspace.yml; do test -f "$f" && grep -nEi 'learn|learning|memory|沉淀|记忆|knowledge' "$f"; done
find . -maxdepth 3 \( -name 'README*' -o -name 'INDEX.md' \) 2>/dev/null | sort | head -80
```

Then state which protocol is active:

- **Explicit project protocol found**: follow it as the only source of truth.
- **Only entrypoint hints found**: use them for repository structure and ownership; use the default protocol for learning decisions.
- **No project protocol or hints found**: use the default protocol below.

## Default Learning Protocol

Use only when the project has no own learning protocol.

1. **Worth recording?** Record only verified, reusable knowledge that future agents are likely to need.
2. **Where does it belong?** Choose the narrowest durable home:
   - project behavior -> relevant project README near the code
   - cross-project workflow -> shared knowledge repo or `skills/<name>/SKILL.md`
   - user preference / agent correction -> memory tool or final-answer summary
3. **Avoid duplication.** Search nearby README, index files, and existing rules before writing.
4. **Write operationally.** Include trigger, decision points, exact steps, failure modes, and verification.
5. **Protect rule files.** Do not edit `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or similar rule files unless the user explicitly asks to maintain stable rules.
6. **Verify.** Check file content, formatting, absence of unfinished markers, and explain why this qualified for learning.

## Read Project Entrypoints

If no project learning protocol exists, use entrypoint files to understand the repository shape. Do not copy their examples blindly; translate their ownership model into the note location.

Read in this order when present:

1. `docs/rules/learning-protocol.md`: if present, stop here and follow it as the only rule source. Do not assume this file exists.
2. `AGENTS.md`, `CLAUDE.md`, `WORKSPACE.md`, `WORKSPACE.markdown`, `workspace.yaml`, `workspace.yml`: scan for repository layout, ownership, docs locations, memory rules, and forbidden edits.
3. Root `README.md` and nearby `README*`: use them to learn category names and index/update commands.

Example `workspace.yaml`:

```yaml
projects:
  - name: api
    path: services/api
  - name: web
    path: apps/web
  - name: shared-auth
    path: packages/auth
docs:
  runbooks: docs/runbooks
  decisions: docs/adr
```

Interpretation:

- API-only discovery -> `services/api/README_<topic>.md` or an existing docs file under that service.
- Web route/component discovery -> `apps/web/.../README_<topic>.md` near the owning feature.
- Shared auth behavior -> `packages/auth/README_<topic>.md`.
- Cross-service incident/debug process -> `docs/runbooks/<topic>.md`.
- Architecture decision -> `docs/adr/<decision-name>.md`.

Example `WORKSPACE.md`:

```markdown
# Workspace

- Apps live in `apps/*`.
- Shared packages live in `packages/*`.
- Environment and deployment runbooks live in `deploy/` and `docs/runbooks/`.
- Prefer local README files for module behavior; use root docs only for cross-cutting rules.
```

Interpretation:

- Put module behavior beside the app/package that owns it.
- Put deploy failure modes under `deploy/` or `docs/runbooks/`.
- Do not create a broad root note when the entrypoint says local README files are preferred.

## Trigger Test

Create a learning artifact if at least one is true:

| Trigger | Example |
| --- | --- |
| Read 3+ files to understand a workflow | Traced service state across gateway, worker, and database docs |
| Found root cause of a non-obvious bug | Browser automation failed because CodeMirror state was not updated |
| Found external failure mode | GitHub UI changed selectors; SSL navigation needs retry |
| Clarified durable boundary/contract | Which status field owns manual review state |
| Did substantial research | Compared multiple docs or source files to decide behavior |
| User corrected agent behavior | "Do not use Upload files; use Create new file" |
| Built reusable automation | Browser-only GitHub write script future agents can reuse |

If none apply, reply exactly: `本次无需沉淀`.

## Destination Decision

Use this table before writing:

| Knowledge | Destination | Do not put it in |
| --- | --- | --- |
| Code path, API contract, data flow | README near code or project docs | shared skill |
| Debugging playbook for one system | project docs near system | global rule file |
| Cross-project agent workflow | `skills/<skill-name>/SKILL.md` in shared knowledge repo | product repo README |
| Personal preference or account habit | memory/final summary | project docs |
| Temporary session facts | nowhere | any persistent file |

When both project and cross-project value exist, split them. Project file gets project facts; skill gets reusable process.

## Fit The Project Structure

Do not copy another project's paths. First classify the repository shape, then choose a location that future maintainers will naturally inspect.

Use this placement algorithm for project-level notes:

1. Name the thing that owns the knowledge: route, component, package, service, database migration, queue, deployment workflow, or external integration.
2. Find the nearest durable directory for that owner. Prefer an existing README in that directory; otherwise create `README_<topic>.md` there.
3. If the knowledge spans multiple owners, use the repo's documented runbook/ADR/docs area rather than picking one owner arbitrarily.
4. If the knowledge is not tied to this repo, do not force it into project docs; write a shared skill or knowledge-base article.
5. Replace all example nouns with current repo nouns. A copied path from another project is a bug.

| Repository shape | How to place project knowledge |
| --- | --- |
| Single service/library | Put a focused `README_<topic>.md` beside the package/module that owns the behavior, or update an existing local README. |
| Monorepo with `apps/`, `packages/`, `services/` | Put the note inside the owning app/package/service, not at monorepo root. |
| Backend with domain modules | Put the note beside the handler/service/repository/migration area that owns the flow. |
| Frontend app | Put the note beside the route/page/component state area, or in that app's docs folder. |
| Infrastructure/deploy repo | Put the note beside the environment, chart, workflow, or runbook it affects. |
| Shared knowledge repo | Use top-level categories such as `debugging/`, `architecture/`, `frontend/`, `llm-ops/`, or `skills/`. |

Generic examples:

```text
services/payments/README_idempotency.md
apps/admin/src/features/users/README_status-flow.md
packages/auth/README_token-refresh.md
deploy/k8s/README_rollout-debugging.md
docs/runbooks/README_incident-triage.md
skills/github-browser-create-files/SKILL.md
```

Bad generic examples:

```text
README.md                  # too broad unless it is a repository-wide rule
docs/notes.md              # dumping ground
src/README.md              # not close enough to ownership
<old-project-path>/...     # copied from another project without matching current repo
```

Project-level note filenames should describe the durable topic, not the session:

```text
README_idempotency.md
README_reconnect-flow.md
README_status-lifecycle.md
README_rollout-debugging.md
```

Avoid:

```text
README_notes.md
README_today.md
README_bugfix.md
README_session-summary.md
```

## Worked Examples

### Example A: Shared Knowledge Repo With Skills

Situation: the target repo is a shared knowledge base with categories and an index.

Do:

1. Read root `README.md` to learn categories.
2. If adding a new category such as `skills/`, update root `README.md`.
3. Put the reusable workflow in `skills/<workflow-name>/SKILL.md`.
4. If the repo has `build_index.py` or `INDEX.md`, rebuild/update the index.
5. Verify the new skill appears in the index.

Do not leave only the new skill file while README/INDEX still hide it.

### Example B: Cross-Project Workflow

Situation: the session produced a workflow that can apply to any project, such as browser-only GitHub file creation.

Destination:

```text
skills/github-browser-create-files/SKILL.md
```

Minimum contents:

- hard constraints: forbidden paths and required path
- exact browser/UI sequence
- selectors or scripts only if they are part of the reusable method
- known failure modes
- final verification checklist

### Example C: Session Memory / User Correction

Situation: user corrected agent behavior: "Do not use GitHub Upload files; use Add file -> Create new file."

Decision:

- If it affects only this user or machine, record as memory/final-summary.
- If it protects future agents across projects, write a shared skill.
- If it also changes a project-specific tool script, update that script's README or local docs.

Do not bury this correction inside a long narrative. Put it in a hard-constraints section.

### Example D: Project Entrypoint Controls Placement

Situation: `workspace.yaml` says `apps/web`, `services/api`, and `packages/auth` are separate projects.

Session discovery: a token refresh failure was traced through the web client and the shared auth package.

Decision:

- If the reusable fact is "auth package refresh tokens must be rotated before cache write", write under `packages/auth/README_token-refresh.md`.
- If the reusable fact is "web app should redirect after auth package returns a refresh error", write under the owning web feature directory.
- If the reusable fact is "the incident crosses web, API, and auth package", write a runbook under the repo's documented runbook path.

Do not create `docs/notes.md` or copy a path from another repository just because it looked plausible.

### Example E: Project-Specific Debugging Playbook

Situation: a bug was root-caused in one service's status flow.

Destination should match ownership:

```text
services/<service-name>/<domain>/README_<topic>.md
apps/<app-name>/src/features/<feature>/README_<topic>.md
docs/runbooks/<system>-<failure-mode>.md
```

Include the exact fields, logs, commands, and verification for that project. Do not put service-specific field names in a global skill unless they illustrate a general pattern.

## Artifact Templates

### Project README Note

```markdown
# <Topic>

## When It Matters
<Concrete trigger.>

## What To Check
- <file/command/field>

## Known Failure Mode
<Symptom -> root cause -> fix.>

## Verification
<Command or observable result.>
```

### Knowledge Base Article

```markdown
---
tags: [workflow, debugging]
date: YYYY-MM-DD
project: optional
---

# <Title>

## Context
## Root Cause / Decision
## Reusable Workflow
## Failure Modes
## Verification
```

### Reusable Skill

```markdown
---
name: lowercase-hyphen-name
description: Use when <trigger conditions only; no workflow summary>.
---

# <Skill Name>

## Job
## First 3 Minutes
## Workflow
## Failure Modes
## Verification
```

If the workflow repeatedly needs exact code, add a small script under the skill folder and test it. If it is only judgment/process, keep it in `SKILL.md`.

## Quality Bar

Before publishing, run this self-review:

```bash
grep -RInE 'TODO|TBD|FIXME|�' <changed-files>
wc -w <skill-or-doc>
```

The artifact must answer:

- What should trigger this knowledge?
- What exact first checks should the next agent run?
- What decision should the next agent make?
- What should the next agent avoid?
- How does the next agent verify success?

If it does not answer those five questions, rewrite it.

## Common Mistakes

- Assuming `docs/rules/learning-protocol.md` exists; if it is missing, failing to inspect entrypoint files and then use the fallback protocol.
- Writing a session story instead of an executable workflow.
- Hiding the most important user correction in prose.
- Creating a skill with no trigger, no first checks, and no verification.
- Updating a shared knowledge repo but not its `README` or `INDEX`.
- Publishing browser/GitHub automation notes without warning about forbidden paths such as `git push`, API writes, or `Upload files`.
