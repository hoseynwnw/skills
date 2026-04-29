# Quantumult X Filter 分流规则参考 (Filter Rules Reference)

> Filter 规则用于将网络请求分流到不同的策略组（如直连、代理、拒绝）。
> Filter rules are used to route network requests to different policy groups (e.g., direct, proxy, reject).

---

## 规则语法 (Rule Syntax)

```
<type>, <pattern>, <policy>
```

| 参数 (Parameter) | 说明 (Description) |
|---|---|
| `type` | 匹配类型 (Match type) |
| `pattern` | 匹配模式 (Match pattern) |
| `policy` | 策略组名称 (Policy group name) |

---

## 匹配类型详解 (Match Types)

### 1. HOST — 精确主机名匹配 (Exact Hostname)

匹配完全相同的域名。

```ini
# 精确匹配单个域名 / Exact match for single domain
HOST, example.com, PROXY

# 精确匹配 / Exact match
HOST, api.example.com, DIRECT
```

---

### 2. HOST-SUFFIX — 域名后缀匹配 (Hostname Suffix)

匹配域名及所有子域名。

```ini
# 匹配 example.com 及其所有子域名 / Match example.com and all subdomains
HOST-SUFFIX, example.com, PROXY

# 最常用类型 / Most commonly used type
HOST-SUFFIX, google.com, PROXY
HOST-SUFFIX, apple.com, DIRECT
```

---

### 3. HOST-KEYWORD — 域名关键词匹配 (Hostname Keyword)

域名中包含指定关键词即匹配。

```ini
# 包含关键词 / Contains keyword
HOST-KEYWORD, google, PROXY
# 匹配: google.com, googlevideo.com, googleapis.com 等
```

---

### 4. USER-AGENT — 用户代理匹配 (User Agent Match)

通过请求中的 User-Agent 字段匹配。**优先级低于 HOST 系列规则。**

```ini
# UA 包含指定字符串 / UA contains specified string
USER-AGENT, WeChat*, PROXY
USER-AGENT, TikTok*, PROXY
USER-AGENT, Microsoft*, DIRECT
```

**通配符 (Wildcards):**

| 通配符 | 意义 | 示例 |
|---|---|---|
| `*` | 匹配任意字符 | `WeChat*` 匹配 `WeChat/8.0` |
| `?` | 匹配单个字符 | `iOS?` 匹配 `iOS9` |

---

### 5. IP-CIDR — IP 段匹配 (IP CIDR Match)

```ini
# IPv4 CIDR
IP-CIDR, 10.0.0.0/8, DIRECT
IP-CIDR, 192.168.1.0/24, DIRECT

# IPv6 CIDR
IP-CIDR, fe80::/10, DIRECT
IP-CIDR, 2001:db8::/32, PROXY
```

---

### 6. IP-ASN — ASN 号匹配 (AS Number Match)

```ini
# ASN 匹配 / AS Number match
IP-ASN, 45102, DIRECT    # Alibaba
IP-ASN, 132203, PROXY    # Tencent Cloud
```

---

### 7. GEOIP — 地理位置匹配 (GeoIP Match)

```ini
# 按国家/地区路由 / Route by country
GEOIP, CN, DIRECT        # 中国直连
GEOIP, US, PROXY         # 美国代理
GEOIP, JP, JP-Proxy      # 日本走日本节点
```

**内置 GeoIP 数据库 (Built-in GeoIP Database):**

| 代码 (Code) | 地区 (Region) |
|---|---|
| CN | 中国 (China) |
| US | 美国 (United States) |
| JP | 日本 (Japan) |
| HK | 香港 (Hong Kong) |
| TW | 台湾 (Taiwan) |
| SG | 新加坡 (Singapore) |
| GB | 英国 (United Kingdom) |
| DE | 德国 (Germany) |
| FR | 法国 (France) |
| KR | 韩国 (South Korea) |

完整列表参考 MaxMind GeoLite2 数据库。

---

### 8. IP6-CIDR — IPv6 段匹配 (IPv6 CIDR Match)

```ini
# IPv6 CIDR
IP6-CIDR, 2400:3200::/32, DIRECT    # 阿里云 IPv6
IP6-CIDR, 2408:4000::/32, DIRECT    # 腾讯云 IPv6
```

---

### 9. DST-PORT — 目标端口匹配 (Destination Port)

```ini
# 端口匹配 / Port match
DST-PORT, 80, DIRECT
DST-PORT, 443, PROXY
DST-PORT, 8080, DIRECT
```

---

### 10. DOMAIN — 域名匹配 (Domain Match)

与 HOST 相同，精确域名匹配。

```ini
DOMAIN, api.example.com, PROXY
```

---

### 11. DOMAIN-SUFFIX — 域名后缀 (Domain Suffix)

与 HOST-SUFFIX 相同。

```ini
DOMAIN-SUFFIX, google.com, PROXY
```

---

### 12. DOMAIN-KEYWORD — 域名关键词 (Domain Keyword)

与 HOST-KEYWORD 相同。

```ini
DOMAIN-KEYWORD, apple, DIRECT
```

---

### 13. URL-REGEX — URL 正则匹配 (URL Regex)

```ini
# URL 正则匹配 (较耗性能) / URL regex match (less performant)
URL-REGEX, ^https?://[\w-]+\.example\.com/api, PROXY
URL-REGEX, ^https?://.*\.douban\.com/.*, DIRECT
```

---

### 14. AND / OR / NOT — 逻辑规则 (Logical Rules)

```ini
# AND — 同时满足多个条件
AND, ((DOMAIN, example.com), (DST-PORT, 443)), PROXY

# OR — 满足任一条件
OR, ((DOMAIN, a.com), (DOMAIN, b.com)), PROXY

# NOT — 不满足条件
NOT, ((DOMAIN-SUFFIX, cn)), PROXY
```

---

### 15. FINAL — 最终规则 (Final Rule)

**必须放在最后**，匹配所有未被之前规则处理的内容。

```ini
# 默认策略 / Default policy
FINAL, PROXY

# 使用策略组 / Use policy group
FINAL, 🚀 代理
```

---

## 规则匹配优先级 (Rule Priority)

规则按**从上到下**的顺序匹配，**第一个匹配的规则生效**。

```ini
[filter_local]
# 1. 先匹配特定规则 / Specific rules first
HOST, special.example.com, DIRECT
IP-CIDR, 10.0.0.0/8, DIRECT

# 2. 再匹配域名后缀 / Then suffix rules
HOST-SUFFIX, google.com, PROXY
HOST-SUFFIX, apple.com, DIRECT

# 3. 关键词匹配 / Keyword rules
HOST-KEYWORD, ad, REJECT

# 4. GEOIP 匹配 / GeoIP rules
GEOIP, CN, DIRECT

# 5. 🔑 最终兜底规则 (必须) / Final fallback rule (required)
FINAL, PROXY
```

---

## 策略参数 (Policy Targets)

| 策略值 (Policy Value) | 说明 (Description) |
|---|---|
| `DIRECT` | 直连 (Direct connection) |
| `REJECT` | 拒绝连接 (Reject connection) |
| `REJECT-TINYGIF` | 返回 1px 透明图 (Return transparent GIF) |
| `REJECT-DROP` | 静默丢弃 (Silent drop) |
| `PROXY` | 走代理策略组 (Use proxy group) |
| `<自定义策略组名>` | 如 `🚀 代理`, `📺 媒体`, `🇯🇵 日本` |

---

## 远程规则订阅 (Remote Rule Subscription)

```ini
[filter_remote]
# 格式: <url>, tag=<名称>, force-policy=<策略>, update-interval=<秒>
https://raw.githubusercontent.com/user/rules/main/ad.txt, tag=🚫 广告, force-policy=REJECT, update-interval=86400
https://raw.githubusercontent.com/user/rules/main/cn.txt, tag=🇨🇳 国内, force-policy=DIRECT, update-interval=86400
https://raw.githubusercontent.com/user/rules/main/apple.txt, tag=🍎 Apple, force-policy=DIRECT, update-interval=604800
```

| 参数 (Param) | 说明 (Description) |
|---|---|
| `url` | 规则文件 URL (支持 .list / .txt) |
| `tag=` | 显示标签 |
| `force-policy=` | 强制指定策略（覆盖文件内的策略） |
| `update-interval=` | 更新间隔（秒），0=每次启动更新 |
| `enabled=` | `true`/`false` 是否启用 |
| `resource-parser=` | 资源解析器 URL（可选） |

---

## 本地规则文件格式 (Local Rule File Format)

### .list 格式

```
# 注释 / Comment
DOMAIN-SUFFIX, google.com
DOMAIN-SUFFIX, youtube.com
IP-CIDR, 35.190.0.0/16
```

### .txt 格式

```ini
# 标准 Surge 格式 / Standard Surge format
DOMAIN-SUFFIX,google.com,PROXY
DOMAIN-SUFFIX,youtube.com,PROXY
```

---

## 性能优化建议 (Performance Tips)

1. **FINAL 必须在最后** — 否则所有后续规则无效
2. **精确匹配优先** — HOST 比 HOST-SUFFIX 快
3. **减少正则** — URL-REGEX 性能开销大
4. **远程规则控制数量** — 避免加载过多外部规则
5. **合理排序** — 高频命中的规则放在前面
6. **REJECT 放前** — 广告屏蔽规则前置可减少后续匹配

---

## 常见分流方案 (Common Routing Schemes)

### 方案 1: 白名单模式 (Whitelist Mode)

```ini
# 国内直连 / China direct
GEOIP, CN, DIRECT
HOST-SUFFIX, apple.com, DIRECT
HOST-SUFFIX, icloud.com, DIRECT

# 广告拒绝 / Ad reject
HOST-SUFFIX, doubleclick.net, REJECT

# 其余代理 / Rest proxy
FINAL, PROXY
```

### 方案 2: 黑名单模式 (Blacklist Mode)

```ini
# 已知需要代理的 / Known proxy-needed
HOST-SUFFIX, google.com, PROXY
HOST-SUFFIX, youtube.com, PROXY
HOST-SUFFIX, twitter.com, PROXY
HOST-SUFFIX, facebook.com, PROXY

# 广告拒绝 / Ad reject
HOST-SUFFIX, doubleclick.net, REJECT

# 其余直连 / Rest direct
FINAL, DIRECT
```

### 方案 3: 混合模式 (Hybrid Mode)

```ini
# 国内域名直连 / China domains direct
HOST-SUFFIX, cn, DIRECT
HOST-SUFFIX, baidu.com, DIRECT
HOST-SUFFIX, qq.com, DIRECT
HOST-SUFFIX, weixin.qq.com, DIRECT

# 苹果服务 / Apple services
HOST-SUFFIX, apple.com, DIRECT
HOST-SUFFIX, icloud.com, DIRECT
HOST-SUFFIX, mzstatic.com, DIRECT

# 广告屏蔽 / Ad blocking
HOST-SUFFIX, doubleclick.net, REJECT
HOST-SUFFIX, googlesyndication.com, REJECT

# GEOIP 辅助 / GeoIP辅助
GEOIP, CN, DIRECT
GEOIP, US, PROXY
GEOIP, JP, 🇯🇵 日本

# 局域网 / LAN
IP-CIDR, 10.0.0.0/8, DIRECT
IP-CIDR, 127.0.0.0/8, DIRECT
IP-CIDR, 172.16.0.0/12, DIRECT
IP-CIDR, 192.168.0.0/16, DIRECT

# 兜底 / Fallback
FINAL, 🚀 代理