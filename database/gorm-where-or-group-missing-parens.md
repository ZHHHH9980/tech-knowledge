# GORM 链式 Where 里的 OR 组缺外层括号：一条 UPDATE 污染全表

## 症状

- 一条本应只更新 1 行的 UPDATE，实际更新了几百行（本例 318 行）。
- 受影响的行有共同特征：**它们都满足 OR 分支的条件**，而与目标主键无关。
- 上游看起来"没成功"：调用方按 `RowsAffected != 1` 判定失败并走了回滚/重排分支，但脏数据**已经写进事务并提交**。故障表现成"任务未完成"，掩盖了"数据已污染"。
- 单元测试全绿。

## 根因

GORM 的链式 `Where` 之间用 `AND` 拼接，但**不会给每个 `Where` 的内容自动加括号**。SQL 里 `AND` 优先级高于 `OR`，于是写在同一个 `Where` 里的 OR 组会被上一个条件"切开"。

出事的写法：

```go
tx.Table("core.characters").
    Where("id = ?", characterID).
    Where(`loop_video_urls IS NULL
        OR loop_video_urls = 'null'::jsonb
        OR loop_video_urls = '[]'::jsonb`).      // ← 缺外层括号
    Updates(map[string]any{...})
```

意图：

```sql
WHERE id = ?
  AND (loop_video_urls IS NULL OR loop_video_urls = 'null' OR loop_video_urls = '[]')
```

实际生成：

```sql
WHERE id = ?
  AND loop_video_urls IS NULL
  OR  loop_video_urls = 'null'
  OR  loop_video_urls = '[]'
```

按优先级等价于：

```sql
WHERE (id = ? AND loop_video_urls IS NULL)
   OR loop_video_urls = 'null'     -- 任意行
   OR loop_video_urls = '[]'       -- 任意行
```

**主键约束只保护了第一个分支**，后两个分支对全表生效。所有该列为空的行全部命中。

Go raw string 里的多行 SQL 视觉上很像一个整体，这是它容易骗过 code review 的原因 —— 缩进让三个 OR 看起来"属于"同一个括号组，而括号根本不存在。

## 修复

OR 组自带外层括号，并抽成具名函数固化写法：

```go
func updateCharacterLoopVideoURLsInTx(
    ctx context.Context, tx *gorm.DB, characterID int64, rawURLs string,
) *gorm.DB {
    return tx.WithContext(ctx).
        Table(GCharacter.TableName()).
        Where("id = ?", characterID).
        Where(`(loop_video_urls IS NULL
            OR loop_video_urls = 'null'::jsonb
            OR loop_video_urls = '[]'::jsonb)`).      // ← 外层括号
        Updates(map[string]any{...})
}
```

抽函数不只是为了复用：条件写散落在长事务里时，reviewer 会把它当成"业务分支"扫过去；独立命名的函数会被当成"SQL 构造"逐字读。

## 为什么单元测试假绿（最值得记的一点）

本例有一个专门验证"客户端异步期间新增的 Loop 不被覆盖"的对抗测试，实跑通过，还把这条 SQL 原文抄进了结论。它没抓到 bug，因为：

测试构造的目标行 `loop_video_urls` 已被写成 `["client.mp4"]` → 三个 OR 分支对该行**全部 false** → `id = ?` 是否被括号保护根本不影响结果 → `RowsAffected` 正确返回 0 → 断言通过。

**测试只断言了"目标行没被改"，从未断言"其他行没被改"。**

条件写（conditional update）的测试必须有一条全局断言：

```go
// 不够：只看目标行
assert(targetRow.LoopVideoURLs == `["client.mp4"]`)
assert(completed == false)

// 必须加：受影响范围
var affected int64
tx.Table("core.characters").
    Where("loop_video_urls = ?", newValue).
    Count(&affected)
assert(affected == 1)   // 或 0，视场景
```

同理，任何"只该动一行"的 UPDATE，测试里都该有 `RowsAffected == 1` 之外的**全表范围断言**。`RowsAffected` 只告诉你数量，不告诉你打中了谁 —— 本例 `RowsAffected == 318`，`!= 1` 的门确实触发了，但那时数据已经写了。

## 取证手法

### 1. DryRun 打印生成 SQL

```go
db, _ := gorm.Open(postgres.New(postgres.Config{DSN: "..."}), &gorm.Config{
    DryRun: true, DisableAutomaticPing: true,
})
sql := db.ToSQL(func(tx *gorm.DB) *gorm.DB {
    return tx.Table("t").Where("id = ?", 1).
        Where("a IS NULL OR b = 1").
        Updates(map[string]any{"x": 1})
})
fmt.Println(sql)
// UPDATE "t" SET "x"=1 WHERE id = 1 AND a IS NULL OR b = 1
//                                   ^^^^^^^^^^^^^^^^^^^^^ 无括号，一眼可见
```

### 2. 生产侧确认影响面

```sql
-- 慢查询/审计日志里 rows 数远大于预期，就是信号
-- [rows]: 318  ← 本该是 1
```

日志里的 `[rows]` 字段是最早的暴露点，比业务报错早得多。本例业务侧只看到"任务未完成"。

### 3. 事后定位受污染行

```sql
SELECT id FROM core.characters
WHERE loop_video_urls = '["<误写入的 URL>"]'::jsonb
ORDER BY id;
```

注意清理时要连带把这些行的下游状态一起回滚 —— 本例污染让 317 个角色的 `loop_video_urls` 变成非空，导致补齐任务被同步成 `succeeded`，**Worker 永远不会重新生成**，光清 URL 不够，还要把任务打回可重排状态。

## 防御

1. **任何 `Where` 里出现 `OR`，外层必须自带括号。** 无例外，即使当前只有一个 `Where` 也要加 —— 后面有人加一个 `Where` 就出事。
2. **多分支条件写抽成具名函数**，别内联在长事务里。
3. **条件 UPDATE 的测试必须有全表范围断言**，不能只断言目标行和 `RowsAffected`。
4. **`RowsAffected != expected` 不是安全网**：它在数据写入之后才被检查。要么把条件写对，要么在同事务里回滚。
5. **仓库级排查**：`grep -rn 'Where(' --include=*.go | grep -i ' OR '`，逐条确认括号。同类隐患也存在于 `Not()`、`Or()` 混用和 `db.Where(...).Or(...)` 链式调用。

## 相关

- [gorm-reused-struct-pk-where-condition.md](../debugging/gorm-reused-struct-pk-where-condition.md) — 同属"GORM 生成的 SQL 与意图不符"家族，那篇是隐式追加条件，这篇是显式条件被优先级切开。两者的共同取证手法都是 DryRun 打印 SQL。

关键词：GORM, Where, OR, AND 优先级, 括号, 条件更新, RowsAffected, 全表污染, DryRun, 假绿测试, conditional update, SQL operator precedence
