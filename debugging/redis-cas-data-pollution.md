# Redis 数据污染导致 CAS 永久失败

## 场景

CAS (Compare-And-Swap) 乐观锁通过 Lua 脚本在 Redis 中做字符串比较：

```lua
local current = redis.call("GET", key)
if current == expected then
    redis.call("SET", key, next)
    return 0
end
return current
```

## 问题

`redis-cli -x SET key < file` 或 `echo value | redis-cli -x SET key` 写入的值会带换行符。
`echo` 默认追加 `\n`，`-x` 从 stdin 读取时保留所有字节。

导致 CAS 比较：`"386" == "386\n"` → 永远失败。

## 诊断

错误信息已经包含答案：`actual_in_redis="386\n"` — 引号内的 `\n` 就是问题。

验证命令：
```bash
redis-cli STRLEN key  # 应该是 3（"386"），如果是 4 说明有多余字符
```

## 修复

```bash
redis-cli SET key "386"  # 覆写为干净值
redis-cli STRLEN key     # 确认长度正确
```

## 防御

在 CAS Lua 脚本中加 trim：
```lua
local current = redis.call("GET", key)
if current == false then current = "0" end
current = current:gsub("%s+", "")  -- 防御性 trim
```

## 排查方法论

遇到 "expected ≠ actual" 类错误的排查优先级：

1. **精读错误信息** — 提取 actual 和 expected 的具体差异
2. **验证数据源** — 直接 GET + STRLEN/TYPE 看原始值
3. **区分写入来源** — 代码路径（strconv.FormatInt/INCR）vs 人工操作（redis-cli -x/echo pipe）
4. **最后才怀疑代码逻辑**

## 反模式

- 看到 CAS 失败就怀疑并发逻辑
- 看到 version 对不上就怀疑前端传参
- 不去看数据源直接改代码
