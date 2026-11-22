# 豆包

本机 **DeepSeek Harness（DSH）** 的配置基线仓库。

## 用途

这台机器上的 DSH 被反复装卸过插件、改过权限与浏览器载体，出过几次故障。
这个仓库把**当前可用的配置**固化成可版本化的文档，目的是：

1. 每次改动后 `git diff` 就能看出动了什么；
2. 配置改坏时，能对照上一个 commit 回滚；
3. 换机器 / 重装时，照 `docs/` 重建。

## 内容

| 路径 | 说明 |
|---|---|
| `docs/dsh-config-baseline.md` | 当前配置基线：版本、插件清单、权限、浏览器载体 |
| `scripts/backup-dsh-config.ps1` | 把关键配置（**脱敏**）备份到 D 盘，供对比与回滚 |

## 边界

- **只存配置与文档，不存任何凭据**：不含 API key、SSH 私钥、配对码、token。
- 仓库为 **Private**，仅供本机自用。

## 维护约定

改动 DSH 配置（装/卸插件、改权限、换浏览器载体）之后：

1. 更新 `docs/dsh-config-baseline.md`
2. `git commit -m "config: <改了什么>"`
3. `git push`

---

创建：2026-11-22 ｜ 由 DSH agent 初始化
