#!/bin/sh
MODULES_DIR="/data/adb/modules"
ACTION=$1
MOD_NAME=$2

echo "=== 🧩 Magisk 模块管理 ==="

if [ "$ACTION" = "list" ]; then
  echo "[当前模块列表]"
  android-shizuku-cli exec "su -c 'ls -1 $MODULES_DIR 2>/dev/null'" | python3 -c "import sys,json; mods=json.load(sys.stdin).get('data',{}).get('stdout','').strip().split('\n'); print('\n'.join(['  • '+m for m in mods if m]) if mods!=[''] else '  (无)')"
elif [ "$ACTION" = "disable" ] && [ -n "$MOD_NAME" ]; then
  android-shizuku-cli exec "su -c 'touch $MODULES_DIR/$MOD_NAME/disable'" >/dev/null
  echo "  ✓ 已标记禁用 $MOD_NAME (重启生效)"
elif [ "$ACTION" = "enable" ] && [ -n "$MOD_NAME" ]; then
  android-shizuku-cli exec "su -c 'rm -f $MODULES_DIR/$MOD_NAME/disable'" >/dev/null
  echo "  ✓ 已标记启用 $MOD_NAME (重启生效)"
else
  echo "用法: bash scripts/magisk_mgr.sh [list|disable|enable] <模块名>"
fi
