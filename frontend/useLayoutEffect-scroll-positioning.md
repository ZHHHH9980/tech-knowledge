# useLayoutEffect 用于 DOM 位置操作

## 问题

React 中渲染列表后需要滚动到底部（聊天、日志、feed），用 `useEffect` 执行 `el.scrollTop = el.scrollHeight` 会导致一帧闪烁：用户先看到列表顶部，再跳到底部。

## 根因

React 渲染周期：

```
setState → reconcile → commit DOM → useLayoutEffect → browser paint → useEffect
                                     ^^^^^^^^^^^^^^                     ^^^^^^^^^^
                                     paint 前同步执行                    paint 后异步执行
```

`useEffect` 在 paint 之后执行。如果列表很长（50+ 条消息，渲染 > 100ms），中间那帧用户看到的是 scrollTop=0（顶部），造成"消息闪一下才到底部"。

## 规则

**任何依赖 DOM 几何属性（scrollTop、offsetHeight、getBoundingClientRect）的定位操作，必须用 `useLayoutEffect`，不用 `useEffect`。**

典型场景：
- 聊天列表滚动到底部
- 虚拟列表跳转到指定 item
- Tooltip / Popover 根据锚点元素计算位置
- 输入框自动聚焦后滚动到可视区域
- 拖拽排序后修正元素位置

## 代价

`useLayoutEffect` 是同步的，会阻塞 paint。如果回调本身很重（> 16ms），会造成帧延迟。但对于单次 scrollTop 赋值这种 O(1) 操作，开销可忽略。

## 反模式

```tsx
// 错误：paint 后才滚动，用户看到一帧旧位置
useEffect(() => {
  containerRef.current.scrollTop = containerRef.current.scrollHeight;
}, [messages]);

// 正确：paint 前滚动，用户直接看到正确位置
useLayoutEffect(() => {
  containerRef.current.scrollTop = containerRef.current.scrollHeight;
}, [messages]);
```

## 排查信号

当用户描述"加载后闪一下"、"跳了一下"、"先看到 X 再变成 Y"，且涉及滚动/位置，优先检查是否用了 `useEffect` 做 DOM 定位。

## 来源

swaydream/ug-fe 聊天页排查。消息渲染 50 条（~160ms），useEffect 中 scrollToBottom 导致一帧闪烁。改 useLayoutEffect 后修复。
