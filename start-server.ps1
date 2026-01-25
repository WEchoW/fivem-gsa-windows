# start-server.ps1
$ErrorActionPreference = "Stop"

$fivemHome = $env:FIVEM_HOME
if (-not $fivemHome) { $fivemHome = "C:\fivem" }

$fx = Join-Path $fivemHome "server\FXServer.exe"

# Data path (txAdmin)
$tx = $env:TXDATA
if (-not $tx) { $tx = "C:\txdata" }

New-Item -ItemType Directory -Force -Path $tx | Out-Null
Set-Location $tx

# Ensure basic structure (optional but helpful)
New-Item -ItemType Directory -Force -Path (Join-Path $tx "resources") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tx "cache") | Out-Null

# txAdmin interface + port
$iface = $env:TXHOST_INTERFACE
if (-not $iface) { $iface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

Write-Host "DEBUG TXHOST_TXA_PORT=[$($env:TXHOST_TXA_PORT)] TXHOST_INTERFACE=[$($env:TXHOST_INTERFACE)]"
Write-Host "DEBUG FIVEM_HOME=[$fivemHome] TXDATA=[$tx]"
Write-Host "Starting txAdmin on ${iface}:${txaPort} (TXDATA=$tx)"

# Auto-install FXServer into mounted C:\fivem if missing
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}

if (!(Test-Path $fx)) {
  Write-Host "ERROR: Still missing FXServer.exe at $fx after install."
  if (Test-Path (Split-Path $fx -Parent)) {
    Get-ChildItem (Split-Path $fx -Parent) -Force | Format-Table -AutoSize | Out-String | Write-Host
  }
  exit 1
}

# Start server (txAdmin mode)
& $fx `
  +set "txAdminInterface" "$iface" `
  +set "txAdminPort" "$txaPort"
