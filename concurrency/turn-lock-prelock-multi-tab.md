***tags: [concurrency, go, mutex, session, multi-tab]
date: 2026-06-12
project: 7verse-agent
***
Turn 锁 + PreLock 钩子解决多 Tab 竞态

现象

用户在多个浏览器 Tab 打开同一个编辑器 Session，同时发送消息。
两个 Turn 并发执行时：
LLM 读到的 AssetPool 状态可能已过时
两个 Turn 同时写入 Transcript 导致消息乱序
资产生成互相覆盖

根因

Session 状态（AssetPool、Memory、Transcript）是共享可变状态。
FC Loop 内部有多次读写（读状态→调LLM→执行Tool→写结果），不是原子操作。
如果锁放在 Cache 层（每次 Get/Set 加锁），粒度太细，无法保证整个 Turn 的一致性。

修复

在 Handler 层（业务入口）用 Turn 级互斥锁，保证同一 Session 同一时间只有一个 Turn 在执行：

type SessionHub struct {
    sessions map[string]*sessionEntry
}

type sessionEntry struct {
    turnMu sync.Mutex  // Turn 级锁
}

type TurnParams struct {
    PreLock func(ctx context.Context) error  // 持锁前的验证钩子
}

func (h *SessionHub) RunTurn(sessionID string, params TurnParams, fn func() error) error {
    entry := h.getOrCreate(sessionID)
    
    // PreLock：在获取锁之前做轻量验证（如 Session 是否仍然有效）
    if params.PreLock != nil {
        if err := params.PreLock(ctx); err != nil {
            return err  // Session 已失效，不用等锁了
        }
    }
    
    entry.turnMu.Lock()
    defer entry.turnMu.Unlock()
    
    return fn()
}

PreLock 的必要性

如果没有 PreLock，流程是：等锁 → 获取锁 → 读状态 → 发现 Session 已过期 → 释放锁。
在高并发下，多个 Turn 排队等锁，前一个 Turn 已经关闭了 Session，后面的 Turn 等到锁后才发现白等了。

PreLock 让排队中的 Turn 在获取锁之前就能快速失败。

模式抽象

共享 Session 的并发控制原则：

锁的粒度 = 业务操作的原子性粒度。不是每个 Get/Set 加锁（太细，无法保证一致性），而是整个 Turn（读-处理-写的完整周期）
锁放在调用链的入口层（Handler），而非底层（Cache），让上层明确掌控生命周期
PreLock 模式：在排队等锁之前做轻量前置检查，避免在锁竞争激烈时白等。适用于"等到锁后可能发现前提已不成立"的场景
多连接同 Session：锁按 SessionID 粒度，不是按连接粒度。多个 Tab 共享 Session 状态时，Turn 必须串行
