# start-server.ps1 (txAdmin on 40120, GSA-synced, non-deprecated convars)
$ErrorActionPreference = "Stop"

# ---- REQUIRED ENVS (GSA verify expects these) ----
$required = @(
  "FIVEM_ROOT","ARTIFACTS_DIR","TXDATA",
  "TXHOST_INTERFACE","TXHOST_TXA_PORT",
  "FIVEM_GAME_INTERFACE","FIVEM_GAME_PORT"
)

foreach ($k in $required) {
  $v = [Environment]::GetEnvironmentVariable($k)
  if ([string]::IsNullOrWhiteSpace($v)) {
    Write-Host "Missing expected env var: $k"
    exit 1
  }
}

$root      = $env:FIVEM_ROOT
$artifacts = $env:ARTIFACTS_DIR
$tx        = $env:TXDATA

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null
New-Item -ItemType Directory -Force -Path $tx | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $tx "temp") | Out-Null

$fx = Join-Path $artifacts "FXServer.exe"

$gameIface = $env:FIVEM_GAME_INTERFACE
$gamePort  = [int]$env:FIVEM_GAME_PORT
$endpoint  = "$gameIface`:$gamePort"

# Force txAdmin to 40120 (per your requirement)
$txIface = $env:TXHOST_INTERFACE
$txaPort = 40120

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "DEBUG Game endpoint_add_tcp/udp=[$endpoint]"
Write-Host "DEBUG txAdmin bind (forced)=[$txIface`:$txaPort]"

# Ensure FXServer exists
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) { throw "Still missing FXServer.exe at $fx after install." }

# Start FXServer (txAdmin is bundled). Use NON-deprecated convars.
Set-Location $tx

& $fx `
  +set sv_txAdminInterface "$txIface" `
  +set sv_txAdminPort "$txaPort" `
  +set endpoint_add_tcp "$endpoint" `
  +set endpoint_add_udp "$endpoint"
