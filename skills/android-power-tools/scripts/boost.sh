#!/bin/sh
echo "=== 🚀 手机加速套餐 ==="

echo "[1/4] 冻结指定 App..."
for pkg in "$@"; do
  android-shizuku-cli exec "pm disable-user --user 0 $pkg 2>/dev/null" >/dev/null 2>&1
  echo "  ✓ 已冻结: $pkg"
done

echo "[2/4] 清理系统缓存 (1G)..."
android-shizuku-cli exec "pm trim-caches 1G" >/dev/null 2>&1
echo "  ✓ 缓存清理完成"

echo "[3/4] 调整动画缩放至 0.5x..."
android-shizuku-cli exec "settings put global window_animation_scale 0.5" >/dev/null 2>&1
android-shizuku-cli exec "settings put global transition_animation_scale 0.5" >/dev/null 2>&1
android-shizuku-cli exec "settings put global animator_duration_scale 0.5" >/dev/null 2>&1
echo "  ✓ 动画已加速"

echo "[4/4] 切换 CPU 调度至 performance..."
android-shizuku-cli exec "su -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > \$cpu; done'" >/dev/null 2>&1
echo "  ✓ 调度已切换"

echo "=== ✅ 优化完成 ==="
