---
name: android-power-tools
description: Android 16 设备深度控制与混合环境路由。涵盖：环境决策、无障碍UI自动化、Root系统调优、隐私审计、Magisk管理。当用户要求优化手机、截屏、写脚本、修改系统参数、自动化操作UI、查看电池/进程时自动触发。
version: 1.7.0
---
# 🤖 Android Power Tools (Android 16 增强版)

当前运行在 Google Pixel 9a (tegu) / Tensor G4 / Android 16 / Magisk Root 环境下。

## 🧠 核心：混合环境决策路由 (Context Router)

1. **沙盒环境 (`rootfs` / Alpine Linux)**：
   - 适用：纯文本处理、Python/JS 脚本、网络请求、内部文件管理。
   - 执行：直接执行标准 Linux 命令。
2. **宿主环境 (Android OS / Shizuku / Root)**：
   - 适用：涉及实体手机 UI 操作、App 管理、系统调优、宿主硬件读取。
   - 执行：必须使用 `android-shizuku-cli exec "su -c '...'"`。

## ⚠️ 跨环境流转与防坑指南 (极度重要)

1. **跨环境传文件**：
   **绝对禁止**直接在 rootfs 内操作 `/sdcard`（那是虚拟的）。当需要在沙盒和真实手机存储间互传文件时，**必须调用你拥有的 `sandbox-bridge` 技能**。
   
2. **截屏与 UI Dump 限制**：
   - Android 16 限制了无障碍截屏。强制使用 Root 命令：`android-shizuku-cli exec "su -c 'screencap -p /data/local/tmp/temp.png'"`，然后用 `sandbox-bridge` 导回。
   - **UI Dump 推荐路径**：`uiautomator dump /data/local/tmp/window_dump.xml` (避免写入 `/sdcard` 产生权限冲突)。执行前**必须** `sleep 2` 等待界面渲染。

3. **命令兼容性**：
   - BusyBox `sort` 不支持 `-h`，用 `-m` 配合 `sort -rn`。
   - `android-shizuku-cli exec` 返回 JSON，提取 stdout 需解析 JSON 的 `data.stdout` 字段。

---

## ⚡ 快速索引（按场景调用内置脚本）

所有复杂逻辑已封装在 `scripts/` 下，**直接调用脚本**，不要试图手动拼写长命令。

| 你说 / 需求 | 我执行 | 脚本路径 |
|------|--------|------|
| "手机加速" / "卡了" | 冻结毒瘤+清缓存+快动画+性能调度 | `bash scripts/boost.sh [包名...]` |
| "隐私审计" / "屏蔽广告" | 抓连接+分析域名+屏蔽 | `bash scripts/privacy_audit.sh [--block]` |
| "电池状态" / "充电功率" | 查多节点传感器+计算真实功率 | `bash scripts/battery_check.sh` |
| "备份 XX App" | 打包 App 数据 | `bash scripts/backup_app.sh <包名>` |
| "Magisk 管理" | 列出/开关/移除模块 | `bash scripts/magisk_mgr.sh [list\|disable\|enable] <模块>` |

---

## 🛠️ 核心能力速查字典 (原生工具调用)

### 1. 系统信息查询与控制
```bash
android-device info                                      # 设备/内存概览
android-shizuku-cli exec "getprop ro.build.fingerprint"  # 系统指纹
android-shizuku-cli exec "dumpsys window displays | grep mCurrentFocus"  # 查前台活动窗口
android-shizuku-cli exec "am start -a android.intent.action.VIEW -d 'https://www.google.com'" # 打开网页
```

### 2. 网络连接审计与 Clash Meta 感知
```bash
android-shizuku-cli exec "su -c 'ss -tunp | head -20'"
```
   ⚠️ 审计时需区分 Clash 代理流量：
   - `127.91.79.77:37941` 等动态 IP 均为 TUN 内部服务（由 VpnService 分配）。
   - 目标为阿里 CDN 或海外节点端口的连接为正常代理出口。
   - **真正的可疑连接**是绕过 Clash 代理直连外部的进程流量。

### 3. 系统参数与 UI 调优
```bash
# CPU 调度模式 (Tensor 可选: sched_pixel, performance, powersave)
android-shizuku-cli exec "su -c 'echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor'"

# 屏幕亮度 (0=关闭自动亮度, 128=中等亮度)
android-shizuku-cli exec "settings put system screen_brightness_mode 0"
android-shizuku-cli exec "settings put system screen_brightness 128"
```

### 4. 交互与限制
```bash
android-notification send --title "标题" --body "内容"
android-clipboard set "文本"
android-shizuku-cli exec "input swipe 100 1200 500 1200 200"  # 模拟返回手势
android-shizuku-cli exec "cmd media_session volume --show --stream 3 --set 10" # 音量调整
```
   ⚠️ **剪贴板前台限制**: `android-clipboard` 操作时 **Minis 必须处于前台**。若报错 `clipboard_requires_foreground`，先执行 `input keyevent KEYCODE_HOME` 回到桌面让 Widget 恢复焦点。

## 🚨 安全准则
- `permission_denied` → 检查 Shizuku/Root 授权状态。
- `NODE_NOT_FOUND` → 控件不存在，尝试 `android-a11y-cli tap xy` 盲点，或重新 `ui dump`。
- 修改 hosts 等核心系统文件必须基于 Magisk systemless 机制，不要直接触碰 `/system`。
