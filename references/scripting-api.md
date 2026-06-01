# Quantumult X JavaScript 脚本 API 参考 (Scripting API Reference)

> Quantumult X 支持通过 JavaScript 脚本来处理 MitM 解密的 HTTP 请求和响应。
> Quantumult X supports JavaScript scripting to process MitM-decrypted HTTP requests and responses.

---

## 脚本类型 (Script Types)

### 1. 请求脚本 (Request Script)
在请求发出前执行，可修改 URL、请求头、请求体。

```javascript
// 脚本文件示例 / Script file example
// 被 Rewrite 的 http-request 规则触发
// Triggered by http-request rewrite rule

$done({
    url: $request.url,          // 可修改 URL / Modify URL
    headers: $request.headers,  // 可修改 Headers / Modify headers
    body: $request.body,        // 可修改 Body / Modify body
});
```

### 2. 响应脚本 (Response Script)
在响应返回后执行，可修改响应状态码、响应头、响应体。

```javascript
// 被 Rewrite 的 http-response 规则触发
// Triggered by http-response rewrite rule

$done({
    status: $response.statusCode,   // 可修改状态码 / Modify status code
    headers: $response.headers,     // 可修改响应头 / Modify response headers
    body: $response.body,           // 可修改响应体 / Modify response body
});
```

### 3. Task 脚本 (Task Script)
通过 `[task_local]` 定时触发或手动执行。

```javascript
// 定时任务脚本 / Scheduled task script
$task.fetch({}).then(response => {
    $notify("Title", "Subtitle", response.body);
    $done();
});
```

---

## 核心 API (Core APIs)

### `$request` — 请求对象 (Request Object)

```javascript
$request = {
    url: "https://api.example.com/data",
    method: "GET",          // GET / POST / PUT / DELETE
    headers: {
        "Content-Type": "application/json",
        "User-Agent": "Quantumult X/1.0",
    },
    body: "{\"key\":\"value\"}",
    scheme: "https",
    host: "api.example.com",
    path: "/data",
    port: 443,
};
```

| 属性 (Property) | 类型 (Type) | 说明 (Description) |
|---|---|---|
| `$request.url` | String | 完整请求 URL |
| `$request.method` | String | 请求方法 (GET/POST/PUT/DELETE) |
| `$request.headers` | Object | 请求头字典 |
| `$request.body` | String | 请求体（字符串） |
| `$request.scheme` | String | http 或 https |
| `$request.host` | String | 域名 (Hostname) |
| `$request.path` | String | URL 路径 (URL path) |
| `$request.port` | Number | 端口号 |

---

### `$response` — 响应对象 (Response Object)

```javascript
$response = {
    statusCode: 200,        // HTTP 状态码 / Status code
    headers: {
        "Content-Type": "application/json",
    },
    body: "{\"data\":\"value\"}",
};
```

| 属性 (Property) | 类型 (Type) | 说明 (Description) |
|---|---|---|
| `$response.statusCode` | Number | HTTP 状态码 |
| `$response.headers` | Object | 响应头字典 |
| `$response.body` | String | 响应体（字符串） |

---

### `$done()` — 结束处理 (Finish Processing)

**必须调用**，否则请求会超时。参数可选。

```javascript
// 1. 不做任何修改 / No modification
$done();

// 2. 只修改请求/响应体 / Modify body only
$done({ body: JSON.stringify(newData) });

// 3. 完整修改请求 / Full request modification
$done({
    url: "https://new-api.example.com",
    headers: { ...$request.headers, "X-Custom": "value" },
    body: modifiedBody,
});

// 4. 完整修改响应 / Full response modification
$done({
    status: 200,
    headers: { ...$response.headers },
    body: modifiedBody,
});
```

---

### `$notify()` — 发送通知 (Send Notification)

```javascript
// 基本用法 / Basic usage
$notify("Title 标题", "Subtitle 副标题", "Message 消息内容");

// 带 URL Scheme / With URL scheme
$notify("Title", "Subtitle", "Message", { "open-url": "quantumult-x://" });

// 自动展开详情 / Auto-expand details
$notify("Title", "Subtitle", "Message", {
    "open-url": "quantumult-x://",
    "auto-dismiss": true
});
```

---

### `$prefs` — 持久化偏好存储 (Persistent Preferences)

```javascript
// 读取 / Read
const value = $prefs.valueForKey("my_key");

// 写入 / Write
$prefs.setValueForKey("my_value", "my_key");

// 删除 / Remove
$prefs.removeValueForKey("my_key");

// 检查是否存在 / Check existence
const exists = $prefs.isKey("my_key");
```

---

### `$persistentStore` — 持久化存储 (Persistent Key-Value Store)

```javascript
// 全局存储 / Global store
$persistentStore.write("hello", "key1");
const value = $persistentStore.read("key1");
$persistentStore.remove("key1");

// 查看是否开启（iOS 需在设置中开启）
const enabled = $persistentStore.isEnabled();
```

---

### `$task.fetch()` — HTTP 请求 (HTTP Fetch)

用于 Task 脚本发起 HTTP 请求：

```javascript
// 基本 GET 请求 / Basic GET request
$task.fetch({
    url: "https://api.example.com/data",
    method: "GET",
}).then(response => {
    console.log(response.statusCode);
    console.log(response.headers);
    console.log(response.body);
    $done();
}, reason => {
    $notify("Error", "", reason.error);
    $done();
});

// POST 请求 / POST request
$task.fetch({
    url: "https://api.example.com/submit",
    method: "POST",
    headers: {
        "Content-Type": "application/json",
    },
    body: JSON.stringify({ key: "value" }),
}).then(response => {
    const data = JSON.parse(response.body);
    $done();
});
```

| 参数 (Param) | 说明 (Description) |
|---|---|
| `url` | 请求 URL |
| `method` | GET / POST / PUT / DELETE (默认 GET) |
| `headers` | 请求头对象 |
| `body` | 请求体字符串 |
| `timeout` | 超时秒数 (默认 10s) |
| `policy-descriptor` | 使用指定策略 (如 DIRECT) |

---

### `$task.fetch()` 响应对象 (Response Object)

```javascript
{
    statusCode: 200,        // HTTP 状态码
    headers: {},            // 响应头
    body: "response text",  // 响应体字符串
    error: "",              // 错误信息 (如有)
}
```

---

## 实用代码示例 (Practical Examples)

### 示例 1: 签到脚本 (Check-in Script)

```javascript
// 自动签到 / Auto sign-in
const url = "https://api.example.com/signin";
const token = $prefs.valueForKey("user_token");

$task.fetch({
    url: url,
    method: "POST",
    headers: {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json",
    },
}).then(response => {
    const result = JSON.parse(response.body);
    if (result.code === 0) {
        $notify("签到成功 ✅", "", `获得 ${result.data.points} 积分`);
    } else {
        $notify("签到失败 ❌", "", result.message);
    }
    $done();
});
```

### 示例 2: 响应重写 (Response Rewriting)

```javascript
// 移除广告 / Remove ads
const body = JSON.parse($response.body);

// 修改数据 / Modify data
body.data.ads = [];
body.data.vip = true;
body.data.expire_time = "2099-12-31";

$done({ body: JSON.stringify(body) });
```

### 示例 3: 请求头修改 (Request Header Modification)

```javascript
// 添加自定义请求头 / Add custom headers
const headers = { ...$request.headers };
headers["X-Custom-Header"] = "custom_value";
headers["User-Agent"] = "Mozilla/5.0 Custom";

$done({
    url: $request.url,
    headers: headers,
    body: $request.body,
});
```

### 示例 4: 多接口调用 (Multiple API Calls)

```javascript
// 先获取 token / Get token first
$task.fetch({
    url: "https://api.example.com/auth",
    method: "POST",
    body: JSON.stringify({ user: "admin", pass: "pwd" }),
}).then(authResponse => {
    const token = JSON.parse(authResponse.body).token;

    // 再用 token 请求数据 / Then use token to fetch data
    return $task.fetch({
        url: "https://api.example.com/data",
        headers: { "Authorization": `Bearer ${token}` },
    });
}).then(dataResponse => {
    console.log(dataResponse.body);
    $done();
});
```

### 示例 5: 通知 & 存储结合 (Notify + Store combo)

```javascript
// 汇率监控 / Exchange rate monitor
$task.fetch({
    url: "https://api.exchangerate-api.com/v4/latest/USD",
}).then(response => {
    const data = JSON.parse(response.body);
    const currentRate = data.rates.CNY;
    const lastRate = parseFloat($prefs.valueForKey("last_cny_rate") || "0");

    if (lastRate > 0 && Math.abs(currentRate - lastRate) > 0.1) {
        const change = currentRate > lastRate ? "📈 上涨" : "📉 下跌";
        $notify("汇率变动", change, `USD → CNY: ${currentRate}`);
    }

    $prefs.setValueForKey(String(currentRate), "last_cny_rate");
    $done();
});
```

---

## 常用工具函数 (Utility Functions)

```javascript
// Base64 编解码 / Base64 encode/decode
const decoded = atob(encodedString);
const encoded = btoa("hello");

// JSON 安全解析 / Safe JSON parse
function safeJSON(str) {
    try { return JSON.parse(str); }
    catch(e) { return null; }
}

// 日志输出 (查看日志: QuanX → 日志) / Log output
console.log("Debug info:", variable);
console.error("Error occurred:", error);
```

---

## 注意事项 (Notes)

1. **`$done()` 是必须的** — 忘记调用会导致请求超时/挂起
2. 脚本文件放在 iCloud Drive `Quantumult X/Scripts/` 目录
3. `$task.fetch()` 仅在 Task 脚本中可用（Request/Response 脚本中用不了）
4. `$persistentStore` 需要 iOS 设置中手动开启持久化
5. `$notify()` 最多显示约 200 字符
6. 脚本有执行时限（约 30s），超时会强制终止