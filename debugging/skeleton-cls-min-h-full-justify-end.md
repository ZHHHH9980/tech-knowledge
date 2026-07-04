# 骨架屏 CLS：`min-h-full` + `justify-end` 在动态高度容器中引发布局抖动

## 现象

聊天页面骨架屏使用 `min-h-full flex-col justify-end` 让占位气泡贴底显示。页面加载时骨架屏出现后往上跳 8-12px。

## 根因

骨架屏所在的滚动容器（`overflow-y-auto flex-1`）高度由外层 flex 布局动态分配。当组件树中任何兄弟/祖先元素触发 cascading setState（比如初始化 effect 重置一批状态），会导致容器 `offsetHeight` 微变。

`min-h-full` 使骨架屏高度 = 容器高度。`justify-end` 使内容贴底。容器高度微变 → 骨架屏高度跟着变 → 贴底位置跳动。

关键链路：
1. 组件 mount → 初始化 effect 触发多个 `setState()`
2. React 批量重渲染 → 某些 UI 元素微调（哪怕是 0→0 的"脏"引用更新）
3. 外层 flex/grid 重新分配高度 → 滚动容器 `offsetHeight` 变化几 px
4. `min-h-full` 骨架屏跟着变高/变矮 → `justify-end` 底部位置偏移 → 视觉抖动

## 修复

去掉骨架屏的 `min-h-full`。骨架屏不再强制填满容器，不再对容器高度微变敏感。

```diff
- <div className="flex min-h-full flex-col justify-end gap-4 animate-pulse">
+ <div className="flex flex-col justify-end gap-4 animate-pulse">
```

如果需要贴底效果，改用容器侧的 `flex-col justify-end`（让容器控制对齐，而非子元素自己撑满）。

## 排查方法

1. Performance 面板录制，找到 Layout Shift 时间点
2. 对应时间点找到 React 的 cascading update / setState 调用栈
3. 定位触发重渲染的 effect
4. 在该 effect 中逐步排除，或直接验证怀疑的 CSS 属性

## 通用教训

- **骨架屏/占位组件不要用 `min-h-full`**：容器高度在初始化阶段不稳定，任何 setState 都可能触发微小的高度重算
- **`justify-end` + 动态高度 = CLS 放大器**：底部对齐时，容器高度变 1px，内容就移 1px；而顶部对齐时，容器变高不影响已有内容位置
- **排查 CLS 优先看 Performance 面板的 cascading update**：不是所有 useLayoutEffect 都能修的，有时根因在 CSS 布局策略本身
