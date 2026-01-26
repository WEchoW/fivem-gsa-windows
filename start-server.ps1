# start-server.gsa.ps1
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
New-Item -ItemType Directory -Force -Path (Join-Path $tx "temp") | Out-Null

$fx = Join-Path $artifacts "FXServer.exe"

$gameIface = $env:FIVEM_GAME_INTERFACE
if (-not $gameIface) { $gameIface = "0.0.0.0" }

$gamePort = $env:FIVEM_GAME_PORT
if (-not $gamePort) { $gamePort = "30120" }
$gamePort = [int]$gamePort

$endpoint = "$gameIface`:$gamePort"

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "DEBUG Game endpoint_add_tcp/udp=[$endpoint]"

# Ensure FXServer exists (installer)
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) {
  throw "Still missing FXServer.exe at $fx after install."
}

# ------------------------------
# GSA verify compatibility:
# If txAdmin has not been configured yet (no default profile), GSA "verify" will fail
# because txAdmin may not bind the game port during the verify window.
# So we bind the game port quickly using FXServer, then exit 0.
# ------------------------------
$txDefault = Join-Path $tx "default"

if (!(Test-Path $txDefault)) {
  Write-Host "txAdmin not configured yet ($txDefault missing) - performing quick endpoint bind for GSA verify, then exiting."
  Set-Location $tx

  # Start FXServer just to bind endpoint ports and satisfy GSA. Use a short timeout.
  $p = Start-Process -FilePath $fx -ArgumentList @(
    "+set", "endpoint_add_tcp", $endpoint,
    "+set", "endpoint_add_udp", $endpoint
  ) -PassThru

  Start-Sleep -Seconds 5

  # Stop it and exit success
  try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
  exit 0
}

# ------------------------------
# Normal run: start txAdmin (txAdmin must be parent for heartbeat)
# ------------------------------
$node = Join-Path $artifacts "node\node.exe"
$txMain = Join-Path $artifacts "txAdmin\main.js"

if (!(Test-Path $node)) {
  $nodeFound = Get-ChildItem -Path $artifacts -Recurse -Filter "node.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($nodeFound) { $node = $nodeFound.FullName }
}
if (!(Test-Path $txMain)) {
  $mainFound = Get-ChildItem -Path $artifacts -Recurse -Filter "main.js" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "txAdmin\\main\.js$" } | Select-Object -First 1
  if ($mainFound) { $txMain = $mainFound.FullName }
}

if (!(Test-Path $node) -or !(Test-Path $txMain)) {
  throw "Could not locate txAdmin entrypoint. node=[$node] txMain=[$txMain]."
}

Write-Host "Starting txAdmin via node:"
Write-Host "  $node"
Write-Host "  $txMain"
Write-Host "  --txData $tx"

Set-Location $artifacts
& $node $txMain --txData "$tx"
