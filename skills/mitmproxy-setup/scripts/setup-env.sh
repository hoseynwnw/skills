#!/bin/sh
echo "=== Phase 1: 环境准备 ==="

echo "[1/4] 安装 mitmproxy..."
pip install mitmproxy 2>/dev/null || apk add py3-pip && pip install mitmproxy

echo "[2/4] 生成 mitmproxy 证书..."
mitmdump --version >/dev/null 2>&1
mitmdump -s /dev/null &
sleep 2
kill %1 2>/dev/null

echo "[3/4] 推送证书到 Android 系统信任区..."
CERT_HASH=$(openssl x509 -inform PEM -subject_hash_old -in ~/.mitmproxy/mitmproxy-ca-cert.pem | head -1)
cp ~/.mitmproxy/mitmproxy-ca-cert.pem /tmp/$CERT_HASH.0

android-shizuku-cli exec "su -c 'cp /data/local/tmp/$CERT_HASH.0 /system/etc/security/cacerts/ && chmod 644 /system/etc/security/cacerts/$CERT_HASH.0'"

echo "[4/4] 设置全局 HTTP 代理..."
android-shizuku-cli exec "settings put global http_proxy 127.0.0.1:8080"

echo "=== 环境准备完成 ==="
echo "⚠️ 证书安装可能需要重启设备生效"
