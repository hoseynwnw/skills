#!/bin/sh
if [ -z "$1" ]; then
  echo "用法: bash scripts/inject-frida.sh <目标App包名>"
  exit 1
fi

PKG=$1
echo "=== Phase 3: Frida 注入 (SSL Pinning Bypass) ==="
echo "目标: $PKG"

echo "[1/4] 启动 frida-server..."
FRIDA_RUNNING=$(android-shizuku-cli exec "su -c 'pidof frida-server'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())" 2>/dev/null)

if [ -z "$FRIDA_RUNNING" ]; then
  android-shizuku-cli exec "su -c 'nohup /data/local/tmp/frida-server -D >/dev/null 2>&1 &'"
  sleep 2
  echo "  ✓ frida-server 已启动"
else
  echo "  ✓ frida-server 已在运行"
fi

echo "[2/4] 获取 App PID..."
APP_PID=$(android-shizuku-cli exec "su -c 'pidof $PKG'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())" 2>/dev/null)
echo "  PID: $APP_PID"

echo "[3/4] 注入 SSL pinning bypass 脚本..."
frida -U -p "$APP_PID" -l /data/local/tmp/ssl-pinning-bypass.js --no-pause &
sleep 2
echo "  ✓ 注入完成"

echo "[4/4] 确认注入状态..."
frida-ps -U | grep "$PKG"
echo "=== Frida 注入完成 ==="
