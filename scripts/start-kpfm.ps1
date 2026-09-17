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
$cmd = "cd '$quotedRoot' && export DASHBORG_LAN_URL='$quotedUrl' && " +
  "for i in `$(seq 1 60); do docker compose -p dashborg-leagueos exec -T wordpress wp db check --allow-root >/dev/null 2>&1 && break; sleep 2; done; " +
  "docker compose -p dashborg-leagueos exec -T wordpress wp core is-installed --allow-root >/dev/null 2>&1 || docker compose -p dashborg-leagueos exec -T wordpress wp core install --url='$quotedUrl' --title='DashBOrg LeagueOS' --admin_user=localadmin --admin_password='Dashborg-Local-2026!' --admin_email='localadmin@dashborg.local' --skip-email --allow-root; " +
  "docker compose -p dashborg-leagueos exec -T wordpress wp plugin activate dashborg-leagueos --allow-root"
wsl.exe -d KPFM -- bash -lc $cmd
Write-Host "DashBOrg LeagueOS ready at $LanUrl"
