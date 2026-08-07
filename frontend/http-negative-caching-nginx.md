---
tags: [frontend, nginx, http, caching, cache-control, cdn, debugging]
date: 2026-08-07
---

# 404 负缓存：为什么静态资源恢复后用户仍然打不开页面

## 1. 典型现象

一次前端发布短暂删除了带 hash 的资源，浏览器请求资源时收到 404。资源随后重新上传，直接请求已经返回 200，但部分用户仍持续看到：

```text
Failed to load resource: the server responded with a status of 404
```

DevTools 可能显示 `from disk cache`。这时源站已经恢复，用户仍失败的原因是浏览器缓存了先前的 404。

问题不在“浏览器为什么缓存”，而在出口错误地把 404 标记成了可长期公开缓存的响应，例如：

```http
HTTP/2 404
Cache-Control: public, max-age=1209600, must-revalidate
```

`must-revalidate` 只要求响应过期后重新验证；在 14 天 `max-age` 内，它仍是 fresh 响应，浏览器可以直接复用。

## 2. 先分清几个 Cache-Control 指令

| 指令 | 含义 |
| --- | --- |
| `max-age=N` | 私有和共享缓存可在 N 秒内直接复用响应 |
| `s-maxage=N` | 仅控制 CDN、代理等共享缓存，并覆盖 `max-age` |
| `no-cache` | 可以存储，但每次复用前必须向源站验证 |
| `no-store` | 不应存储响应 |
| `immutable` | fresh 期间内容不会变化，不需要刷新验证 |

`Age` 是共享缓存已经持有响应的时间，不是配置的缓存期限。

因此，`max-age=0` 与 `no-store` 也不相同：前者允许存储但要求立即重新验证，后者禁止存储。

## 3. 为什么应该在 Nginx/CDN 层解决

成功存在的对象可以在 GCS、S3 等对象存储上配置 `Cache-Control` metadata。404 对应的对象并不存在，因此没有对象 metadata 可以修改。

最终缓存策略只能由产生或转发错误响应的层决定：

```text
对象存储 → Nginx/网关 → 负载均衡/CDN → 浏览器
```

如果对象存储原始 404 是 `private, max-age=0`，但公开出口变成 `public, max-age=1209600`，说明中间层覆盖了响应头。常见原因是对整个 `/assets/` location 无条件执行：

```nginx
add_header Cache-Control "public, max-age=1209600" always;
```

`always` 会让该响应头出现在包括 404、5xx 在内的所有状态码上。路径是 `/assets/` 不代表响应一定是成功的静态资源。

## 4. 正确策略必须同时判断路径和状态码

推荐策略：

| 响应 | 浏览器缓存策略 |
| --- | --- |
| 2xx 内容 hash 资源 | `public, max-age=31536000, immutable` |
| HTML、manifest 等可变入口 | `no-cache, no-store, must-revalidate` |
| 404、5xx | `no-store` |

反向代理资源时，可以根据 upstream 状态生成缓存头。示意配置如下，实际变量要按部署方式调整：

```nginx
map $upstream_status $asset_cache_control {
    ~^2     "public, max-age=31536000, immutable";
    default "no-store";
}

location /assets/ {
    proxy_pass https://object-storage;
    proxy_hide_header Cache-Control;
    add_header Cache-Control $asset_cache_control always;
}
```

若 Nginx 直接读取本地文件而不是代理 upstream，应使用本地 404/error location 分支表达同一规则。配置完成后必须从公开域名验证，不能只检查 Nginx 文件或对象存储 metadata。

## 5. 大规模系统会不会缓存 404

会，但通常只在 CDN 做短暂的负缓存，用于减少不存在 URL 对源站的重复压力。Google Cloud CDN 的 404 默认负缓存 TTL 是 120 秒，并允许按状态码配置。

关键区别是：

- CDN 可以短暂缓存错误，保护源站。
- 浏览器不应收到数天或数月的 404 `max-age`。
- 负缓存 TTL 应与发布窗口和恢复目标匹配，通常是秒级或分钟级。

若要只让共享缓存短暂保存，可以使用 CDN 的 negative caching policy，或设计 `s-maxage` 与浏览器 `max-age` 的分层策略。最简单、最安全的应用出口策略仍是让 404 返回 `no-store`。

## 6. 已经缓存 404 的用户怎么办

修改 Nginx 只能影响下一次网络响应，无法主动改写浏览器磁盘缓存中仍处于 fresh 状态的旧响应。

恢复选项按可靠性排序：

### 6.1 发布新的资源 URL

这是面向生产用户最可靠的方式。新 HTML 或 SSR 引用新的 hash 或 release namespace，浏览器没有对应缓存记录，会正常请求新 URL。

```text
/assets/<release-id>/app-<content-hash>.js
```

重新构建相同 commit 往往产生相同 hash，因此单纯重跑构建并重新上传同名对象不一定能绕开已缓存 404。

### 6.2 清理 CDN 缓存

CDN purge 可以修复共享边缘缓存，但无法删除用户设备上的浏览器缓存。它不能代替新的资源 URL。

### 6.3 让内部用户强制刷新

在 UAT、测试环境可以使用：

- DevTools 勾选 Disable cache 后强制刷新。
- 清理站点数据。
- 使用无痕窗口验证。

这只是内部恢复手段，不能作为生产解决方案。

## 7. 为什么发布流程仍是第一道防线

最好的负缓存恢复是根本不让用户看到发布窗口中的 404：

```text
先上传新 hash 资源
→ 从公开出口验证完整 manifest 闭包
→ 再切换 HTML/manifest
→ 再发布消费同一构建的 SSR
→ 保留旧 release 资源
```

状态码缓存策略是第二道防线。当对象因为误删、权限、复制延迟或外部写入者而暂时不存在时，404 `no-store` 可以让客户端在资源恢复后再次请求，而不是把短暂故障固化数天。

## 8. 排查清单

### 8.1 对比直连与公开出口

```bash
curl -sS -I https://storage.example.com/assets/app-hash.js
curl -sS -I https://www.example.com/assets/app-hash.js
```

关注：

- HTTP 状态码。
- `Cache-Control`、`Expires`、`Age`。
- `Via`、CDN 命中信息。
- 对象 `Last-Modified` 或 generation。

### 8.2 同时测试存在和不存在的资源

```bash
curl -sS -I https://www.example.com/assets/existing-hash.js
curl -sS -I https://www.example.com/assets/definitely-missing.js
```

期望结果：成功的 hash 资源长期 immutable；不存在资源不被浏览器存储。

### 8.3 验证真实页面全部依赖

不要只测试主入口。HTML 中的 modulepreload、CSS，以及 JavaScript 动态 import 的 chunk 都可能单独失败。

## 9. 结论

1. 404 可以做负缓存，但浏览器不应长期缓存发布资源的 404。
2. 对象不存在时没有 metadata 可改，Nginx/CDN 是错误响应缓存策略的控制层。
3. `/assets/` 路径与成功状态必须同时成立，才能使用 immutable 长缓存。
4. 修复响应头不能清除已有浏览器缓存；生产恢复需要新资源 URL。
5. 正确发布顺序避免 404，按状态码缓存则限制意外故障的影响范围。

## 参考资料

- [NGINX：ngx_http_headers_module](https://nginx.org/en/docs/http/ngx_http_headers_module.html)
- [MDN：Cache-Control](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control)
- [Google Cloud CDN：Negative caching](https://cloud.google.com/cdn/docs/using-negative-caching)

