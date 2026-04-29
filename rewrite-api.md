# Quantumult X Rewrite 重写规则参考 (Rewrite API Reference)

> Rewrite 用于修改 HTTP/HTTPS 请求和响应的头部、状态码、Body 内容。
> Rewrite is used to modify HTTP/HTTPS request/response headers, status codes, and body content.

---

## 基本语法 (Basic Syntax)

```
<type> <pattern> <target>
```

| 参数 (Parameter) | 说明 (Description) |
|---|---|
| `type` | 重写类型 (Rewrite type) |
| `pattern` | 匹配 URL 的正则表达式 (URL regex pattern) |
| `target` | 替换目标 (Replacement target) |

---

## 类型详解 (Type Details)

### 1. reject — 拒绝请求 (Reject Request)

直接返回 HTTP 200 空响应，阻断该请求。

```ini
# 格式: ^https?://url pattern$ - reject
^https?://example\.com/api/ad\b - reject
```

#### 变体 (Variants)

| Command | 说明 (Description) |
|---|---|
| `reject` | 返回 HTTP 200，空 body |
| `reject-200` | 同 reject |
| `reject-img` | 返回 1x1 透明 PNG 图片 |
| `reject-dict` | 返回空 JSON 字典 `{}` |
| `reject-array` | 返回空 JSON 数组 `[]` |

```ini
# 示例 Example
^https?://example\.com/ad\.jpg$ - reject-img        # 返回透明图 / Returns transparent image
^https?://api\.example\.com/config$ - reject-dict   # 返回空JSON / Returns empty JSON {}
```

---

### 2. http-request — 修改请求 (Modify Request)

```ini
# 修改请求头 / Modify request headers
^https?://example\.com/api - req-header-json (\w+) (.*)

# 修改请求 Body / Modify request body
^https?://example\.com/api - req-body-json (\w+) (.*)
```

**Syntax (几种写法):**

| Pattern | 功能 (Function) |
|---|---|
| `http-request ^url regex^ header-key header-value` | 修改/添加单个请求头 |
| `http-request ^url regex^ body <regex> <replacement>` | 正则替换请求 Body |
| `http-request ^url regex^ script-response-body <script-path>` | 用 JS 脚本处理 |

---

### 3. http-response — 修改响应 (Modify Response)

```ini
# 修改响应头 / Modify response headers
^https?://example\.com/api - res-header-json (\w+) (.*)

# 修改响应 Body / Modify response body
^https?://example\.com/api - res-body-json (\w+) (.*)
```

| Pattern | 功能 (Function) |
|---|---|
| `http-response ^url regex^ header-key header-value` | 修改/添加单个响应头 |
| `http-response ^url regex^ body <regex> <replacement>` | 正则替换响应 Body |
| `http-response ^url regex^ script-response-body <script-path>` | 用 JS 脚本处理响应 |

---

### 4. 302 / 307 — 重定向 (Redirect)

```ini
# 302 临时重定向 / Temporary redirect
^https?://old\.domain\.com/path$ - 302 https://new.domain.com/path

# 307 临时重定向 (保留方法) / Temporary redirect (preserving method)
^https?://old\.domain\.com/path$ - 307 https://new.domain.com/path
```

---

## 匹配类型标记 (Pattern Matching Flags)

在 pattern 后可添加标记来控制匹配规则：

| Flag | 说明 (Description) |
|---|---|
| `reject` | 直接拒绝 |
| `reject-200` | 返回 200 |
| `reject-img` | 返回透明图 |
| `reject-dict` | 返回空字典 `{}` |
| `reject-array` | 返回空数组 `[]` |
| `request-header` | 修改请求头 |
| `response-header` | 修改响应头 |
| `request-body` | 修改请求体 |
| `response-body` | 修改响应体 |
| `302` / `307` | 重定向 |

---

## 常用示例 (Common Examples)

### 去广告 (Ad Blocking)

```ini
# 广告域名直接拒绝 / Reject ad domains
^https?://[\w-]+\.doubleclick\.net/ - reject
^https?://[\w-]+\.googlesyndication\.com/ - reject
^https?://[\w-]+\.ads\.example\.com/ - reject-img
```

### 修改 User-Agent (Modify User-Agent)

```ini
# 请求头替换通用UA / Replace universal User-Agent
^https?://example\.com/api - request-header User-Agent Mozilla/5.0.*
```

### 修改响应内容 (Modify Response Content)

```ini
# 替换响应Body中的文本 / Replace text in response body
^https?://api\.example\.com/data - response-body "old_key" "new_value"
```

### 重定向 (Redirect)

```ini
# 旧域->新域 / Old domain -> New domain
^https?://old\.api\.com/v[12]/ - 302 https://new.api.com/v2/
```

---

## 正则表达式技巧 (Regex Tips)

| 场景 (Scenario) | 正则 (Regex) |
|---|---|
| 匹配 HTTP/HTTPS | `^https?://` |
| 匹配域名后的路径 | `/path.*` |
| 匹配 URL 结尾 | `$` |
| 匹配任意子域名 | `[\w-]+\.` |
| 匹配单词边界 | `\b` |
| 转义点号 | `\.` |
| 捕获组引用 | `$1`, `$2` |

---

## 注意事项 (Notes)

1. Rewrite 需要 MitM 解密 HTTPS 流量才能生效
2. 规则按顺序匹配，**第一个匹配的规则生效**
3. `response-body` 替换在 `script-response-body` 脚本**之前**执行
4. 大量正则可能影响性能，建议精确匹配
5. 脚本文件需放在 iCloud Drive `Quantumult X/Scripts/` 目录下