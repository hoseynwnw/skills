#!/bin/sh
if [ -z "$1" ]; then
  echo "用法: sh scripts/backup_app.sh <包名>"
  exit 1
fi
PKG=$1
BACKUP_DIR="/data/local/tmp/minis_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${PKG}_${TIMESTAMP}.tar.gz"

echo "=== 💾 备份 App 数据 ==="
android-shizuku-cli exec "pm path $PKG" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ 未找到 App: $PKG"; exit 1
fi

echo "[1/3] 计算数据大小..."
SIZE=$(android-shizuku-cli exec "su -c 'du -sm /data/data/$PKG 2>/dev/null | cut -f1'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','0').strip())" 2>/dev/null)
echo "  大小: ${SIZE} MB"

echo "[2/3] 打包数据 (保存至 /data/local/tmp)..."
android-shizuku-cli exec "su -c 'mkdir -p $BACKUP_DIR && tar czf $BACKUP_FILE -C /data/data $PKG'" >/dev/null

echo "[3/3] 验证备份文件..."
RESULT=$(android-shizuku-cli exec "su -c 'ls -lh $BACKUP_FILE 2>/dev/null'" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('stdout','').strip())" 2>/dev/null)

if [ -n "$RESULT" ]; then
  echo "  ✅ 备份成功! 路径: $BACKUP_FILE"
  echo "  (如需导出到用户目录，请使用 sandbox-bridge 技能复制)"
else
  echo "  ❌ 备份失败"
fi
