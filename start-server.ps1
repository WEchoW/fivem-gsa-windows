# start-server.ps1
$ErrorActionPreference = "Stop"

$fx = "C:\fivem\server\FXServer.exe"
$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Missing FXServer.exe at $fx"
  Write-Host "Listing C:\fivem\server:"
  Get-ChildItem "C:\fivem\server" -Force | Format-Table -AutoSize | Out-String | Write-Host
  exit 1
}

# Ensure txData exists
New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

# --- txAdmin bind + port (prefer new env vars) ---
$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = $env:TXADMIN_PORT }
if (-not $txaPort) { $txaPort = "40120" }

Write-Host "=================================================="
Write-Host "Starting FXServer (txAdmin first-run mode)"
Write-Host "TXDATA: $tx"
Write-Host "txAdmin bind: $iface"
Write-Host "txAdmin port: $txaPort"
Write-Host "=================================================="

# Start txAdmin mode
& $fx +set txAdminInterface $iface +set txAdminPort $txaPort
