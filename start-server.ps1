# start-server.ps1
$ErrorActionPreference = "Stop"

$fx = "C:\fivem\server\FXServer.exe"
$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

$txaPort = $env:TXADMIN_PORT
if (-not $txaPort) { $txaPort = "40120" }

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Missing FXServer.exe at $fx"
  Write-Host "Listing C:\fivem\server:"
  Get-ChildItem "C:\fivem\server" -Force | Format-Table -AutoSize | Out-String | Write-Host
  exit 1
}

# Ensure txData exists (this is where txAdmin stores everything)
New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

Write-Host "=================================================="
Write-Host "Starting FXServer (txAdmin first-run mode)"
Write-Host "TXDATA: $tx"
Write-Host "txAdmin bind: 0.0.0.0"
Write-Host "txAdmin port: $txaPort"
Write-Host "=================================================="

# Start txAdmin mode (default behavior when no server.cfg is provided)
# Force interface+port so it's reachable via container port mapping
& $fx +set txAdminInterface 0.0.0.0 +set txAdminPort $txaPort
