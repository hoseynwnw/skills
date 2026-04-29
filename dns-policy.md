# Quantumult X DNS & 策略组参考 (DNS & Policy Group Reference)

> DNS 配置和策略组路由是 QuanX 的核心功能，决定了流量的走向。
> DNS configuration and policy group routing are core features of QuanX, determining traffic direction.

---

## 一、DNS 配置 (DNS Configuration)

### 基本配置 (Basic Config)

```ini
[dns]
# DNS 服务器 (逗号分隔多个)
server = 223.5.5.5, 119.29.29.29, 1.1.1.1

# 使用系统 DNS (获取方式: 系统设置 → Wi-Fi → DNS)
# Use system DNS (Obtain from: System Settings → Wi-Fi → DNS)
server = system

# 自定义端口 / Custom port
server = 223.5.5.5:853, 119.29.29.29:853

# 禁用 IPv6 / Disable IPv6
no-ipv6 = true

# 本地DNS映射 / Local DNS mapping
address = /example.com/192.168.1.100
address = /internal.local/10.0.0.1
```

| 参数 (Param) | 说明 (Description) |
|---|---|
| `server` | DNS 服务器地址(逗号分隔)，默认端口 53 |
| `no-ipv6` | `true` = 禁用 IPv6 域名解析 |
| `address` | 本地 DNS 映射 (hostname → IP) |
| `server = system` | 使用系统Wi-Fi DNS |

---

### DNS 策略组 (DNS Policy Group)

```ini
[dns]
# 常规 DNS / Regular DNS
server = 223.5.5.5, 119.29.29.29

# 特定策略使用专属 DNS / Policy-specific DNS
[policy]
static=direct, DIRECT, direct, img-url=https://example.com/direct.png
static=China, DIRECT, direct, server=223.5.5.5

# 不同策略用不同 DNS / Different DNS per policy
static=Proxy, PROXY, proxy, server=8.8.8.8
static=Japan, PROXY, proxy, server=1.1.1.1
```

---

### DNS over HTTPS (DoH)

```ini
[dns]
# DoH 支持 / DoH support
server = https://dns.alidns.com/dns-query
server = https://doh.pub/dns-query
server = https://cloudflare-dns.com/dns-query
```

| DoH 提供商 | URL |
|---|---|
| 阿里 DNS (Ali) | `https://dns.alidns.com/dns-query` |
| 腾讯 DNS (DNSPod) | `https://doh.pub/dns-query` |
| Cloudflare | `https://cloudflare-dns.com/dns-query` |
| Google DNS | `https://dns.google/dns-query` |
| 360 DNS | `https://doh.360.cn/dns-query` |

---

### DNS 验证 (Server Check URL)

```ini
[server_local]
# 自定义服务器检测 URL / Custom server check URL
shadowsocks=ss.example.com:8388, method=chacha20-ietf-poly1305, password=pass123, server_check_url=http://www.gstatic.com/generate_204, tag=🔐 SSR
```

每个服务器可独立配置 `server_check_url`；不配置则使用全局 `server_check_url`。

---

## 二、策略组 (Policy Groups)

### 概述 (Overview)

策略组决定了流量的最终走向。例如：自动选择最快的代理、手动切换节点、直连等。

```
[policy]
# 格式 / Format:
<type>=<group-name>, <default-policy>, <sub-policies>, <options>

# 示例 / Example:
static=🚀 代理, PROXY, proxy-A, proxy-B, proxy-C, img-url=https://example.com/icon.png
```

---

### 策略组类型 (Policy Group Types)

#### 1. static — 静态策略 (Static Policy)

**手动选择**，用户需手动切换节点。

```ini
static=🚀 代理, PROXY, proxy-A, proxy-B, proxy-C
static=📺 媒体, DIRECT, proxy-media, DIRECT
static=🤖 AI服务, PROXY, proxy-openai, proxy-gemini
```

| 参数 | 说明 |
|---|---|
| `static` | 类型 |
| `🚀 代理` | 策略组名称 (显示名) |
| `PROXY` | 默认策略 |
| `proxy-A, proxy-B, proxy-C` | 可选子策略列表 |

---

#### 2. available — 可用性策略 (Availability)

**按列表顺序**连接，第一个可用的节点被选中。

```ini
available=🔗 自动, PROXY, proxy-A, proxy-B, proxy-C, DIRECT
```

> 依次尝试 proxy-A → proxy-B → proxy-C → DIRECT，使用第一个可用的

---

#### 3. round-robin — 轮询策略 (Round Robin)

**轮流使用**列表中的节点，实现负载均衡。

```ini
round-robin=⚖️ 负载均衡, PROXY, proxy-A, proxy-B, proxy-C
```

---

#### 4. url-latency-benchmark — 延迟优选 (Latency Benchmark)

**自动测试延迟**，选择延迟最低的节点。

```ini
url-latency-benchmark=🚀 自动测速, PROXY, proxy-A, proxy-B, proxy-C, url=http://www.gstatic.com/generate_204, interval=600
```

| 参数 | 说明 (Description) |
|---|---|
| `url=` | 测速 URL / Benchmark URL |
| `interval=` | 测速间隔（秒）/ Benchmark interval (seconds) |
| `tolerance=` | 容忍度(ms)，0=严格最低 / Tolerance, 0=strict lowest |

---

#### 5. ssid — Wi-Fi 策略 (SSID-based Policy)

根据**当前连接的 Wi-Fi** 自动选择策略。

```ini
ssid=🏠 家宽模式, DIRECT, policy-A, policy-B, default=PROXY, cellular=PROXY, ssid=MyHomeWiFi
```

| 参数 | 说明 |
|---|---|
| `default=` | 不匹配时的默认策略 |
| `cellular=` | 蜂窝网络时的策略 |
| `ssid=` | 匹配的 Wi-Fi 名称 |

---

### 策略组选项 (Group Options)

| 选项 (Option) | 说明 (Description) | 示例 (Example) |
|---|---|---|
| `img-url=` | 策略组图标 / Group icon URL | `img-url=https://example.com/icon.png` |
| `server=` | 专属 DNS / Policy-specific DNS | `server=8.8.8.8` |
| `url=` | 测速 URL (仅 latency-benchmark) | `url=http://www.gstatic.com/generate_204` |
| `interval=` | 测速间隔 (仅 latency-benchmark) | `interval=300` |
| `tolerance=` | 容忍度 ms (仅 latency-benchmark) | `tolerance=50` |
| `no-alert=` | `true` 禁用测速通知 | `no-alert=true` |
| `persistent=` | `true` 持久化选择 | `persistent=true` |

---

## 三、服务器配置 (Server Configuration)

### 本地服务器 (Local Server)

```ini
[server_local]
# Shadowsocks / SSR
shadowsocks=ss.example.com:8388, method=chacha20-ietf-poly1305, password=pass123, tag=🔐 SSR-东京

# V2Ray / VMess
vmess=vmess.example.com:443, username=user-id, ws=true, tls=true, ws-path=/path, tag=🛡️ VMess-WS-TLS

# Trojan
trojan=trojan.example.com:443, password=pass123, tls-host=example.com, tag=🐴 Trojan

# HTTP/HTTPS 代理
http=http.example.com:8080, username=user, password=pass, tag=🌐 HTTP代理

# Socks5
socks5=socks5.example.com:1080, tag=🧦 Socks5
```

### 远程订阅 (Remote Subscription)

```ini
[server_remote]
# 格式: <url>, tag=<名称>, <options>
https://sub.example.com/link/xxxx, tag=🚀 机场订阅, update-interval=86400, enabled=true
https://sub2.example.com/link/yyyy, tag=🎯 备用订阅, update-interval=43200, enabled=true, opt-parser=true
```

| 选项 | 说明 |
|---|---|
| `tag=` | 显示名称 |
| `update-interval=` | 更新间隔秒数 |
| `enabled=` | `true`/`false` |
| `opt-parser=` | `true` 使用优化解析器 |
| `filter=` | 过滤节点关键词 (regex) |
| `exclude=` | 排除节点关键词 (regex) |

---

## 四、完整策略示例 (Complete Policy Example)

```ini
[policy]
# 静态选择 / Static selection
static=🚀 代理选择, PROXY, proxy-A, proxy-B, proxy-C, img-url=https://raw.githubusercontent.com/icons/proxy.png

# 自动测速选择 / Auto speed test
url-latency-benchmark=⚡ 自动最快, PROXY, proxy-A, proxy-B, proxy-C, DIRECT, url=http://www.gstatic.com/generate_204, interval=600, tolerance=100

# 国内直连 / China direct
static=🇨🇳 国内, DIRECT, DIRECT, img-url=https://raw.githubusercontent.com/icons/cn.png

# 媒体服务 / Media services
static=📺 流媒体, PROXY, proxy-A, proxy-B, DIRECT, img-url=https://raw.githubusercontent.com/icons/media.png

# 苹果服务 / Apple services
static=🍎 Apple, DIRECT, DIRECT, PROXY, img-url=https://raw.githubusercontent.com/icons/apple.png

# 广告拦截 / Ad block
static=🚫 广告, REJECT, REJECT, img-url=https://raw.githubusercontent.com/icons/ad.png

# 可用性自动 / Availability auto
available=🔗 可用切换, DIRECT, proxy-A, proxy-B, DIRECT, img-url=https://raw.githubusercontent.com/icons/auto.png

# Wi-Fi匹配 / Wi-Fi match
ssid=🏠 家宽, DIRECT, PROXY, default=PROXY, cellular=PROXY, ssid=MyHomeWiFi, img-url=https://raw.githubusercontent.com/icons/home.png
```

---

## 五、网络设置 (Network Settings)

```ini
[general]
# 按需求连接 (按需开启 VPN)
ssid_suspended_list = MyHomeWiFi, OfficeWiFi

# 绕过证书验证 (调试用，不建议常开)
skip_cert_verify = false

# 绕过代理 (特定IP不走代理)
bypass_system = true

# TUN 接口排除路由 (0.0.0.0/31 保持直连)
excluded_routes = 0.0.0.0/31

# 代理通过接口
proxy_via_interface = utun2

# HTTP 后端代理端口
http_backend_proxy_port = 0

# DNS 排除列表 (不通过 QuanX DNS)
dns_exclusion_list = *.local, *.lan, 192.168.*, 10.*
```

---

## 注意事项 (Notes)

1. **策略组顺序无关** — 但 Filter 规则分流到策略组时才决定顺序
2. **节点命名** — 使用易识别的标签（如 `🇯🇵 日本-01`、`🇺🇸 美国-02`）
3. **测速频率** — 过于频繁测速会耗电，建议 600 秒以上
4. **DNS 泄露** — 务必配置 `no-ipv6=true` 防止 IPv6 DNS 泄露
5. **服务器检查** — `server_check_url` 用国内可访问的 URL（如百度 `http://www.baidu.com`）
6. **ssid_suspended_list** — 直连 Wi-Fi 下可暂停 VPN，省电