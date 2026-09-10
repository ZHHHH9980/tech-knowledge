---
name: frontend-cr
description: Use when reviewing or implementing frontend UI changes, especially React, Tailwind-heavy components, page-level features, large files, or comments about readability, file size, component boundaries, folder structure, CR, or code review.
---

# Frontend CR

Use this skill to keep frontend changes readable, reviewable, and split by responsibility. Prefer clear domain names and small files over large inline component piles.

## Review First

Before commenting or editing, identify:

- Framework and local conventions.
- Files touched and line counts.
- Whether the change is a page-level feature, reusable UI, data transformation, styling-only tweak, or stateful behavior.
- 检查实际调用关系，确定新增或抽取的组件、hook 所属的最小范围，并统计该范围内已有的同类实现。
- Existing repo rules for tests. Do not add tests when the repo explicitly forbids them.

## Hard Biases

- Keep frontend files under 400 lines. If a touched file is already over 400 lines, do not make it worse; extract the part you changed when practical.
- Split by responsibility before a component becomes hard to scan.
- Avoid thousand-line page files and mixed concerns such as fetching, formatting, constants, event logic, and dense JSX in one file.
- Treat dense Tailwind class strings as a readability smell when they hide intent.
- Name extracted pieces by domain behavior, not presentation trivia.
- Prefer small, obvious modules over clever generic abstractions.

## 目录归属与渐进归组

先判断归属，再按数量归组。目录表达代码所有权，不机械复制 JSX 的嵌套层级。

- **私有实现就近放置**：组件拥有独立拆出的私有实现时，使用同名目录，`index.tsx` 作为入口。私有子组件、hooks 和样式放在该目录内，不与所属组件平铺；纯展示组件也遵循归属关系。
- **超过 3 个主动归组**：同一归属范围内，自定义 hook 或子组件超过 3 个（第 4 个起），分别收敛到该范围的 `hooks/`、`components/`。统计自有实现，不计 React 内置 hooks、外部导入组件或 JSX 使用次数。数量较少时允许在所属目录内平铺；已有分类目录则继续复用，不要求凑够 4 个。
- **真实复用再上提**：多个独立调用方确实需要、且职责与语义一致时，才移到最近的共同所属范围。不要因“以后可能复用”提前上提，也不要因为有两个调用方就直接移到全局共享目录。
- **随改动维护**：新增第 4 个同类实现时，在本次涉及范围内主动完成归组并更新引用，不等待用户 review 时提醒，不顺带重排无关目录。
- **保持边界**：外部调用方使用所属组件的公开入口，不跨目录引用其私有实现；出现真实共享需求时按上述规则上提。

例如，一个功能既有共享 hooks，也有包含私有子组件的视图，可以逐步形成：

```text
feature-name/
  index.tsx
  hooks/
    use-feature-state.ts
    ...
  detail-view/
    index.tsx
    components/
      detail-item.tsx
      ...
  const.ts
  utils.ts
  types.ts
```

只创建确有职责的文件或目录；仅服务 `detail-view` 的 hooks 放在该视图内部，不放到功能共享层。

- `index.tsx`：组合、数据连接与主组件导出，不为所有分类目录机械新增 barrel 文件。
- `ui.tsx`：少量且内聚的展示子结构；子组件超过阈值时拆到 `components/`，不靠堆进一个文件规避归组。
- `const.ts`：静态选项、超时、映射、标签、路由。
- `utils.ts`：内聚的纯计算、解析、格式化与选择逻辑。
- `types.ts`：会使其他文件臃肿的局部共享类型。
- 测试文件：仅在仓库规则允许时添加。

不要为了符合示例而创建空目录或无职责文件。

## Tailwind Readability

Inline Tailwind is fine for simple elements. Extract when:

- A JSX node has a long class list and no semantic name.
- The class list repeats across sibling elements.
- Styling choices encode state, layout, or product meaning.
- The surrounding JSX needs comments to explain what the element does.

Prefer readable structures like:

```tsx
export function LiveRoomBackgroundCarousel() {
  const currentScene = useCurrentBackgroundScene();

  return (
    <img
      src={currentScene.src}
      alt=""
      className="absolute inset-0 h-full w-full object-cover opacity-95"
      draggable={false}
    />
  );
}
```

Over leaving a visually important behavior as an anonymous inline element inside a larger component.

## Extraction Rules

Extract when the name teaches the reader something:

- `sceneIndexForHour` is better than burying time-window logic in JSX.
- `LiveRoomBackgroundCarousel` is better than a bare `<img>` when rotation, selection, or business meaning exists.
- `BACKGROUND_GROUP_ROTATE_MS` is better than an unexplained timer literal.

Do not extract when the result is less clear:

- Avoid one-use wrappers named after raw HTML, such as `ImageBox`, unless they own real behavior.
- Avoid generic `helpers.ts` dumping grounds. Use `utils.ts` only for cohesive local pure helpers.
- Avoid pushing every Tailwind class into constants. Extract semantic pieces, not style trivia.

## CR Checklist

When reviewing frontend changes, check in this order:

1. 归属与目录：是否有私有实现与所属组件平铺、超过 3 个仍未归组、跨目录引用私有实现，或尚无真实复用就提前上提？按“目录归属与渐进归组”检查。
2. 文件体量：本次涉及的文件是否超过或接近 400 行？
3. 职责拆分：常量、纯逻辑、UI、数据连接和类型是否混杂？
4. JSX 可读性：主组件能否在一屏内理解？
5. Tailwind 密度：类名是否遮蔽重要 UI 的意图？
6. 命名：抽取的组件和辅助函数是否描述业务行为？
7. 验证：是否遵循仓库规则完成适当的类型、lint、构建或浏览器检查？

Give comments as concrete refactors, for example:

```text
This logic should move to utils.ts as sceneIndexForHour(). The component then reads as selection plus render instead of time-window math inside JSX.
```

## Implementation Checklist

When implementing a frontend change:

1. 先检查实际调用关系与本地约定，确定组件、hook 的归属和共享范围。
2. 按“目录归属与渐进归组”放置私有实现；达到阈值时主动整理目录并更新引用。
3. 保持 `index.tsx` 为组合入口。
4. JSX 变得密集之前，先分离纯逻辑和常量。
5. 本次涉及的文件超过 400 行之前主动拆分。
6. 交付前复查目录归属、数量阈值和引用边界，并执行仓库要求的验证。
