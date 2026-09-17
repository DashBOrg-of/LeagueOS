param([string]$LanUrl)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$linuxRoot = (wsl.exe -d KPFM -- wslpath -a ($root -replace '\\','/') | Select-Object -Last 1).Trim()
if (-not $LanUrl) {
  $lanIp = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp |
    Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.|192\.168.224\.)' } |
    Select-Object -First 1 -ExpandProperty IPAddress)
  $LanUrl = "http://$lanIp`:8210"
}
$quotedRoot = $linuxRoot.Replace("'", "'\\''")
$quotedUrl = $LanUrl.TrimEnd('/').Replace("'", "'\\''")
wsl.exe -d KPFM -- bash -lc "cd '$quotedRoot' && export DASHBORG_LAN_URL='$quotedUrl' && docker compose -p dashborg-leagueos up -d --build"
& (Join-Path $PSScriptRoot 'bootstrap-local.ps1') -LanUrl $LanUrl
