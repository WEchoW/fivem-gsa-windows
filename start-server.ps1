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

# --- Pick txAdmin port ---
# Preferred: new txAdmin env var
$txaPort = $env:TXHOST_TXA_PORT

# Fallback: old env var (if you set it manually)
if (-not $txaPort) { $txaPort = $env:TXADMIN_PORT }

# Fallback: GSA "other" port (auto-assigned by panel)
# Commonly exposed by panels as GSA_PORT_OTHER; harmless if missing.
if (-not $txaPort) { $txaPort = $env:GSA_PORT_OTHER }

# Final fallback
if (-not $txaPort) { $txaPort = "40120" }

Write-Host "=================================================="
Write-Host "Starting FXServer (txAdmin first-run mode)"
Write-Host "TXDATA: $tx"
Write-Host "txAdmin bind: 0.0.0.0"
Write-Host "txAdmin port: $txaPort"
Write-Host "=================================================="

# Start txAdmin mode
& $fx +set txAdminInterface 0.0.0.0 +set txAdminPort $txaPort
