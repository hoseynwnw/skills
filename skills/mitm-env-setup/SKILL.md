---
name: mitm-env-setup
description: >
  Initialize the mitmproxy HTTPS capture environment on Android 16 / Magisk
  devices. Deploy the mitmproxy CA certificate via MoveCertificate to bypass
  Android 14+ read-only APEX restrictions, download Frida server/inject
  binaries for SSL pinning bypass, and scaffold the Clash Meta TUN capture
  skeleton configuration. Trigger this skill when the user mentions setting up
  a capture environment for the first time, initializing mitmproxy, deploying
  CA certificates, or installing Frida on Android — even if they say "setup
  environment", "install cert", or "first time mitm".
  在 Android 16 / Magisk 设备上初始化 mitmproxy HTTPS 抓包环境。通过
  MoveCertificate 部署 CA 证书绕过 Android 14+ 只读 APEX 限制，下载 Frida
  二进制文件用于 SSL 证书锁定绕过，搭建 Clash Meta TUN 抓包骨架配置。当用户
  提到首次搭建抓包环境、初始化 mitmproxy、部署 CA 证书、安装 Frida 时触发 —
  即使只说"搭建环境"、"装证书"、"第一次抓包"也要触发。
compatibility: Android 16, Magisk, Alpine Linux aarch64 (PRoot), MoveCertificate v1.5.7+
---

# mitmproxy 环境初始化

在 Android 16 / Minis 沙盒环境中完成一次性抓包环境部署。此 skill 仅在首次初始化时执行一次。

## 设备基线

| 项目 | 值 |
|---|---|
| 设备 | Google Pixel 9a (tegu) / Android 16 |
| 沙盒 | Alpine Linux aarch64 (PRoot) |
| 证书模块 | MoveCertificate v1.5.7 (突破 Android 14+ 只读 APEX 限制) |
| 代理核心 | Clash Meta (TUN 模式) |
| 证书解锁 | Vector v2.0 (LSPosed) + TrustMeAlready |

---

## 步骤一：部署 CA 证书 (MoveCertificate)

将 mitmproxy 的 CA 证书提取为纯 PEM 格式，并通过 MoveCertificate 模块注入系统信任区。严格禁止直接写 `/apex/` 目录。

```bash
CERT_HASH=$(openssl x509 -in /root/.mitmproxy/mitmproxy-ca.pem -hash -noout)
openssl x509 -in /root/.mitmproxy/mitmproxy-ca.pem -out /tmp/mitmproxy-ca-cert.pem

ROOTFS=/data/data/com.openminis.app/files/alpine-rootfs
android-shizuku-cli exec "
for f in /data/adb/modules/MoveCertificate/certificates/*.0; do
  if grep -q mitmproxy \"\$f\" 2>/dev/null && [ \"\$(basename \"\$f\")\" != \"${CERT_HASH}.0\" ]; then
    rm \"\$f\"
  fi
done
cp $ROOTFS/tmp/mitmproxy-ca-cert.pem /data/adb/modules/MoveCertificate/certificates/${CERT_HASH}.0
chmod 644 /data/adb/modules/MoveCertificate/certificates/${CERT_HASH}.0
"
```

**完成后提示用户**：证书已部署至系统底层模块，请重启手机以使 APEX 挂载生效。

---

## 步骤二：下载对抗依赖 (Frida)

下载 Frida server 和 frida-inject，用于后续 SSL pinning 绕过。

```bash
FRIDA_VER=$(curl -sL "https://api.github.com/repos/frida/frida/releases/latest" | grep '"tag_name"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
cd /tmp
curl -sLO "https://github.com/frida/frida/releases/download/${FRIDA_VER}/frida-server-${FRIDA_VER}-android-arm64.xz"
xz -d frida-server-${FRIDA_VER}-android-arm64.xz
android-shizuku-cli exec "cp /data/data/com.openminis.app/files/alpine-rootfs/tmp/frida-server-${FRIDA_VER}-android-arm64 /data/local/tmp/frida-server; chmod 755 /data/local/tmp/frida-server"

curl -sLO "https://github.com/frida/frida/releases/download/${FRIDA_VER}/frida-inject-${FRIDA_VER}-android-arm64.xz"
xz -d frida-inject-${FRIDA_VER}-android-arm64.xz
android-shizuku-cli exec "cp /data/data/com.openminis.app/files/alpine-rootfs/tmp/frida-inject-${FRIDA_VER}-android-arm64 /data/local/tmp/frida-inject; chmod 755 /data/local/tmp/frida-inject"
```

---

## 步骤三：Clash 配置骨架初始化

确保目标为 `imported/<UUID>/config.yaml`。先确认用户的目标 UUID（默认参考 `3278a573-6f61-437b-94a9-2a2c63d25660`）。

在 `config.yaml` 中需完成以下 3 处注入。禁止用 Python 处理长文本，使用 `sed` 或 `awk` 追加。

### 3.1 proxies 底部追加

```yaml
- {name: Local-Mitmproxy, type: http, server: 127.0.0.1, port: 8080}
```

### 3.2 rule-providers 追加

```yaml
mitm-capture:
  type: file
  behavior: classical
  path: mitm-capture.yaml
```

### 3.3 rules 顶部追加（防循环必须排在最前）

```yaml
- PROCESS-NAME,mitmdump,DIRECT
- PROCESS-NAME,mitmweb,DIRECT
- RULE-SET,mitm-capture,Local-Mitmproxy
```

完成后将 config 和 provider 文件同步至 `processing/` 目录，并修正 owner。

---

## 完成标记

环境初始化完成后，后续日常抓包使用 `mitm-capture-core` skill。

---
