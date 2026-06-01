#!/bin/sh
if [ -z "$1" ]; then
  echo "用法: bash scripts/route-clash.sh <目标App包名>"
  exit 1
fi

PKG=$1
echo "=== Phase 2: Clash TUN 路由 ==="
echo "目标: $PKG"

echo "[1/3] 检查 Clash 运行状态..."
CLASH_RUNNING=$(android-shizuku-cli exec "su -c 'pidof clash-meta'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())" 2>/dev/null)

if [ -z "$CLASH_RUNNING" ]; then
  echo "  ⚠️ Clash 未运行，尝试启动..."
  android-shizuku-cli exec "su -c 'nohup /data/local/tmp/clash-meta -d /data/local/tmp/clash >/dev/null 2>&1 &'"
  sleep 3
fi

echo "[2/3] 配置代理..."
android-shizuku-cli exec "settings put global http_proxy 127.0.0.1:8080"

echo "[3/3] 验证代理..."
CURRENT_PROXY=$(android-shizuku-cli exec "settings get global http_proxy" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())" 2>/dev/null)
echo "  当前代理: $CURRENT_PROXY"

echo "=== 路由配置完成 ==="
