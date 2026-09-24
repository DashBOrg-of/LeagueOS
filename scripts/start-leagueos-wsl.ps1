param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [Parameter(Mandatory = $true)]
    [int]$Port,
    [Parameter(Mandatory = $true)]
    [string]$WslWorktree,
    [string]$LanUrl
)

$ErrorActionPreference = 'Stop'

if ($WslWorktree -notmatch '^/' -or $WslWorktree -match '^/mnt/') {
    throw 'WslWorktree must be an existing native LeagueOS WSL checkout, not a Windows or /mnt mount.'
}

& (Join-Path $PSScriptRoot 'validate-local-config.ps1') -ProjectName $ProjectName -Port $Port

if (-not $LanUrl) {
    $lanIp = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp |
        Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.|192\.168\.224\.)' } |
        Select-Object -First 1 -ExpandProperty IPAddress)
    if (-not $lanIp) {
        throw 'No usable LAN address found; provide -LanUrl explicitly.'
    }
    $LanUrl = "http://$lanIp`:$Port"
}

$LanUrl = $LanUrl.TrimEnd('/')
$quotedWorktree = $WslWorktree.Replace("'", "'\''")
$quotedProject = $ProjectName.Replace("'", "'\''")
$quotedLanUrl = $LanUrl.Replace("'", "'\''")
$quotedCompose = "$WslWorktree/docker-compose.yml".Replace("'", "'\''")

$distroCheck = (wsl.exe -d LeagueOS -- true 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "The LeagueOS WSL distro is unavailable: $distroCheck"
}

$existing = (wsl.exe -d LeagueOS -- docker ps -a --filter "label=com.docker.compose.project=$ProjectName" --format '{{.ID}}' 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Could not inspect LeagueOS WSL Compose projects: $existing"
}

$existingVolumes = (wsl.exe -d LeagueOS -- docker volume ls -q --filter "label=com.docker.compose.project=$ProjectName" 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Could not inspect LeagueOS WSL Compose volumes: $existingVolumes"
}

$existingNetworks = (wsl.exe -d LeagueOS -- docker network ls -q --filter "label=com.docker.compose.project=$ProjectName" 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Could not inspect LeagueOS WSL Compose networks: $existingNetworks"
}

if ($existing -or $existingVolumes -or $existingNetworks) {
    throw "Compose project '$ProjectName' already exists in LeagueOS WSL; choose a unique project name."
}

$script = @'
set -euo pipefail
cd '__WORKTREE__'
export DASHBORG_HTTP_PORT='__PORT__'
export DASHBORG_LAN_URL='__LAN_URL__'
docker compose -p '__PROJECT__' -f '__COMPOSE__' config --quiet
docker compose -p '__PROJECT__' -f '__COMPOSE__' up -d --build
for attempt in $(seq 1 60); do
  if docker compose -p '__PROJECT__' -f '__COMPOSE__' exec -T wordpress wp db check --allow-root >/dev/null 2>&1; then
    break
  fi
  if [ "$attempt" -eq 60 ]; then
    echo 'WordPress database readiness check timed out' >&2
    exit 1
  fi
  sleep 2
done
docker compose -p '__PROJECT__' -f '__COMPOSE__' exec -T wordpress sh -lc 'if ! wp core is-installed --allow-root >/dev/null 2>&1; then wp core install --url="$DASHBORG_LAN_URL" --title="DashBOrg LeagueOS" --admin_user="$DASHBORG_WP_ADMIN_USER" --admin_password="$DASHBORG_WP_ADMIN_PASSWORD" --admin_email="$DASHBORG_WP_ADMIN_EMAIL" --skip-email --allow-root; fi; wp plugin activate dashborg-leagueos --allow-root; wp rewrite structure "/%postname%/" --hard --allow-root; wp rewrite flush --hard --allow-root'
'@

$script = $script.Replace('__WORKTREE__', $quotedWorktree)
$script = $script.Replace('__PORT__', [string]$Port)
$script = $script.Replace('__LAN_URL__', $quotedLanUrl)
$script = $script.Replace('__PROJECT__', $quotedProject)
$script = $script.Replace('__COMPOSE__', $quotedCompose)

wsl.exe -d LeagueOS -- bash -lc $script
if ($LASTEXITCODE -ne 0) {
    throw "LeagueOS WSL bootstrap failed with exit code $LASTEXITCODE."
}
Write-Host "DashBOrg LeagueOS ready at $LanUrl using project $ProjectName"
