#!/bin/sh
echo "=== 🔒 隐私审计套餐 ==="

echo "[1/3] 抓取活跃网络连接 (排除 Clash 本地回环)..."
CONNECTIONS=$(android-shizuku-cli exec "su -c 'ss -tunp state established'" | python3 -c "
import sys, json
try:
    stdout = json.load(sys.stdin).get('data',{}).get('stdout','')
    for line in stdout.strip().split('\n')[1:]:
        parts = line.split()
        if len(parts) >= 6:
            peer = parts[5]
            proc = parts[6] if len(parts) > 6 else 'unknown'
            if not peer.startswith('127.'):
                print(f'{peer}\t{proc}')
except: pass
")

echo "[2/3] 分析连接目标..."
echo "$CONNECTIONS" | awk '{print "  -> " $0}'

if [ "$1" = "--block" ]; then
  echo "[3/3] 写入 Magisk Systemless Hosts 屏蔽规则..."
  HOSTS_DIR="/data/adb/modules/hosts/system/etc"
  CHECK=$(android-shizuku-cli exec "su -c 'ls -d $HOSTS_DIR 2>/dev/null'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())")
  
  if [ -n "$CHECK" ]; then
    android-shizuku-cli exec "su -c 'echo \"127.0.0.1 ad.example.com\" >> $HOSTS_DIR/hosts'" >/dev/null
    echo "  ✓ 示例规则已写入 Systemless Hosts"
  else
    echo "  ❌ 错误: 未检测到 Magisk Systemless Hosts 模块开启，由于 Android 16 /system 强只读，跳过写入。"
  fi
else
  echo "[3/3] 跳过屏蔽 (加 --block 参数可自动写入)"
fi
echo "=== ✅ 审计完成 ==="
