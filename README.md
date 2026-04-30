# QuanX Master

> Quantumult X 全能大师 — 精通 QuanX 配置编写的 AI Skill

## 简介

QuanX Master 是一个 AI Skill，专门用于帮助用户创建、修改、调试、优化 Quantumult X 的各类配置和脚本。它深度掌握 QuanX 的每一个配置段落、每一个 API 细节、每一个最佳实践，可以辅助你从零搭建完整配置，或解决各种疑难杂症。

## 功能覆盖

| 能力领域 | 涵盖内容 |
|---|---|
| **配置结构** | `[general]`, `[dns]`, `[policy]`, `[server_remote/local]`, `[filter_remote/local]`, `[rewrite_remote/local]`, `[task_local/remote]`, `[mitm]`, `[http_backend]` |
| **分流规则** | HOST / HOST-SUFFIX / HOST-KEYWORD / USER-AGENT / IP-CIDR / GEOIP / DOMAIN / URL-REGEX / AND / OR / NOT / FINAL |
| **重写规则** | reject / reject-img / reject-dict / reject-array / http-request / http-response / 302 / 307 / script-request-body / script-response-body |
| **JS 脚本** | `$request` / `$response` / `$done()` / `$notify()` / `$prefs` / `$persistentStore` / `$task.fetch()` / Task 脚本 / 签到脚本 / 响应修改 |
| **策略组** | static / available / round-robin / url-latency-benchmark / ssid |
| **定时任务** | event-interaction / event-network / cron 表达式 |
| **DNS 配置** | server / DoH / no-ipv6 / address (本地映射) |
| **MitM** | 证书安装 / hostname 配置 / 排查证书问题 |

## 参考文档 (References)

Skill 运行时可以查阅以下参考文档以确保准确性：

- `references/filter-api.md` — 分流规则 API（匹配类型、语法、远程订阅参数）
- `references/rewrite-api.md` — 重写规则 API（响应修改、请求修改、拦截类型）
- `references/scripting-api.md` — JS 脚本 API（$request/$response/$done/$notify/$task）
- `references/task-api.md` — 定时任务 API（cron、事件类型、参数传递）
- `references/dns-policy.md` — DNS & 策略配置（DNS、策略组、服务器配置）
- `references/sample-config.md` — 完整配置文件模板

## 适用场景

- 编写或修改 Quantumult X 配置文件
- 创建去广告规则、VIP 解锁脚本
- 编写签到/任务 JS 脚本
- 配置分流策略组和路由规则
- 调试 Rewrite 不生效或脚本报错
- 优化配置性能
- 从零搭建完整的 QuanX 配置
- 理解或转换 Surge/Loon/Stash 规则

## 文件结构

```
quanxmaster/
├── SKILL.md                    # Skill 定义文件（核心指令与行为规范）
├── README.md                   # 项目说明文档
└── references/                 # 参考知识库
    ├── filter-api.md           # 分流规则 API 参考
    ├── rewrite-api.md          # 重写规则 API 参考
    ├── scripting-api.md        # JS 脚本 API 参考
    ├── task-api.md             # 定时任务 API 参考
    ├── dns-policy.md           # DNS & 策略配置参考
    └── sample-config.md        # 完整配置模板
```

## 许可证

MIT License