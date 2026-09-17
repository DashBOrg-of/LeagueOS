param([string]$LanUrl)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$env:COMPOSE_PROJECT_NAME = 'dashborg-leagueos'
$lanIp = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp |
  Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.|192\.168\.224\.)' } |
  Select-Object -First 1 -ExpandProperty IPAddress)
if (-not $LanUrl) { $LanUrl = "http://$lanIp`:8210" }
$env:DASHBORG_LAN_URL = $LanUrl.TrimEnd('/')
docker compose -f (Join-Path $root 'docker-compose.yml') up -d
for ($i = 0; $i -lt 60; $i++) {
  docker compose -f (Join-Path $root 'docker-compose.yml') exec -T wordpress wp db check --allow-root *> $null
  if ($LASTEXITCODE -eq 0) { break }
  Start-Sleep -Seconds 2
}
docker compose -f (Join-Path $root 'docker-compose.yml') exec -T wordpress wp core is-installed --allow-root *> $null
if ($LASTEXITCODE -ne 0) {
  docker compose -f (Join-Path $root 'docker-compose.yml') exec -T wordpress wp core install --url="$($env:DASHBORG_LAN_URL)" --title='DashBOrg LeagueOS' --admin_user=localadmin --admin_password='Dashborg-Local-2026!' --admin_email='localadmin@dashborg.local' --skip-email --allow-root
}
docker compose -f (Join-Path $root 'docker-compose.yml') exec -T wordpress wp plugin activate dashborg-leagueos --allow-root
Write-Host "DashBOrg LeagueOS ready at $($env:DASHBORG_LAN_URL)"
