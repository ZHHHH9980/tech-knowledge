设计禁令：标识符推断与兜底策略

禁止从标识符推断业务属性

ID、key 名、文件名是身份标识，不是数据源。禁止用正则或字符串匹配从标识符中提取业务含义。

规则

业务属性（product_id、category、is_xxx 等）必须通过显式字段声明
如果需要关联，在数据结构里加字段；如果来源是外部调用，通过参数显式传入
最差的设计也应该是一个 is_product: true 的 flag，而不是靠正则匹配 ID 格式

事故案例（2026-06-15，soulslive-be）

// enqueue_topic.go — 从 beat ID 正则推断 ProductID
var planNodeProductIDPattern = regexp.MustCompile(`(?:^|_)p(\d{3})(?:_|$)`)

func productIDForQueuedTopic(roomID, explicit, planNodeID string) string {
    if explicit != "" { return explicit }
    // BUG: 从 beat ID "b_p001_usage" 推断出 "P001"
    match := planNodeProductIDPattern.FindStringSubmatch(planNodeID)
    if len(match) >= 2 { return "P" + match[1] }
    // ...
}

后果： 峰哥房间没有商品配置，但 beat ID 沿用了旧模板的 b_p001_* 格式，导致不存在的商品卡片出现在直播画面。IVI context 里出现 product_card: P001，主播画面展示了不存在的商品。

根因： EnqueueTopicTool 缺少对 beat 数据的访问能力 → 用命名约定代替显式数据 → 命名约定与实际内容脱节后产生幽灵商品。

本质： 早期 hack（beat 还没有 product_id 字段时的快速上线方案）→ 后来加了正式字段但旧路径没拆干净。

兜底策略必须安全侧

当缺少必要输入时，默认行为是「不执行 / 不展示」，不能是「推断一个可能错的值继续执行」。

规则

会产生用户可见副作用的操作（挂卡、发消息、扣费、变更状态）— 缺少显式输入就不执行
只读或内部状态操作 — 可以用合理默认值兜底
如果确实需要推断，推断结果必须经过存在性校验才能产生副作用

判断标准

误执行的后果 vs 漏执行的后果：
商品卡挂错（不存在的商品出现在画面）>> 漏挂（少一次曝光）
发了错误消息 >> 没发消息
扣错费 >> 没扣费

如果误执行更严重，兜底就该是不执行。

反模式

// 错：缺少输入时猜一个继续执行
if productID == "" {
    productID = guessFromSomething()  // 可能猜错
}
mountProductCard(productID)  // 用户看到错误商品

// 对：缺少输入就不执行
if productID == "" {
    return  // 不挂卡，安全
}
mountProductCard(productID)

Code Review 检查点

看到正则匹配 ID/key 名来决定业务行为 → CRITICAL
看到缺少输入时用推断值执行有副作用的操作 → HIGH
看到推断值直接产生副作用而无存在性校验 → HIGH
