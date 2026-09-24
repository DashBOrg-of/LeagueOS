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
& (Join-Path $PSScriptRoot 'start-leagueos-wsl.ps1') `
    -ProjectName $ProjectName `
    -Port $Port `
    -WslWorktree $WslWorktree `
    -LanUrl $LanUrl
