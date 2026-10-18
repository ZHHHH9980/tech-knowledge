# 共用高频 SQL 加 OR 导致部分索引不再适用、执行计划退化

## 场景

PostgreSQL 表被当作任务队列使用，多个 worker 按任务类型高频领取任务：

```sql
SELECT t.id FROM tasks t
WHERE t.task_type = $1
  AND (t.status = 'pending' OR (t.status = 'running' AND t.leased_until < now()))
  AND t.available_at <= now()
  AND t.attempts < t.max_attempts
ORDER BY t.available_at, t.id
FOR UPDATE OF t SKIP LOCKED
LIMIT 1;
```

配套一个部分索引（Partial Index），只收录可领取的任务：

```sql
CREATE INDEX idx_tasks_claim_by_type ON tasks (task_type, available_at, id)
WHERE status IN ('pending', 'running') AND attempts < max_attempts;
```

查询条件覆盖了索引的收录条件，`task_type` 和 `ORDER BY` 又与索引列顺序一致，因此每次领取只需读取该类型的第一条记录。

## 问题

新增一种任务类型，要求它不受重试次数限制，于是把条件改成：

```sql
AND (t.attempts < t.max_attempts OR t.task_type = 'new_type')
```

功能测试和测试环境验证都通过了。上线后，数据库 CPU 被打满，全站查询变慢，只能回滚。

## 原因

1. **部分索引只有在查询条件能推出其收录条件时才会被使用。** 新增的 OR 分支允许命中 `attempts >= max_attempts` 的记录，而这些记录不在索引里，优化器无法再使用该索引，执行计划随之退化：改走只按状态排序的索引，或者顺序扫描，对所有类型的活跃任务逐行过滤。
2. **这是一条参数化的共用 SQL。** 所有任务类型共用同一份 SQL 文本和通用执行计划。即使对旧类型来说 `task_type = 'new_type'` 永远不成立，通用计划也必须覆盖 `$1 = 'new_type'` 的情况，所以所有类型的领取都会退化，不只是新类型。
3. **高频执行会成倍放大开销。** 每个 pod 的每个队列每隔几秒就领取一次，扫到的每一行都要做可见性检查、计算条件、执行子查询、检查锁。热数据常驻内存，所以开销集中在 CPU 上。
4. **"找不到任务"是最坏情况。** 找得到时扫到第一条就停；找不到时（例如队头全是不满足依赖的任务）必须扫完所有候选行，而且每个轮询周期都要重来一遍。
5. **测试环境数据量小，掩盖了问题。** 小表即使全扫也很快，只有在线上的数据量和并发下才会暴露。

## 判断方法

查询中的每一个 OR 分支，都必须落在部分索引的收录条件之内：

| 写法 | 是否可用索引 |
| --- | --- |
| `status = 'pending' OR (status = 'running' AND ...)` | 可用：两个分支都在 `status IN ('pending','running')` 之内 |
| `attempts < max_attempts OR task_type = 'x'` | 不可用：第二个分支可能命中索引外的记录 |

增加额外的 AND 条件只会缩小范围，不影响索引的使用；用 OR 放宽、或删掉收录条件，都会让索引不再适用。

## 正确做法

不要从查询条件上放宽，而是从数据上满足收录条件：例如插入新类型任务时直接设置一个足够大的 `max_attempts`，领取 SQL 保持原样。如果新类型确实需要完全不同的领取规则，就为它单独写查询、单独建部分索引。

## 教训

- **SQL 查得对，不代表查得快。** 功能验证通过，不代表可以安全上线。
- 修改 WHERE、OR、排序或关联条件时，要对比修改前后的执行计划，确认仍然使用预期的索引。
- 高频查询要分别验证"找到任务"和"找不到任务"两种情况，找不到时也可能扫描大量数据。
- 修改共用 SQL 时，要检查所有调用方，不能只验证新增的类型。
- 修改前，先到迁移仓库查看该表的索引定义；索引常常不在业务仓库里。
- 高频查询要监控耗时，比如设置领取耗时 P99 告警，执行计划退化时能在几分钟内发现。

## 验证命令

```sql
-- 对比修改前后的执行计划，确认是否仍出现目标索引名
EXPLAIN SELECT ...;
-- 只读环境可以加 ANALYZE 查看实际耗时和读取的数据页
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
```

关键词：Partial Index、部分索引、OR、执行计划退化、generic plan、任务队列、SKIP LOCKED、CPU 打满
