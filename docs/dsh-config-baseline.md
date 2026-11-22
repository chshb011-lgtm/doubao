# DSH 配置基线

> 采集时间：**2026-11-22**
> 采集方式：直接读 `~/.dsh/profiles/desktop/package.json` 与磁盘实测，非凭记忆。

## 一、运行环境

| 项 | 值 |
|---|---|
| DSH 版本 | **0.2.2-rc.1**（开发者预览） |
| 安装位置 | `D:\新建文件夹 (5)\DeepSeek Harness.exe`（应用本体在 D 盘） |
| 数据目录 | `C:\Users\23346\.dsh`（约 300MB+，待迁 D 盘） |
| Python / Node | DSH 自带运行时（`~/.dsh/dsh-runtimes/...`），系统无独立 node |

## 二、启动清单（18 个 bundle）

### 内核（3）
| bundle | 作用 |
|---|---|
| `@deepseek-ai/dsh-base` | 内核 |
| `@deepseek-ai/dsh-web-app` | Web 界面层 |
| `@deepseek-ai/dsh-experimental-terminal-bundle` | 常驻 shell |

### 能力（9）
| bundle | 作用 |
|---|---|
| `dsh-builtin-browser` | 浏览器操作（载体 chrome） |
| `dsh-free-search` | 搜索 9 工具（research / multi_search / platform_search…） |
| `dsh-prime-memory` | 长期记忆（L0~L3 蒸馏） |
| `@michengai/dsh-archive-manager` | 会话归档 + 损坏会话诊断 |
| `dsh-context` | 上下文洞察面板 |
| `dsh-cost-meter` | 会话成本 / 余额 |
| `dsh-rewind-plugin` | 会话回退 + 文件恢复（**注意工作区有 junction**） |
| `dsh-prompt-enhancer` | 提示词增强 |
| `dsh-market`(dshmarket) | GUI 插件市场 |

### 通道（4）
| bundle | 作用 |
|---|---|
| `dsh-mobile-plugin` | 手机接管（AI-HUB，局域网 18787） |
| `dsh-douyin-browser-local` | 抖音工具（33 个） |
| `dsh-douyin-publish` | 视频发布器（默认 draft + private） |
| `@deepseek-ai/dsh-experimental-session-search` | 搜历史会话 |

### 其他（2）
| bundle | 作用 |
|---|---|
| `dsh-pet` | 桌宠（`display: desktop`，只留桌面一只） |
| `@deepseek-ai/dsh-experimental-forge-bundle` | git 变更请求面板（实验） |

## 三、权限与审批（`cordis.patch.yml`）

```yaml
permission.defaultPreset: danger-full-access   # 新会话默认全盘访问
approval.policy: never                          # 不再弹批准
```

> 这意味着 agent 可读写全盘、执行命令且不逐次确认。**风险自负**，已配套：
> `_agent/人格与授权.md` 的四级授权表 + 每次自主操作写 `_agent/actions.jsonl`。

## 四、浏览器载体

| 项 | 值 |
|---|---|
| 载体 | **chrome**（本机 Chrome 157） |
| 配置文件 | `~/.dsh/dsh-builtin-browser-host/settings.json` |
| 独立 profile | `~/.dsh/dsh-builtin-browser-host/chrome-profile`（**不共享日常浏览器登录态**） |
| 切换方式 | 改 `browser.channel`（bundled / chrome / edge / auto / sidebar），热切换无需重启 |

已知：`bundled` 载体需要 profile 内自带 Electron 二进制，本机没有，所以用 chrome。

## 五、已知坑

1. **中文仓库名 GitHub 不收**（只允许 ASCII），会被规范化。
2. **插件装/卸必须整体重启**：`install_bundle` 返回 `restart-required`，刷新页面不生效。
3. **连续卸载运行中的重插件会拖死会话**（prime-memory 带 worker + sqlite）。批量操作优先装、少卸。
4. 工作区有 7 个 junction 指向 `D:\dsh-extra`（6.4GB），`rewind` 的"恢复文件"不要随手点。
5. 托管配置按自身清单对账重写，**手工改 `package.json` 不持久**。

## 六、如何更新本文件

改动插件/权限/载体后：

```bash
# 1. 重新采集
python -c "import json,os;d=json.load(open(os.path.expanduser('~/.dsh/profiles/desktop/package.json'),encoding='utf-8'));print('\n'.join(d['dsh']['profile']['bundles']))"
# 2. 更新对应段落
# 3. 提交
git commit -am "config: <改了什么>"
```
