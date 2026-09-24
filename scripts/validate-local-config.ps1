param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [Parameter(Mandatory = $true)]
    [ValidateRange(1024, 65535)]
    [int]$Port
)

$ErrorActionPreference = 'Stop'

if ($ProjectName -notmatch '^[a-z0-9][a-z0-9_-]{0,62}$') {
    throw 'ProjectName must be a lowercase Compose-safe identifier.'
}
if ($ProjectName -eq 'dashborg-leagueos') {
    throw 'The shared dashborg-leagueos Compose project name is forbidden; provide a unique project name.'
}
if ($Port -in @(8207, 8208, 8209, 8210)) {
    throw "Port $Port is reserved by the current LeagueOS runtime lanes."
}

$listeners = @(Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)
if ($listeners.Count -gt 0) {
    throw "Port $Port is already listening; choose an unused port."
}

Write-Output "Local project and port accepted: $ProjectName / $Port"
