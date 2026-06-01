# SSL Pinning Bypass 参考

## 常见 SSL Pinning 方案

1. **OkHttp Certificate Pinner** — 通过自定义 TrustManager 绑定特定证书
2. **TrustKit (iOS/Android)** — 基于公钥哈希的 pinning
3. **自定义 SSLSocketFactory** — 直接替换 Socket 层

## Frida 绕过脚本

使用 `frida-ssl-pinning-unpinner` 或自定义脚本：

```javascript
// 绕过 OkHttp CertificatePinner
Java.perform(function() {
    var CertificatePinner = Java.use("okhttp3.CertificatePinner");
    CertificatePinner.check.overload('java.lang.String', 'java.util.List').implementation = function() {
        return;
    };
});
```

## 注意事项

- Android 14+ 需要额外绕过 Restricted Settings
- 部分金融类 App 使用 Native 层 pinning，需要 hook so 文件
