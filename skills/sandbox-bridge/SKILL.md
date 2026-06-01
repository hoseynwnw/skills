---
name: sandbox-bridge
version: 1.1.0
description: "沙盒文件系统桥接：当需要在 Minis PRoot 沙盒和 Android 外部存储之间复制文件时使用。涵盖 rootfs 与 bind mount 的路径映射、shizuku 复制命令、mounts 外部文件夹访问。触发词：复制出去、复制进来、导出、导入、传到手机、从手机拿文件、沙盒路径、真实路径。"
---

# Sandbox Bridge — Minis 沙盒 ↔ Android 文件系统

## 核心概念

Minis 的 `/var/minis/` **不是单一文件系统**，而是两层叠加：

```text
/data/data/com.openminis.app/files/
├── alpine-rootfs/          ← PRoot rootfs（Alpine Linux 根文件系统）
└── minis-global/           ← 跨会话持久层（bind mount 到 rootfs 之上）
```

rootfs 在 Android 上的基础路径：
```text
/data/data/com.openminis.app/files/alpine-rootfs/
```

## `/var/minis/` 完整路径映射

### 第一类：rootfs 内目录（会话级，rootfs 重置后消失）

| 沙盒路径 | Android 真实路径 |
|----------|-----------------|
| `/var/minis/attachments/` | `/data/data/com.openminis.app/files/alpine-rootfs/var/minis/attachments/` |
| `/var/minis/workspace/` | `/data/data/com.openminis.app/files/alpine-rootfs/var/minis/workspace/` |
| `/var/minis/offloads/` | `/data/data/com.openminis.app/files/alpine-rootfs/var/minis/offloads/` |
| `/var/minis/browser/` | `/data/data/com.openminis.app/files/alpine-rootfs/var/minis/browser/` |

### 第二类：bind mount 目录（跨会话持久，rootfs 重置后保留）

| 沙盒路径 | Android 真实路径 |
|----------|-----------------|
| `/var/minis/memory/` | `/data/data/com.openminis.app/files/minis-global/memory/` |
| `/var/minis/shared/` | `/data/data/com.openminis.app/files/minis-global/shared/` |
| `/var/minis/skills/` | `/data/data/com.openminis.app/files/minis-global/skills/` |

> **⚠️ 关键**：rootfs 内有同名空壳目录（如 `alpine-rootfs/var/minis/skills/`），但**内容是空的**。真实数据在 `minis-global/` 下。从 Android 侧访问必须用 `minis-global/` 路径。

### 第三类：外部挂载

| 沙盒路径 | Android 真实路径 |
|----------|-----------------|
| `/var/minis/mounts/<name>/` | 配置文件 `minis-config/mounted-folders.json` 中 `resolvedHostPath` 字段 |

当前挂载：
```text
/var/minis/mounts/Telegram/  →  /storage/emulated/0/Download/Telegram/
```

## 复制命令模板

### 📤 1. 沙盒 → 外部存储 (导出)

```bash
# 技能/记忆/共享（bind mount 目录）
android-shizuku-cli exec "cp -r /data/data/com.openminis.app/files/minis-global/skills/<name> /storage/emulated/0/Download/"

# 工作文件（rootfs 目录）
android-shizuku-cli exec "cp /data/data/com.openminis.app/files/alpine-rootfs/var/minis/workspace/<file> /storage/emulated/0/Download/"
```

### 📥 2. 外部存储 → 沙盒 (导入) ⚠️ 必修权限

**极易踩坑**：Shizuku 复制的文件默认 owner 是 `root:root`。如果不改权限，Minis 将无法读取或删除这些文件！**必须**带上 `chown` 命令。

```bash
# 复制到 skills 示例
android-shizuku-cli exec "
APP_DIR=/data/data/com.openminis.app
cp -r /storage/emulated/0/Download/<skill-name> \$APP_DIR/files/minis-global/skills/
APP_USER=\\$(stat -c %U \$APP_DIR)
chown -R \\$APP_USER:\\$APP_USER \$APP_DIR/files/minis-global/skills/<skill-name>
chmod -R 755 \$APP_DIR/files/minis-global/skills/<skill-name>
echo '导入并修复权限完成'
"
```
*(注：导入到 `workspace` 或 `shared` 时，请替换为对应的 Android 真实路径，同样必须执行 chown)*

### 🔍 3. 验证完整性

```bash
# 对比 sha256
sha256sum /var/minis/skills/<name>/SKILL.md
android-shizuku-cli exec "sha256sum /storage/emulated/0/Download/<name>/SKILL.md"
```

## 为什么这么复杂

1. **Android 沙盒隔离**：`/data/data/com.openminis.app/` 是 Minis 私有目录，其他 App 无权访问
2. **PRoot 命名空间**：沙盒内看到的是 `/var/minis/`，但底层 bind mount 把 rootfs 和 minis-global 拼在一起
3. **权限边界**：普通 `cp` 无法跨越私有目录 ↔ `/storage/emulated/0/`，必须走 shizuku (root)，而走 root 后又必须手动降权 (`chown`) 交还给 App。

## 快速决策表

| 要操作的目标 | 用哪个基础路径 |
|-------------|--------------|
| skill 文件 | `...minis-global/skills/` |
| 记忆/daily log | `...minis-global/memory/` |
| shared 共享文件 | `...minis-global/shared/` |
| workspace 临时文件 | `...alpine-rootfs/var/minis/workspace/` |
| attachments 附件 | `...alpine-rootfs/var/minis/attachments/` |
| offloads 转储 | `...alpine-rootfs/var/minis/offloads/` |
| browser 截图 | `...alpine-rootfs/var/minis/browser/` |
| mounts 外部文件夹 | 直接读 `/var/minis/mounts/<name>/`，无需 shizuku |
