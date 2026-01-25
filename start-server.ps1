# start-server.ps1
# GSA-synced start script for FiveM (Windows) + txAdmin
#
# Blueprint should set:
#   TXHOST_INTERFACE=0.0.0.0
#   TXHOST_TXA_PORT={gameserver.rcon_port}  (stable, because you pin the RCON port in GSA UI)
#   FIVEM_GAME_INTERFACE=0.0.0.0
#   FIVEM_GAME_PORT={gameserver.game_port}
#
# IMPORTANT:
# - Do NOT pass deprecated txAdminPort/txAdminInterface ConVars.
# - txAdmin reads TXHOST_* environment variables.

$ErrorActionPreference = "Stop"

# --- Paths (defaults can be overridden by GSA env vars)
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

# --- txAdmin bind (from env; should be set by GSA blueprint)
$txIface = $env:TXHOST_INTERFACE
if (-not $txIface) { $txIface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

# --- Game bind (from env; should be set by GSA blueprint)
$gameIface = $env:FIVEM_GAME_INTERFACE
if (-not $gameIface) { $gameIface = "0.0.0.0" }

$gamePort = $env:FIVEM_GAME_PORT
if (-not $gamePort) { $gamePort = "30120" }
$gamePort = [int]$gamePort

$endpoint = "$gameIface`:$gamePort"

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "DEBUG Game endpoint_add_tcp/udp=[$endpoint]"
Write-Host "DEBUG txAdmin bind (env)=[$txIface`:$txaPort] (TXDATA=$tx)"

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

# Start FXServer; txAdmin reads TXHOST_* env vars automatically.
& $fx +set "endpoint_add_tcp" "$endpoint" +set "endpoint_add_udp" "$endpoint"
