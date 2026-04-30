# Quantumult X Task 定时任务参考 (Task API Reference)

> Task 用于定时执行 JavaScript 脚本，实现自动签到、数据采集、通知等功能。
> Task is used to schedule JavaScript scripts for auto check-in, data collection, notifications, etc.

---

## Task 配置语法 (Task Configuration Syntax)

### 本地任务 (Local Task)

```ini
[task_local]
# 格式 / Format:
<event-type> <cron-expression> <tag=<标签>>, <script-path>, <arguments>

# 示例 / Examples:
event-interaction */30 * * * * *, tag=🪙 签到, script-path=signin.js
event-network * * * * *, tag=📡 网络监控, script-path=monitor.js
```

| 参数 (Parameter) | 说明 (Description) |
|---|---|
| `event-type` | 事件类型: `event-interaction` / `event-network` |
| `cron-expression` | cron 定时表达式 |
| `tag=` | 在 QuanX 中显示的任务标签 |
| `script-path` | 本地脚本文件路径或 URL |
| `arguments` | 传递给脚本的参数（可选） |

---

### 远程任务 (Remote Task)

```ini
[task_remote]
# 格式 / Format:
<url>, tag=<名称>, enabled=<true|false>, update-interval=<秒>

# 示例 / Examples:
https://raw.githubusercontent.com/user/tasks/main/tasks.json, tag=📋 远程任务集, enabled=true, update-interval=3600
```

远程任务文件格式（JSON）:

```json
{
    "name": "签到任务集",
    "description": "每日签到任务集合",
    "task": [
        {
            "tag": "🪙 每日签到",
            "cron": "0 8 * * *",
            "script-url": "https://example.com/signin.js",
            "event-type": "event-interaction"
        },
        {
            "tag": "📊 数据采集",
            "cron": "*/30 * * * *",
            "script-url": "https://example.com/collect.js",
            "event-type": "event-interaction"
        }
    ]
}
```

---

## 事件类型 (Event Types)

### event-interaction — 交互事件 (Interactive Event)

脚本执行期间可与 QuanX 界面交互（如显示通知、使用存储等）。

```ini
event-interaction 0 8 * * *, tag=🪙 每日签到, script-path=signin.js
```

**适用场景 (Use Cases):**
- 每日签到 / Daily check-in
- 积分领取 / Points collection
- 通知推送 / Notification push
- 数据统计 / Data statistics

---

### event-network — 网络事件 (Network Event)

当设备网络状态变化时触发（Wi-Fi ↔ 蜂窝网络切换等）。

```ini
event-network * * * * *, tag=📡 网络切换检测, script-path=network-change.js
```

**适用场景 (Use Cases):**
- 网络状态监控 / Network status monitoring
- IP 变更检测 / IP change detection
- 网络切换后的自动操作 / Auto actions after network switch

---

## Cron 表达式详解 (Cron Expression Guide)

### 基本格式 (Basic Format)

```
* * * * * *
│ │ │ │ │ │
│ │ │ │ │ └── 星期 / Day of week (0-7, 0=周日/Sunday)
│ │ │ │ └──── 月份 / Month (1-12)
│ │ │ └────── 日期 / Day of month (1-31)
│ │ └──────── 小时 / Hour (0-23)
│ └────────── 分钟 / Minute (0-59)
└──────────── 秒钟 / Second (0-59, 可选/Optional)
```

### 常用表达式 (Common Expressions)

| 表达式 (Expression) | 含义 (Meaning) |
|---|---|
| `0 8 * * *` | 每天 8:00 / Daily at 8:00 |
| `0 8 * * 1-5` | 工作日 8:00 / Weekdays at 8:00 |
| `*/30 * * * *` | 每 30 分钟 / Every 30 minutes |
| `0 */6 * * *` | 每 6 小时 / Every 6 hours |
| `0 0 1 * *` | 每月 1 号 0:00 / 1st of month at midnight |
| `*/5 * * * * *` | 每 5 秒 / Every 5 seconds |
| `0 0 * * 0` | 每周日 0:00 / Every Sunday at midnight |
| `0 9,18 * * *` | 每天 9:00 和 18:00 / Daily at 9:00 and 18:00 |
| `0 8 1-7 * 1` | 每月第一个周一 8:00 / First Monday of month at 8:00 |

### 特殊字符 (Special Characters)

| 字符 (Char) | 说明 (Description) | 示例 (Example) |
|---|---|---|
| `*` | 任意值 / Any value | `* * * * *` = 每秒 |
| `,` | 列举多个值 / List values | `8,12,18` = 8点、12点、18点 |
| `-` | 范围 / Range | `9-17` = 9点到17点 |
| `/` | 步进 / Step | `*/15` = 每15单位 |
| `?` | 不指定 (仅日/星期) / No specific value | `?` = 忽略 |

---

## 脚本参数传递 (Script Arguments)

```ini
[task_local]
# 多个参数用 & 连接 / Multiple params joined by &
event-interaction */5 * * * *, tag=🔔 提醒, script-path=reminder.js, key1=value1&key2=value2
```

在脚本中获取参数 (Retrieve in script):

```javascript
// 获取参数 / Get arguments
const params = $context.fetch();
// params = "key1=value1&key2=value2"

// 解析参数 / Parse arguments
function parseQuery(queryString) {
    const result = {};
    if (!queryString) return result;
    queryString.split('&').forEach(pair => {
        const [key, value] = pair.split('=');
        result[decodeURIComponent(key)] = decodeURIComponent(value || '');
    });
    return result;
}
const args = parseQuery(params);
console.log(args.key1); // "value1"
```

---

## 完整 Task 脚本模板 (Complete Task Script Template)

```javascript
/*******************************
 ** Quantumult X Task Script   **
 ** 版本 (Version): 1.0.0       **
 ** 作者 (Author): Your Name    **
 ** 描述 (Description): 每日签到 **
 *******************************/

// Task 脚本入口 / Task script entry point
(async () => {
    try {
        // 1. 发起请求 / Make request
        const response = await $task.fetch({
            url: "https://api.example.com/checkin",
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ date: new Date().toISOString() }),
        });

        // 2. 处理响应 / Process response
        if (response.statusCode === 200) {
            const result = JSON.parse(response.body);
            
            // 3. 存储数据 / Store data
            const lastCheckin = $prefs.valueForKey("last_checkin_date") || "";
            $prefs.setValueForKey(
                new Date().toISOString().split('T')[0],
                "last_checkin_date"
            );
            
            // 4. 发送通知 / Send notification
            $notify(
                "签到成功 ✅ / Check-in Success",
                `日期 Date: ${new Date().toLocaleDateString()}`,
                `获得 Earned: ${result.points} 积分 points\n` +
                `连续签到 Streak: ${result.streak} 天 days`
            );
        } else {
            $notify(
                "签到失败 ❌ / Check-in Failed",
                "",
                `状态码 Status: ${response.statusCode}`
            );
        }
    } catch (error) {
        // 5. 错误处理 / Error handling
        console.error("签到错误 Check-in error:", error);
        $notify(
            "签到异常 ⚠️ / Check-in Error",
            "",
            error.message || "Unknown error"
        );
    }
    
    // 6. 必须 / Required
    $done();
})();
```

---

## 调试技巧 (Debugging Tips)

### 1. 手动执行 (Manual Execution)

在 QuanX 的 Task 界面，左滑任务即可**手动触发执行**。

### 2. 日志查看 (View Logs)

```
QuanX → 底部菜单 → 日志 (Log)
```

或在脚本中使用:
```javascript
console.log("Debug:", variable);
console.error("Error:", error);
```

### 3. 测试模式 (Test Mode)

```javascript
// 开发时增加调试标志 / Debug flag during development
const DEBUG = true;
if (DEBUG) {
    console.log("========== 调试开始 Debug Start ==========");
    console.log("Params:", params);
    console.log("Time:", new Date().toISOString());
    console.log("========== 调试结束 Debug End ==========");
}
```

### 4. 错误追踪 (Error Tracking)

```javascript
async function main() {
    try {
        // 核心逻辑 / Core logic
        await doWork();
    } catch (e) {
        // 记录错误 / Log error
        const errorMsg = `${new Date().toISOString()} | ${e.message}`;
        const logs = $prefs.valueForKey("error_logs") || "";
        $prefs.setValueForKey(logs + "\n" + errorMsg, "error_logs");
        
        // 通知 / Notify
        $notify("❌ 任务异常", "", e.message);
    }
    $done();
}
```

---

## 注意事项 (Notes)

1. **Task 频率限制** — iOS 系统可能限制后台执行频率，过于频繁的 cron 不会严格执行
2. **脚本执行时限** — 约 30 秒，超时强制终止
3. **`$done()` 必须** — 所有脚本最终都必须调用 `$done()`
4. **权限** — `$persistentStore` 等需在 QuanX 设置中开启
5. **网络权限** — Task 中 `$task.fetch()` 会走分流规则，可能需要代理
6. **后台运行** — Task 在后台执行，不在界面显示
7. **通知限制** — `$notify()` 每天有数量限制，频繁调用可能被忽略