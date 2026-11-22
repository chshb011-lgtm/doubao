# 备份 DSH 关键配置（脱敏）
#
# 用途：把 ~/.dsh 下的关键配置复制到 D 盘，供 git diff 对比或故障回滚。
# 安全：只复制配置文件（json / yml / md / jsonc），**显式排除凭据**：
#       relay.json（含配对码与局域网密钥）、cf_token.txt、*.key、*.pem、node_modules。
#
# 用法：
#   powershell -ExecutionPolicy Bypass -File backup-dsh-config.ps1
#   powershell -ExecutionPolicy Bypass -File backup-dsh-config.ps1 -OutRoot "D:\backups"

param(
    [string]$OutRoot = "D:\backups",
    [string]$DshHome = "$env:USERPROFILE\.dsh"
)

$ErrorActionPreference = "Stop"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$dst = Join-Path $OutRoot "dsh-config-$stamp"
New-Item -ItemType Directory -Force -Path $dst | Out-Null

$profileDir = Join-Path $DshHome "profiles\desktop"

# 要备份的单个文件（相对 ~/.dsh）
$files = @(
    "profiles\desktop\package.json",
    "profiles\desktop\pnpm-workspace.yaml",
    "profiles\desktop\cordis.patch.yml",
    "profiles\desktop\cordis.yml",
    "dsh-builtin-browser-host\settings.json",
    "dsh-pet\main-config.jsonc",
    "dsh-pet\memory.json",
    "profiles\desktop\node_modules\dsh-douyin-browser-local\state\video-policy.json",
    "profiles\desktop\node_modules\dsh-douyin-browser-local\state\chat-policy.json"
)

# 明确排除的凭据文件名（双保险）
$deny = @("relay.json", "cf_token.txt", "cf_account.txt")

$copied = @()
foreach ($rel in $files) {
    $src = Join-Path $DshHome $rel
    if (-not (Test-Path $src)) { continue }
    if ($deny -contains (Split-Path $src -Leaf)) { Write-Warning "skip credential: $rel"; continue }
    $target = Join-Path $dst ("dsh\" + $rel)
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item $src $target -Force
    $copied += $rel
}

# 目录：技能与 agent 留痕（只收 .md / .json / .jsonl）
$dirs = @("skills", "memory\memories")
foreach ($d in $dirs) {
    $src = Join-Path $DshHome $d
    if (-not (Test-Path $src)) { continue }
    $target = Join-Path $dst ("dsh\" + $d)
    Copy-Item $src $target -Recurse -Force -ErrorAction SilentlyContinue
    $copied += "$d\ (目录)"
}

# 校验：确认没有把凭据带出去
$leak = Get-ChildItem $dst -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $deny -contains $_.Name }
if ($leak) {
    $leak | ForEach-Object { Remove-Item $_.FullName -Force }
    Write-Warning "已删除误入的凭据文件: $($leak.Name -join ', ')"
}

Write-Host ""
Write-Host "备份完成: $dst"
$copied | ForEach-Object { Write-Host "  + $_" }
$size = [math]::Round(((Get-ChildItem $dst -Recurse -File | Measure-Object Length -Sum).Sum / 1MB), 2)
Write-Host "体积: $size MB（不含 node_modules / 凭据）"
