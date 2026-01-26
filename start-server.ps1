# start-server.ps1 — FINAL STABLE (FXServer + txAdmin)

$ErrorActionPreference = "Stop"

# --- Required env vars (GSA expects these) ---
$required = @(
  "FIVEM_ROOT","ARTIFACTS_DIR","TXDATA",
  "TXHOST_INTERFACE","TXHOST_TXA_PORT",
  "FIVEM_GAME_INTERFACE","FIVEM_GAME_PORT"
)

foreach ($k in $required) {
  $v = [Environment]::GetEnvironmentVariable($k)
  if ([string]::IsNullOrWhiteSpace($v)) {
    Write-Host "Missing env var: $k"
    exit 1
  }
}

$root      = $env:FIVEM_ROOT
$artifacts = $env:ARTIFACTS_DIR
$tx        = $env:TXDATA

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null
New-Item -ItemType Directory -Force -Path $tx | Out-Null

$fx = Join-Path $artifacts "FXServer.exe"

# Ensure FXServer exists
if (!(Test-Path $fx)) {
  Write-Host "Installing FXServer artifacts..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) { throw "FXServer.exe still missing after install." }

$gameIface = $env:FIVEM_GAME_INTERFACE
$gamePort  = [int]$env:FIVEM_GAME_PORT
$endpoint  = "$gameIface`:$gamePort"

$txIface = $env:TXHOST_INTERFACE
$txaPort = [int]$env:TXHOST_TXA_PORT

Write-Host "Starting FXServer with txAdmin..."
Write-Host " Game: $endpoint"
Write-Host " txAdmin: $txIface`:$txaPort"

Set-Location $tx

& $fx `
  +set txAdminInterface "$txIface" `
  +set txAdminPort "$txaPort" `
  +set endpoint_add_tcp "$endpoint" `
  +set endpoint_add_udp "$endpoint"
