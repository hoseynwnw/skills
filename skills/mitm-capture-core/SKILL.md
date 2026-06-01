---
name: mitm-capture-core
description: >
  Core mitmproxy HTTPS capture workflow for Android 16 devices. Starts/stops
  mitmdump with Clash TUN upstream proxy, dynamically switches capture targets
  via Clash rule providers, reads and analyzes captured traffic with Python
  FlowReader, and provides SSL pinning bypass fallbacks (Frida injection +
  eBPF eCapture). Trigger this skill whenever the user mentions capturing App
  traffic, mitmproxy, mitmdump, HTTPS decryption, SSL bypass, packet capture,
  or analyzing network flows — even if they say "grab traffic", "sniff", or
  "intercept requests".
  Android 16 设备上的 mitmproxy HTTPS 抓包核心工作流。通过 Clash TUN 上游代理
  启停 mitmdump，动态切换抓包目标，用 Python FlowReader 读取分析流量，并提供
  Frida 注入和 eBPF eCapture 两种 SSL 证书锁定绕过方案。当用户提到抓 App 流量、
  mitmproxy、mitmdump、HTTPS 解密、SSL 绕过、抓包、分析网络请求时触发 — 即使
  只说"抓一下"、"嗅探"、"拦截请求"也要触发。
compatibility: Android 16, Clash Meta, mitmproxy, Frida, Alpine Linux aarch64 (PRoot)
---

# mitmproxy 核心抓包操作

日常 HTTPS 流量抓取的完整工作流：启动 mitmdump、切换抓包目标、分析流量、停止恢复。包含证书锁定绕过的备选方案（Frida / eBPF）。

## Agent 执行规范

1. **严格原样执行**：Shell 代码块中的复杂变量转义（如 `\$CLASH_OWNER`）绝不能修改或吞掉反斜杠，必须 100% 复制执行。
2. **必须校验状态**：执行任何后台启动命令（包含 `&`）后，必须校验进程是否存活。如果进程不存在，停止后续流程并向用户报错。
3. **用户引导边界**：涉及 LSPosed 模块勾选、Clash VPN 开关重启的操作，必须在回答中明确提示用户手动完成。
4. **清理优先**：在启动任何抓包之前，必须先执行「停止与恢复」的命令，确保无僵尸进程。

## 设备基线

| 项目 | 值 |
|---|---|
| 设备 | Google Pixel 9a (tegu) / Android 16 |
| 沙盒 | Alpine Linux aarch64 (PRoot) |
| 代理核心 | Clash Meta（TUN 模式） |
| UUID | `3278a573-6f61-437b-94a9-2a2c63d25660` |

---

## 一、停止与清理（每次抓包前必须执行）

在启动任何抓包之前，先清理僵尸进程和残留规则。

```bash
# 1. 停止 mitmproxy 进程
android-shizuku-cli exec "pkill -f mitmdump" 2>/dev/null

# 2. 清理系统代理和 iptables
android-shizuku-cli exec "settings put global http_proxy :0; iptables -t nat -F OUTPUT" 2>/dev/null

# 3. 注释掉 Clash 规则（恢复正常直连）
CLASH_DIR=/data/data/com.github.metacubex.clash.meta/files
UUID=3278a573-6f61-437b-94a9-2a2c63d25660

android-shizuku-cli exec "
CLASH_OWNER=\$(stat -c %U $CLASH_DIR)
printf 'payload:\n  # - PROCESS-NAME,disabled\n' \
  > $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
  && cp $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chown \$CLASH_OWNER:\$CLASH_OWNER \
        $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chmod 644 $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
             $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && echo 'CLEANUP_SUCCESS'
"
```

---

## 二、启动抓包

### 2.1 拉起 mitmdump

采用上游代理模式启动，确保流量可通过 Clash HTTP 代理出站，避免 GFW 墙阻断。

```bash
# 1. 强杀旧进程，防止端口冲突
android-shizuku-cli exec "pkill -f mitmdump" 2>/dev/null; sleep 1

# 2. 拉起 mitmdump
mitmdump --mode upstream:http://127.0.0.1:7890 -p 8080 --set block_global=false --set flow_detail=3 -w /tmp/flows > /tmp/mitm.log 2>&1 &
sleep 2

# 3. 校验服务状态（必须检查此输出）
ps aux | grep [m]itmdump || echo "ERROR: mitmdump failed to start"
```

### 2.2 下发路由规则

将目标 App 的包名注入 Clash 规则 Provider，引导其流量进入沙盒。将 `<目标APP包名>` 替换为实际包名（如 `com.hexin.plat.android`）。

```bash
CLASH_DIR=/data/data/com.github.metacubex.clash.meta/files
UUID=3278a573-6f61-437b-94a9-2a2c63d25660
TARGET_PKG="<目标APP包名>"

android-shizuku-cli exec "
CLASH_OWNER=\$(stat -c %U $CLASH_DIR)
printf 'payload:\n  - PROCESS-NAME,%s\n' \"\$TARGET_PKG\" \
  > $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
  && cp $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chown \$CLASH_OWNER:\$CLASH_OWNER \
        $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chmod 644 $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
             $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && echo 'RULE_UPDATE_SUCCESS'
"
```

**提示用户**：路由规则已下发。Clash 通常会自动重载，如果目标 App 无网络，请在 Clash App 中手动关闭并重新开启一次 VPN。

---

## 三、读取与分析流量

读取 `/tmp/flows` 文件前，确保当前没有写入该文件的 mitmdump 进程正在运行，否则端口冲突。使用 Python FlowReader 无损读取，避免占用 8080 端口。

```python
from mitmproxy.io import FlowReader
from mitmproxy.http import HTTPFlow

# 根据用户需求修改匹配逻辑
target_keyword = "api"
with open("/tmp/flows", "rb") as f:
    for flow in FlowReader(f).stream():
        if not isinstance(flow, HTTPFlow):
            continue
        if target_keyword in flow.request.pretty_url:
            print(f"URL: {flow.request.pretty_url}")
            print(f"Response: {flow.response.content[:500] if flow.response else 'No Response'}\n")
```

---

## 四、证书锁定绕过（备选方案）

当标准 Clash TUN + mitmproxy 链路遇到 `Certificate verify failed` 错误时使用。

### 4.1 Frida 动态注入

前提：frida-server 已后台运行。使用 `setsid` 规避沙盒隔离，避免静默挂起。

```bash
# 1. 重启目标 App 获取 PID
android-shizuku-cli exec "am force-stop <目标包名>; monkey -p <目标包名> 1 >/dev/null 2>&1; sleep 3"
PID=$(android-shizuku-cli exec "ps -A | grep '<目标包名>$' | awk '{print \$2}' | head -1")

# 2. 注入绕过脚本
android-shizuku-cli exec "
setsid /data/local/tmp/frida-inject -p $PID -s /data/local/tmp/ssl_bypass.js -R v8 </dev/null >/data/local/tmp/frida.log 2>&1 &
sleep 4
"
```

需提前向 `/data/local/tmp/ssl_bypass.js` 写入基于 `Module.findExportByName` 的全局 Hook 脚本。

### 4.2 Ecapture eBPF uprobe（测试中）

针对高对抗 App。已知 Android 16 的 BoringSSL 结构体内存偏移量变化导致 v2.4.1 数据解析全零。若用户强行要求，仅支持以 text 模式尝试：

```bash
APP_LIBSSL=$(android-shizuku-cli exec "find /data/app -path '*<目标包名>*' -name 'libssl.so' 2>/dev/null | head -1")
SYSTEM_LIBSSL="/apex/com.android.conscrypt/lib64/libssl.so"
android-shizuku-cli exec "
setsid /data/local/tmp/ecapture tls -m text -b 1 --pid=<PID> \
  --libssl=${APP_LIBSSL:-$SYSTEM_LIBSSL} -l /data/local/tmp/ecap.log </dev/null >/data/local/tmp/ecap_out.log 2>&1 &
"
```

---

## 五、停止与环境恢复

当用户要求停止抓包、恢复网络或出现网络断流时，执行此块。

```bash
# 1. 停止 mitmproxy 进程
android-shizuku-cli exec "pkill -f mitmdump" 2>/dev/null

# 2. 清理系统代理和 iptables
android-shizuku-cli exec "settings put global http_proxy :0; iptables -t nat -F OUTPUT" 2>/dev/null

# 3. 注释掉 Clash 规则（恢复正常直连）
CLASH_DIR=/data/data/com.github.metacubex.clash.meta/files
UUID=3278a573-6f61-437b-94a9-2a2c63d25660

android-shizuku-cli exec "
CLASH_OWNER=\$(stat -c %U $CLASH_DIR)
printf 'payload:\n  # - PROCESS-NAME,disabled\n' \
  > $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
  && cp $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chown \$CLASH_OWNER:\$CLASH_OWNER \
        $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
        $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && chmod 644 $CLASH_DIR/imported/$UUID/providers/mitm-capture.yaml \
             $CLASH_DIR/processing/providers/mitm-capture.yaml \
  && echo 'CLEANUP_SUCCESS'
"
```

---

## 附录：Clash 配置架构（供人类调试参考）

Agent 忽略此段。核心原理：通过分离 `config.yaml`（主配置）和 `mitm-capture.yaml`（规则提供者），日常抓包仅需修改外部 Provider 即可动态重载，不受云端订阅更新干扰。

```
/data/data/com.github.metacubex.clash.meta/files/
└── imported/3278a573/
    ├── config.yaml              ← 主配置
    │   ├── proxies: {name: Local-Mitmproxy, type: http, server: 127.0.0.1, port: 8080}
    │   ├── rule-providers: mitm-capture: {type: file, behavior: classical, path: mitm-capture.yaml}
    │   └── rules:
    │         - PROCESS-NAME,mitmdump,DIRECT         ← 防循环路由
    │         - PROCESS-NAME,mitmweb,DIRECT          ← 防循环路由
    │         - RULE-SET,mitm-capture,Local-Mitmproxy
    └── providers/
        └── mitm-capture.yaml    ← Agent 动态修改
            └── payload: - PROCESS-NAME,<目标APP包名>
```

### 防循环为什么必要

如果不配置 `PROCESS-NAME,mitmdump,DIRECT`，mitmdump 向上游发送解密请求时，其出站流量会被 Clash TUN 再次接管并匹配到全局代理，重新发给 mitmdump 自身，导致循环请求耗尽资源引发 `502 Bad Gateway`。

---
