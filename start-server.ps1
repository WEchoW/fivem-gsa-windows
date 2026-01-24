$ErrorActionPreference = "Stop"

$fx = "C:\fivem\server\FXServer.exe"

$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Missing FXServer.exe at $fx"
  exit 1
}

New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

Write-Host "Starting txAdmin on ${iface}:${txaPort} (TXDATA=$tx)"

& $fx +set txAdminInterface $iface +set txAdminPort $txaPort
