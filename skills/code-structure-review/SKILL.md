---
name: code-structure-review
description: Review code changes for structural maintainability, focusing on file size, single-responsibility functions, concise orchestration flows, extracted boundary handling, and step-level intent comments. Use when reviewing a PR, MR, commit, or diff for code readability, function boundaries, oversized files, complex control flow, or maintainability. Trigger on requests such as code review, CR, review this diff, 代码审查, 文件太大, 单一职责, 主流程精简, 边界处理, or 编排函数.
---

# Code Structure Review

Perform a read-only structural review. Do not modify code unless the user explicitly requests implementation.

## Review Scope

Review changed lines together with enough surrounding context to understand their responsibilities.

Distinguish between:

- Problems introduced by the change
- Existing problems made worse by the change
- Unrelated pre-existing debt

Report the first two categories. Avoid expanding the review into unrelated legacy cleanup.

## Review Criteria

### 1. Keep files within 400 lines

Prefer each hand-written source file to remain within 400 lines.

When a changed file exceeds or approaches 400 lines:

1. Identify the independent responsibilities contained in the file.
2. Recommend concrete domain or responsibility-based split points.
3. Explain why the current change makes the file harder to maintain.

Do not mechanically flag:

- Generated code
- Lock files
- Vendored dependencies
- Machine-generated protocol bindings
- Data fixtures whose structure requires a single file

Large hand-written API schemas, protocol definitions, configuration files, and test files still require review. Recommend splitting them when clear domain boundaries exist.

### 2. Enforce single-responsibility functions

A function should have one primary reason to change.

Flag functions that combine multiple independent concerns, such as:

- Validation and persistence
- State transitions and notification delivery
- Data querying and hidden writes
- Business decisions and infrastructure initialization
- Main-flow orchestration and detailed boundary recovery
- Synchronous state changes and unrelated asynchronous side effects

Function length is a signal, not an automatic violation. Inspect functions longer than roughly 50 lines closely, but base findings on mixed responsibilities rather than line count alone.

Recommend named helper functions that reflect the responsibilities being separated.

### 3. Keep core flows as orchestration outlines

Core entry points and business flows should expose the execution outline without embedding detailed implementations.

Prefer a structure similar to:

```go
func HandleRequest(ctx context.Context, req *Request) error {
    // Validate whether the request can enter the business flow.
    input, err := validateRequest(ctx, req)
    if err != nil {
        return err
    }

    // Apply the core state transition.
    result, err := executeTransition(ctx, input)
    if err != nil {
        return err
    }

    // Publish the side effects produced by the transition.
    return publishResult(ctx, result)
}
```

Flag core functions when readers must navigate detailed conditions, persistence operations, retry handling, cleanup, formatting, or fallback logic to understand the main business sequence.

Extract complex boundary handling into focused helpers, including:

- Input normalization
- Empty or missing-state handling
- Compatibility branches
- Retry and fallback behavior
- Partial-failure recovery
- Idempotency and duplicate handling
- Cleanup and resource release
- External dependency error translation

### 4. Comment every orchestration step

In a core orchestration function, add a concise comment before every major business step.

Comments must explain the intent, business phase, invariant, or reason for the step. Do not merely translate the following function call into natural language.

Good:

```go
// Persist the terminal state before publishing events to keep retries idempotent.
if err := finalizeSession(ctx, session); err != nil {
    return err
}
```

Weak:

```go
// Finalize session.
if err := finalizeSession(ctx, session); err != nil {
    return err
}
```

Treat missing comments as a review issue when:

- The function coordinates several business phases.
- Execution order affects correctness.
- A step handles a non-obvious boundary or fallback.
- Side effects must occur before or after persistence.
- Readers cannot understand why a step exists from its name alone.

Do not require comments for trivial getters, simple adapters, or self-evident one-step functions.

For complex boundary helpers, require a comment describing the boundary, invariant, or recovery policy when the implementation alone does not make it obvious.

### 5. Avoid excessive positional dependencies

When a constructor or orchestration helper accepts many dependencies, recommend a named parameter structure.

Treat three or more same-category dependencies, or six or more total positional parameters, as a review signal. Focus on readability, dependency grouping, and resistance to argument-order mistakes.

## Review Procedure

1. Resolve the exact review target: PR, MR, commit, or diff.
2. List changed files and measure line counts at the reviewed revision.
3. Exclude generated and vendored files from manual size enforcement.
4. Inspect changed functions and their surrounding callers.
5. Identify mixed responsibilities and hidden side effects.
6. Inspect core flows for embedded boundary handling.
7. Check whether every major orchestration step has an intent comment.
8. Produce only actionable findings supported by concrete code evidence.

## Finding Requirements

Each finding must include:

- Priority: `P1` for merge-blocking structural problems, `P2` for important maintainability issues
- Confidence from 1 to 10
- Exact file and line
- Concrete evidence from the code
- Why the structure is problematic
- A specific extraction or split recommendation

Use this format:

```markdown
1. `[P1][10/10]` Concise finding title
   `path/to/file.go:123`

   Evidence and impact.

   Recommendation with concrete helper, component, or file boundaries.
```

Group closely related symptoms into one finding instead of repeating the same root cause.

## Output Rules

Lead with an overall conclusion.

Explicitly state:

- Whether the change meets the structural criteria
- Which files exceed 400 lines
- Which core functions contain detailed boundary logic
- Which orchestration functions lack step-level intent comments
- Whether generated files were excluded
- Whether any code was modified

Do not report stylistic preferences without a maintainability impact. Do not suggest broad rewrites when a focused extraction would solve the problem.
