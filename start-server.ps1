# start-server.ps1
$ErrorActionPreference = "Stop"

$root = $env:FIVEM_ROOT
if (-not $root) { $root = "C:\FiveM" }

$artifacts = $env:ARTIFACTS_DIR
if (-not $artifacts) { $artifacts = Join-Path $root "artifacts" }

$tx = $env:TXDATA
if (-not $tx) { $tx = Join-Path $root "txData" }

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null
New-Item -ItemType Directory -Force -Path $tx | Out-Null

$fx = Join-Path $artifacts "FXServer.exe"

$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "Starting txAdmin on ${iface}:${txaPort} (TXDATA=$tx)"

# Install artifacts if missing
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}

if (!(Test-Path $fx)) {
  throw "Still missing FXServer.exe at $fx after install."
}

# Run from txData (txAdmin expects this)
Set-Location $tx

# Start server (txAdmin mode) - quote args for safety
& $fx +set "txAdminInterface" "$iface" +set "txAdminPort" "$txaPort"
