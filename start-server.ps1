# start-server.ps1
$ErrorActionPreference = "Stop"

$fx = "C:\fivem\server\FXServer.exe"
$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Missing FXServer.exe at $fx"
  Get-ChildItem "C:\fivem\server" -Force | Format-Table -AutoSize | Out-String | Write-Host
  exit 1
}

New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }

Write-Host "DEBUG TXHOST_TXA_PORT=[$($env:TXHOST_TXA_PORT)] TXHOST_INTERFACE=[$($env:TXHOST_INTERFACE)]"
Write-Host "=================================================="
Write-Host "Starting FXServer (txAdmin first-run mode)"
Write-Host "TXDATA: $tx"
Write-Host "txAdmin bind: $iface"
Write-Host "txAdmin port: $txaPort"
Write-Host "=================================================="

& $fx +set txAdminInterface $iface +set txAdminPort $txaPort
