# 下游 API 调用的 Contract Test

## 问题

重构、清理代码时，容易无意中删除或遗漏传给下游服务的关键参数。普通单元测试只验证"我的逻辑对不对"，不验证"我发出去的 request 长什么样"。

## 案例

2026-06 soulslive-be：重构 host config 时清理了一段"看起来多余"的 cvi_config 默认注入代码，导致 CreateIVISession gRPC 请求丢失 `max_duration_seconds=0`。IVI 平台收到请求后使用默认值 300s，所有直播间 5 分钟后自动断流。

- 断流持续约 5 分钟（发现并回滚）
- 根因：没有测试验证出站 request 的参数完整性
- 修复后补了 contract test：`live_room_create_session_contract_test.go`

## 原则

### 单元测试 vs 契约测试

| 维度 | 单元测试 | 契约测试 |
|------|---------|---------|
| 视角 | 我的逻辑对不对 | 我给下游发的东西对不对 |
| 关注点 | 内部状态、分支覆盖 | 出站 request 的字段存在性、值约束 |
| 失败含义 | 业务逻辑回归 | 下游集成契约被破坏 |

### 写 Contract Test 的时机

- 每个下游调用点（gRPC、REST、第三方 SDK）至少一个
- 新增调用时立即写，不要等出事
- 重构涉及下游调用链时，先确认 contract test 存在再动手

### Contract Test 应该断言什么

优先级从高到低：

1. **字段存在** — 关键参数不为零值/nil/空字符串
2. **类型正确** — 数字不是字符串，嵌套结构存在
3. **值在合法范围** — 0 表示无限制（而非"未设置"），枚举值在白名单内
4. **不含废弃字段** — 确保迁移后旧字段不再发送

### 用注释替代独立文档

```go
// Contract: CreateIVISession request 不变量
//
// - cvi_config.max_duration_seconds = 0（无时长限制，0 != 未设置）
// - session_parameters.sync_agent_config 存在（控制 agent 行为）
// - session_parameters.shape_config 存在（控制画面比例）
// - max_lifetime_seconds = 0（session 不自动过期）
// - enable_live = true（推流开关）
// - 不含 legacy key: realtime_cvi_config, asr_config（已迁移）
//
// 这些参数的缺失不会报错，下游会静默使用默认值，导致难以察觉的行为变化。
func TestCreateIVISessionRequestContract(t *testing.T) {
    // ...
}
```

注释说明**为什么**这个参数必须是这个值，测试断言**它确实是**。二者缺一不可。

## 反模式

- 只测 happy path 的返回值，不看发出去的 request
- 认为"这个参数一直在，不会丢"——重构就是会丢
- 把契约写在独立 markdown 里——和代码分离，必然腐烂
- 下游调用封装太深，test 里 mock 掉了真实的 request 构建过程
