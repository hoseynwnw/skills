---
name: mitmproxy-setup
description: >
  完整的 Android HTTPS 流量捕获编排器。触发：抓包、HTTPS 解密、mitmproxy、
  Frida 注入、Clash 路由、抓取 XX 流量。涵盖 4 阶段全流程：环境准备 → 
  Clash TUN 路由 → Frida 注入 → mitmdump 抓取。自动处理证书安装、
  SELinux 绕过、Clash TUN 配置、Frida 脚本注入、SSL pinning 绕过。
  适用于 Android 16 + Magisk Root + Shizuku 环境。
version: 2.0.0
---

# mitmproxy-setup — Android HTTPS 流量捕获完整编排器

## 触发条件

当用户要求"抓包"、"HTTPS 解密"、"分析 XX App 流量"、"用 mitmproxy"时触发。

## 四阶段流程

### Phase 1: 环境准备
```bash
bash scripts/setup-env.sh
```
- 安装 mitmproxy (pip install mitmproxy)
- 推送证书到 Android 系统信任区
- 配置 ADB/Shizuku 连接

### Phase 2: Clash TUN 路由
```bash
bash scripts/route-clash.sh <目标App包名>
```
- 配置 Clash Meta TUN 模式
- 设置 HTTP 代理指向 mitmdump (127.0.0.1:8080)
- 设置 HTTPS 代理指向 mitmdump (127.0.0.1:8080)
- 通过 iptables 或路由表强制 App 流量走代理

### Phase 3: Frida 注入 (SSL Pinning Bypass)
```bash
bash scripts/inject-frida.sh <目标App包名>
```
- 推送 Frida Server 到 `/data/local/tmp/`
- 启动 frida-server (root 权限)
- 注入 SSL pinning bypass 脚本
- 确认注入成功

### Phase 4: mitmdump 抓取
```bash
mitmdump -w flows.mitm --ssl-insecure
```

### 读取抓取结果
```bash
python3 scripts/read-flows.py flows.mitm
```

## 故障排查矩阵

| 症状 | 原因 | 解决 |
|------|------|------|
| App 无法联网 | Clash TUN 路由未生效 | 检查 Clash 是否运行，iptables 规则 |
| HTTPS 请求失败 | 证书未信任 | 重新运行 setup-env.sh |
| SSL pinning 错误 | Frida 未注入 | 检查 frida-server 进程 |
| 抓包无流量 | 代理未配置 | 确认 settings global http_proxy |
| Connection Refused | mitmdump 未启动 | 确认 8080 端口监听 |
