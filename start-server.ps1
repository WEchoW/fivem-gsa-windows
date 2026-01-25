# start-server.ps1
$ErrorActionPreference = "Stop"

$fx = "C:\fivem\server\FXServer.exe"

# Data path
$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Missing FXServer.exe at $fx"
  if (Test-Path "C:\fivem\server") {
    Get-ChildItem "C:\fivem\server" -Force | Format-Table -AutoSize | Out-String | Write-Host
  } else {
    Write-Host "C:\fivem\server does not exist."
  }
  exit 1
}

New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

# Ensure basic txData structure exists
New-Item -ItemType Directory -Force -Path (Join-Path $tx "resources") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tx "cache") | Out-Null

# txAdmin interface + port
$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

Write-Host "DEBUG TXHOST_TXA_PORT=[$($env:TXHOST_TXA_PORT)] TXHOST_INTERFACE=[$($env:TXHOST_INTERFACE)]"
Write-Host "Starting txAdmin on ${iface}:${txaPort} (TXDATA=$tx)"

# Start server (txAdmin mode)
& $fx `
  +set "txAdminInterface" "$iface" `
  +set "txAdminPort" "$txaPort"
