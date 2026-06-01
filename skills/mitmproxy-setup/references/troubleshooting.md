# mitmproxy-setup 故障排查

## 常见问题

### 1. 证书未被信任
- 症状：HTTPS 请求返回 SSL 错误
- 检查：`ls /system/etc/security/cacerts/ | grep <hash>`
- 解决：重新运行 `setup-env.sh`，可能需要重启

### 2. App 绕过代理
- 症状：部分请求未出现在 mitmdump 中
- 原因：App 使用 OkHttp 的 `proxy(Proxy.NO_PROXY)` 或自定义 DNS
- 解决：使用 Clash TUN 模式强制路由

### 3. Frida 注入失败
- 症状：`Failed to attach: unable to find process`
- 检查：frida-server 版本与 frida-tools 版本是否一致
- 解决：统一更新到最新版本

### 4. 代理断连
- 症状：mitmdump 频繁断开连接
- 原因：App 检测到代理并主动断开
- 解决：使用透明代理模式
