---
tags: [frontend, manifest, deployment, ssr, caching, gcs, release]
date: 2026-08-07
---

# Manifest 驱动的前端静态资源与 SSR 发布

## 1. 问题不只是“文件有没有上传”

现代前端构建会生成带内容 hash 的 JavaScript、CSS、图片和字体。HTML 或 SSR 服务端产物不会在运行时自动寻找“最新资源”，而是在构建时绑定某一组确定的 hash URL。

因此，一个可工作的前端版本不是若干独立文件，而是一个完整 release：

```text
同一次构建的 manifest
  + manifest 可达的全部 hash 资源
  + HTML 入口
  + SSR bundle 或服务器镜像
  = 一个可激活、可验证、可回滚的发布单元
```

只要其中一部分来自另一轮构建，就会出现版本偏斜：HTML 可以正常返回，首屏 SSR 也可能可见，但客户端脚本 404，页面无法 hydration 和交互。

## 2. 内容 hash 为什么是背景前提

内容 hash 把资源内容编码进 URL：

- 内容不变，URL 不变。
- 内容变化，URL 随 hash 变化。
- 新版本不会覆盖旧 URL，而是创建另一个 URL。

成功返回的 hash 资源因此适合长期缓存：

```http
Cache-Control: public, max-age=31536000, immutable
```

HTML 和 manifest 的 URL 通常稳定、内容会变化，必须重新验证或禁止存储。Manifest 正是稳定逻辑入口与当前 release 的 hash URL 之间的映射。

不了解 hash 缓存背景，manifest 很容易被误解为普通构建清单，发布也容易退化成“把 dist 同步到对象存储”。

## 3. Manifest 在生产中的四个职责

### 3.1 发布物料清单

Manifest 描述入口文件、动态 chunk、CSS、图片等依赖闭包。发布必须确保这个闭包完整存在，不能只检查主入口脚本。

### 3.2 完整性门禁

在 HTML 或 SSR 开始引用新版本之前，应从用户实际访问的公开出口逐个验证 manifest 依赖，而不只是检查对象存储内部是否存在文件。

### 3.3 版本绑定

Manifest、静态资源、HTML 和 SSR 必须来自同一次构建。服务器镜像再用 commit SHA 或 release ID 标记，才能从线上实例反查对应版本。

### 3.4 回收边界

远端“当前 manifest”不是唯一真相源。线上可能同时存在：

- 滚动发布中的旧 SSR Pod。
- 浏览器或 CDN 缓存的旧 HTML。
- 仍在进行中的旧请求。
- 允许回滚的历史版本。

可删除资源应是所有受保护 release 的 manifest 依赖闭包并集之外的对象，而不是简单执行 `rsync --delete` 或按固定天数删除。

## 4. 正确的发布顺序

推荐顺序如下：

```text
1. Checkout 确定的 commit SHA
2. 只构建一次，生成客户端、manifest 与 SSR
3. 追加上传不可变 hash 资源
4. 从公开出口验证 manifest 依赖闭包全部为 200
5. 发布 HTML 与远端 manifest，激活新客户端版本
6. 发布消费同一构建产物的 SSR 镜像
7. 等待 rollout，并重复验证真实页面引用
```

关键点是先准备资源，再切换入口。若资源校验失败，旧 HTML 和旧 SSR 仍然引用保留的旧资源，线上版本不会被破坏。

HTML 与 SSR 不能拆成两个各自重新构建的发布流程。即使两个 job checkout 同一个 commit，构建环境、依赖或非确定性输入也可能让产物不同；最可靠的做法是只构建一次，让后续步骤消费同一份产物。

## 5. 一起发布还不够：必须只有一个写入者

统一发布 job 只能约束经过它的操作。以下入口仍可能绕过编排：

- 使用旧脚本的历史 checkout。
- 其他仓库或旧 pipeline。
- 未纳入同一资源锁的 job。
- 拥有 bucket 写权限的个人账号。

一个旧式静态发布只要执行“上传新 HTML + 删除未匹配资源”，就能在统一发布完成后再次拆开版本：对象存储变成静态版本 B，而 SSR 仍运行版本 A。

因此还需要：

1. UAT/Prod bucket 只允许环境专用发布身份写入。
2. 开发者和其他 CI 身份默认无删除权限。
3. 同一环境的 pipeline 使用资源锁串行化。
4. 开启对象写入与删除的 Data Access 审计。

资源锁通常只能约束一个 CI 项目，IAM 才是阻止外部写入者的最终边界。代码里的 guard 也无法限制仍在使用旧代码的 checkout。

## 6. Manifest 与 HTTP 缓存是两个维度

- Manifest 管版本一致性：定义一个 release 包含哪些内容。
- HTTP 缓存管交付时效：决定客户端何时复用或重新获取这些内容。
- 发布编排连接两者：准备版本图、验证版本图、再激活版本图。

缓存不能修复已经删除对象的 404，manifest 也不会自动控制浏览器、Nginx 或 CDN 的缓存行为。

可以简化为：

```text
构建生成版本图
部署激活版本图
HTTP 缓存分发版本图
```

### 6.1 最佳实践：源站声明、代理透传、CDN 执行

成熟的生产设计不会让对象存储、Nginx 和 CDN 分别维护一套缓存规则。唯一真相源应是版本库中的发布策略；发布流水线根据产物类型写入对象 metadata，对象存储按 metadata 返回标准 HTTP 响应，后续代理层不再重复决策。

| 产物类型 | 建议的 `Cache-Control` |
| --- | --- |
| 带内容 hash 的 JS、CSS、图片 | `public, max-age=31536000, immutable` |
| 版本化且永不覆盖的 manifest | `public, max-age=31536000, immutable` |
| 固定 URL 的 HTML、当前版本 manifest | `no-cache, must-revalidate` |
| 不允许任何中间层存储的响应 | `no-store` |

在 GCP 上，Cloud CDN 不是 GLB 前后的独立跳点，而是 GLB/GFE 的边缘缓存能力。缓存未命中时，一条完整的请求与响应链路是：

```text
请求：浏览器 → GLB/GFE（Cloud CDN 查缓存）→ Nginx/应用 → 对象存储
响应：对象存储 → Nginx 透传 → GLB/GFE（Cloud CDN 执行缓存）→ 浏览器
```

若 Nginx 只是代理静态对象，没有鉴权、签名、路由或内容转换职责，更简单的做法是通过 GLB URL Map 直接分流：

```text
/assets/*       → GLB/GFE + Cloud CDN → GCS Backend Bucket
/api/*、SSR     → GLB/GFE → Backend Service → Nginx/应用
```

保留 Nginx 时，它不应再配置统一的 `add_header Cache-Control ... always`、`expires` 或 `proxy_hide_header Cache-Control`。Cloud CDN 应使用 `USE_ORIGIN_HEADERS`，并将 minimum TTL 设为 `0`；负缓存关闭或只保留秒级 TTL，避免短暂 404 被长期放大。

404、5xx 是边界例外：不存在的对象没有可写入的对象 metadata，因此由产生错误的对象存储、应用或代理明确返回错误缓存头，CDN 只保留防止回源风暴的保护性边界。

## 7. 失败与恢复边界

| 失败位置 | 正确结果 |
| --- | --- |
| 资源上传或完整性校验失败 | 入口未切换，旧版本继续工作 |
| HTML 已切换、SSR rollout 失败 | 旧 SSR 仍能访问保留的旧 hash |
| 外部写入者删除旧 hash | 停止额外写入，完整重发目标 release |
| 只有少数报错资源被恢复 | 动态 import 仍可能引用其他缺失 chunk，不算完整恢复 |

恢复时优先重新发布最新完整 release，不要只根据浏览器控制台手工补几个文件。若错误响应已经被浏览器长缓存，还需要使用新的资源 URL；重新上传同名对象无法主动清除客户端现有缓存。

## 8. 验证与取证

### 8.1 从真实 HTML 反查资源

```bash
curl -sS https://example.com/content/example \
  | rg -o '/assets/[^" ]+\.(js|css)'
curl -sS -I https://example.com/assets/<file>
```

批量验证所有引用，确认状态码、内容类型和缓存头，而不是只抽样入口 JS。

### 8.2 对齐发布身份

核对：

- pipeline checkout SHA。
- 服务器镜像 tag。
- 当前 Pod 的镜像 SHA。
- HTML 与 manifest 的更新时间或对象 generation。
- manifest 引用资源的创建与删除时间。

### 8.3 使用对象 soft delete 还原时间线

若对象存储开启 soft delete：

```bash
gcloud storage ls --soft-deleted --long \
  gs://<bucket>/<prefix>/assets/<file>

gcloud storage objects describe \
  'gs://<bucket>/<prefix>/assets/<file>#<generation>' \
  --soft-deleted --format=json
```

重点关注 `creation_time`、`soft_delete_time` 和 `hard_delete_time`。这些字段能证明对象何时出现或消失，但不能证明是谁操作；归因 principal 仍然依赖 Data Access 审计日志。

## 9. 发布不变量清单

- 一个 release 只构建一次。
- 静态资源、manifest、HTML 与 SSR 消费同一构建产物。
- 先上传并验证资源，后切换入口。
- 校验完整 manifest 依赖闭包。
- UAT/Prod 发布期间不删除旧 hash。
- 资源清理以受保护 manifest 集合为边界。
- 每个环境只有一个受控写入身份。
- 公开出口验证状态码和缓存头。
- 发布完成后验证真实页面的全部资源引用与客户端交互。

## 参考资料

- [Vite：Backend Integration](https://vite.dev/guide/backend-integration)
- [MDN：Cache-Control](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control)
- [Google Cloud CDN：Cloud CDN overview](https://cloud.google.com/cdn/docs/overview)
- [Google Cloud CDN：Caching overview](https://cloud.google.com/cdn/docs/caching)
- [Google Cloud CDN：Set up a backend bucket](https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket)
- [Google Cloud Storage：Soft delete](https://cloud.google.com/storage/docs/soft-delete)
