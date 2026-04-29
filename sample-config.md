# Quantumult X 完整配置模板 (Complete Configuration Template)

> 这是一个功能齐全的 QuanX 配置模板，包含所有主要段落的双语注释。
> This is a fully functional QuanX config template with bilingual comments for all major sections.

---

## 配置文件结构 (Config File Structure)

```
[general]          — 通用设置 / General Settings
[dns]              — DNS 配置 / DNS Configuration
[policy]           — 策略组定义 / Policy Group Definitions
[server_remote]    — 远程服务器订阅 / Remote Server Subscriptions
[server_local]     — 本地服务器 / Local Servers
[filter_remote]    — 远程分流规则 / Remote Filter Rules
[filter_local]     — 本地分流规则 / Local Filter Rules
[rewrite_remote]   — 远程重写规则 / Remote Rewrite Rules
[rewrite_local]    — 本地重写规则 / Local Rewrite Rules
[task_local]       — 本地定时任务 / Local Scheduled Tasks
[task_remote]      — 远程定时任务 / Remote Scheduled Tasks
[http_backend]     — HTTP 后端 (抓包) / HTTP Backend (packet capture)
[mitm]             — MitM 解密配置 / MitM Decryption Config
```

---

## [general] 通用设置 (General Settings)

```ini
[general]
# ▼▼▼ 网络设置 / Network Settings ▼▼▼

# 直连 Wi-Fi 下暂停 VPN (省电) / Suspend VPN on trusted Wi-Fi (save battery)
ssid_suspended_list = MyHomeWiFi, OfficeWiFi

# 跳过证书验证 (调试用，不建议常开) / Skip certificate verification (debug only)
skip_cert_verify = false

# 绕过系统代理 (让系统代理直连) / Bypass system proxy
bypass_system = true

# TUN 排除路由 (0.0.0.0/31 保持直连) / TUN excluded routes
excluded_routes = 0.0.0.0/31

# 代理接口 / Proxy interface
proxy_via_interface = utun2

# DNS 排除列表 / DNS exclusion list
dns_exclusion_list = *.local, *.lan, 192.168.*, 10.*

# ▼▼▼ 持久化设置 / Persistent Settings ▼▼▼

# 资源解析器 (用于解析远程资源的脚本URL) / Resource parser URL
resource_parser_url = https://raw.githubusercontent.com/KOP-XIAO/QuantumultX/master/Scripts/resource-parser.js

# ▼▼▼ GeoIP 数据库 / GeoIP Database ▼▼▼
geoip_checker_url = https://raw.githubusercontent.com/user/geoip/main/cn.dat

# 排除路由 / Exclude routes
always_reject_url_rewrite = false

# ▼▼▼ 始终开启 / Always On ▼▼▼
always_on_vpn = true

# ▼▼▼ HTTP 头部暴露 / HTTP Header Exposure ▼▼▼
show_http_request = false
```

---

## [dns] DNS 配置 (DNS Configuration)

```ini
[dns]
# DNS 服务器 (多个用逗号分隔) / DNS servers (comma-separated)
server = 223.5.5.5, 119.29.29.29, 1.1.1.1

# 或使用 DoH / Or use DNS over HTTPS
# server = https://dns.alidns.com/dns-query

# 禁用 IPv6 DNS 解析 (防止泄露) / Disable IPv6 DNS (prevent leaks)
no-ipv6 = true

# 本地 DNS 映射 / Local DNS mapping
# address = /local.service/192.168.1.100
```

---

## [policy] 策略组 (Policy Groups)

```ini
[policy]
# ▼▼▼ 代理策略 / Proxy Policy ▼▼▼

# 手动选择代理节点 / Manual proxy node selection
static=🚀 代理选择, PROXY, proxy-A, proxy-B, proxy-C, img-url=https://raw.githubusercontent.com/icons/proxy.png

# 自动测速选最快的节点 / Auto select fastest node
url-latency-benchmark=⚡ 自动最快, PROXY, proxy-A, proxy-B, proxy-C, DIRECT, url=http://www.gstatic.com/generate_204, interval=600, tolerance=100, img-url=https://raw.githubusercontent.com/icons/fast.png

# ▼▼▼ 国内直连 / China Direct ▼▼▼
static=🇨🇳 国内, DIRECT, DIRECT, img-url=https://raw.githubusercontent.com/icons/cn.png

# ▼▼▼ 媒体服务 / Media Services ▼▼▼
static=📺 流媒体, PROXY, proxy-A, proxy-B, DIRECT, img-url=https://raw.githubusercontent.com/icons/media.png
static=🎵 音乐, PROXY, proxy-A, DIRECT, img-url=https://raw.githubusercontent.com/icons/music.png

# ▼▼▼ Apple 服务 / Apple Services ▼▼▼
static=🍎 Apple, DIRECT, DIRECT, PROXY, img-url=https://raw.githubusercontent.com/icons/apple.png

# ▼▼▼ AI 服务 / AI Services ▼▼▼
static=🤖 AI服务, PROXY, proxy-openai, proxy-gemini, img-url=https://raw.githubusercontent.com/icons/ai.png

# ▼▼▼ 广告拦截 (直接 REJECT) / Ad Block (REJECT directly) ▼▼▼
static=🚫 广告拦截, REJECT, REJECT, img-url=https://raw.githubusercontent.com/icons/ad.png

# ▼▼▼ 游戏加速 / Gaming ▼▼▼
static=🎮 游戏, PROXY, proxy-game, DIRECT, img-url=https://raw.githubusercontent.com/icons/game.png

# ▼▼▼ 兜底策略 (供 FINAL 使用) / Fallback (for FINAL rule) ▼▼▼
static=🌍 兜底, PROXY, proxy-A, proxy-B, proxy-C, DIRECT, img-url=https://raw.githubusercontent.com/icons/world.png
```

---

## [server_remote] 远程订阅 (Remote Subscriptions)

```ini
[server_remote]
# 格式: <url>, tag=<名称>, update-interval=<秒>, enabled=<true|false>
# 机场订阅1 / Airport subscription 1
https://sub.example.com/link/abc123, tag=✈️ 主力机场, update-interval=86400, enabled=true

# 机场订阅2 (备用) / Airport subscription 2 (backup)
https://sub2.example.com/link/def456, tag=🛩️ 备用机场, update-interval=43200, enabled=false

# 开启优化解析器 / Enable optimized parser
# https://sub.example.com/link/xxx, tag=✈️ 机场, update-interval=86400, opt-parser=true

# 节点过滤 (只保留包含 HK/日本 的节点) / Node filter
# https://sub.example.com/link/xxx, tag=✈️ 亚洲, filter=HK|日本|新加坡|台湾
```

---

## [server_local] 本地服务器 (Local Servers)

```ini
[server_local]
# Shadowsocks 节点 / Shadowsocks node
# shadowsocks=ss.example.com:8388, method=chacha20-ietf-poly1305, password=p@ssw0rd, tag=🔐 SSR-东京, server_check_url=http://www.gstatic.com/generate_204

# VMess WebSocket + TLS 节点 / VMess WS+TLS node
# vmess=vm.example.com:443, username=00000000-0000-0000-0000-000000000000, ws=true, tls=true, ws-path=/path, tag=🛡️ VMess-WS, server_check_url=http://www.gstatic.com/generate_204

# Trojan 节点 / Trojan node
# trojan=tj.example.com:443, password=p@ssw0rd, tls-host=example.com, tag=🐴 Trojan, server_check_url=http://www.gstatic.com/generate_204
```

---

## [filter_remote] 远程分流规则 (Remote Filter Rules)

```ini
[filter_remote]
# ▼▼▼ 广告拦截 / Ad Blocking ▼▼▼
https://raw.githubusercontent.com/NobyDa/ND-AD/master/QuantumultX/AD_Block.txt, tag=🚫 去广告, force-policy=REJECT, update-interval=86400, enabled=true

# ▼▼▼ 国内流量直连 / China Traffic Direct ▼▼▼
https://raw.githubusercontent.com/NobyDa/ND-AD/master/QuantumultX/AD_Block_Plus.txt, tag=🇨🇳 国内直连, force-policy=DIRECT, update-interval=86400, enabled=true

# ▼▼▼ Apple 服务 / Apple Services ▼▼▼
https://raw.githubusercontent.com/NobyDa/ND-AD/master/QuantumultX/Apple.txt, tag=🍎 Apple服务, force-policy=🍎 Apple, update-interval=86400, enabled=true

# ▼▼▼ 国外代理 (GFW List) / Foreign Proxy (GFW List) ▼▼▼
https://raw.githubusercontent.com/user/rules/main/proxy.list, tag=🌐 国外代理, force-policy=🚀 代理选择, update-interval=86400, enabled=true
```

---

## [filter_local] 本地分流规则 (Local Filter Rules)

```ini
[filter_local]
# ===== 优先级最高 / Highest Priority =====

# 局域网直连 / LAN direct
IP-CIDR, 10.0.0.0/8, DIRECT
IP-CIDR, 127.0.0.0/8, DIRECT
IP-CIDR, 172.16.0.0/12, DIRECT
IP-CIDR, 192.168.0.0/16, DIRECT
IP-CIDR, 224.0.0.0/24, DIRECT

# ===== 特定需要代理的 / Specific Proxy =====
HOST-SUFFIX, google.com, 🚀 代理选择
HOST-SUFFIX, youtube.com, 📺 流媒体
HOST-SUFFIX, twitter.com, 🚀 代理选择
HOST-SUFFIX, facebook.com, 🚀 代理选择
HOST-SUFFIX, instagram.com, 🚀 代理选择
HOST-SUFFIX, openai.com, 🤖 AI服务
HOST-SUFFIX, chatgpt.com, 🤖 AI服务

# ===== 特定需要直连的 / Specific Direct =====
HOST-SUFFIX, cn, 🇨🇳 国内
HOST-SUFFIX, baidu.com, 🇨🇳 国内
HOST-SUFFIX, qq.com, 🇨🇳 国内
HOST-SUFFIX, weixin.qq.com, 🇨🇳 国内
HOST-SUFFIX, bilibili.com, 🇨🇳 国内

# ===== 苹果服务 / Apple Services =====
HOST-SUFFIX, apple.com, 🍎 Apple
HOST-SUFFIX, icloud.com, 🍎 Apple
HOST-SUFFIX, mzstatic.com, 🍎 Apple

# ===== GEOIP 兜底 / GeoIP Fallback =====
GEOIP, CN, 🇨🇳 国内
GEOIP, US, 🚀 代理选择

# ===== FINAL 必须放最后 / FINAL must be last =====
FINAL, 🌍 兜底
```

---

## [rewrite_remote] 远程重写规则 (Remote Rewrite Rules)

```ini
[rewrite_remote]
# 去广告重写 / Ad blocking rewrite
https://raw.githubusercontent.com/user/rewrites/main/ad-block.conf, tag=🚫 去广告重写, update-interval=86400, enabled=true

# VIP 解锁重写 / VIP unlock rewrite
https://raw.githubusercontent.com/user/rewrites/main/vip.conf, tag=👑 VIP 解锁, update-interval=86400, enabled=true
```

---

## [rewrite_local] 本地重写规则 (Local Rewrite Rules)

```ini
[rewrite_local]
# ===== 去广告 / Ad Blocking =====

# 拦截广告域名 / Block ad domains
^https?://[\w-]+\.doubleclick\.net/ - reject
^https?://[\w-]+\.googlesyndication\.com/ - reject

# ===== 响应修改 / Response Modification =====

# 修改 JSON 响应 (本地脚本) / Modify JSON response (local script)
^https?://api\.example\.com/vip/status - script-response-body vip_unlock.js

# 修改请求头 / Modify request header
^https?://api\.example\.com/ - request-header User-Agent Mozilla/5.0.*
```

---

## [task_local] 本地定时任务 (Local Tasks)

```ini
[task_local]
# 每日签到 / Daily check-in
event-interaction 0 8 * * *, tag=🪙 每日签到, script-path=https://raw.githubusercontent.com/user/tasks/main/signin.js, enabled=true

# 每30分钟更新 / Update every 30 minutes
event-interaction */30 * * * *, tag=📊 数据更新, script-path=update_data.js, enabled=true

# 网络变化检测 / Network change detection
event-network * * * * *, tag=📡 网络检测, script-path=network_change.js, enabled=false
```

---

## [task_remote] 远程定时任务 (Remote Tasks)

```ini
[task_remote]
https://raw.githubusercontent.com/user/tasks/main/tasks.json, tag=📋 远程任务集, update-interval=3600, enabled=true
```

---

## [http_backend] HTTP 抓包 (HTTP Packet Capture)

```ini
[http_backend]
# HTTP 后端代理端口 (0=关闭) / HTTP backend proxy port (0=off)
http_backend_proxy_port = 0

# 抓包记录 (开启后在日志中查看完整请求/响应) / Packet capture (view in logs)
# 开启后在 HTTP Analyzer 可查看 / Enable to view in HTTP Analyzer
```

---

## [mitm] MitM 解密配置 (MitM Decryption Config)

```ini
[mitm]
# 密码 / Certificate passphrase
passphrase = QuanX

# 证书密码 / Certificate p12 passphrase
p12passphrase = QuanX

# ▼▼▼ 需要解密的域名 / Domains to decrypt ▼▼▼
hostname = api.example.com, *.googleapis.com, *.apple.com, *.icloud.com
```

---

## 完整工作流 (Complete Workflow)

### 1. 安装证书 / Install Certificate
```
QuanX → 设置 → MitM → 安装证书 → 系统设置 → 描述文件 → 信任
```

### 2. 导入配置 / Import Config
```
QuanX → 设置 → 下载配置 → 粘贴URL/本地文件
```

### 3. 启动小火箭 / Start VPN
```
首页 → 开关 → 首次弹窗选"允许"
```

### 4. 调试 / Debug
```
底部 → 日志 (Log) → 查看请求/响应详情
底部 → HTTP Analyzer → 查看抓包内容
```

---

## 常见问题 (FAQ)

| 问题 (Issue) | 解决方案 (Solution) |
|---|---|
| Rewrite 不生效 | 检查域名是否在 `[mitm] hostname` 中 |
| 脚本报错 | 查看日志 (QuanX → 日志) |
| 分流不正确 | 检查规则顺序，确保 FINAL 最后 |
| 证书未信任 | 系统设置 → 通用 → 关于 → 证书信任设置 |
| 任务不执行 | iOS 后台限制，手动左滑触发测试 |
| 代理未生效 | 检查策略组节点是否在线 |