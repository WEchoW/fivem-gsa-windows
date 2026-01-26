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

$txIface = $env:TXHOST_INTERFACE
if (-not $txIface) { $txIface = "0.0.0.0" }

$txaPort = $env:TXHOST_TXA_PORT
if (-not $txaPort) { $txaPort = "40120" }
$txaPort = [int]$txaPort

$gameIface = $env:FIVEM_GAME_INTERFACE
if (-not $gameIface) { $gameIface = "0.0.0.0" }

$gamePort = $env:FIVEM_GAME_PORT
if (-not $gamePort) { $gamePort = "30120" }
$gamePort = [int]$gamePort

$endpoint = "$gameIface`:$gamePort"

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "DEBUG Game endpoint_add_tcp/udp=[$endpoint]"
Write-Host "DEBUG txAdmin bind (env)=[$txIface`:$txaPort] (TXDATA=$tx)"

# Ensure FXServer exists (installer)
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) {
  throw "Still missing FXServer.exe at $fx after install."
}

# ---- Start txAdmin (DO NOT start FXServer directly) ----
# txAdmin in modern artifacts is Node-based. Try common locations.
$node = Join-Path $artifacts "node\node.exe"
$txMain1 = Join-Path $artifacts "txAdmin\main.js"
$txMain2 = Join-Path $artifacts "citizen\system_resources\monitor\txAdmin\main.js"

# Fallback: search for node.exe and txAdmin main.js
if (!(Test-Path $node)) {
  $nodeFound = Get-ChildItem -Path $artifacts -Recurse -Filter "node.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($nodeFound) { $node = $nodeFound.FullName }
}
if (!(Test-Path $txMain1)) {
  $mainFound = Get-ChildItem -Path $artifacts -Recurse -Filter "main.js" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "txAdmin\\main\.js$" } | Select-Object -First 1
  if ($mainFound) { $txMain1 = $mainFound.FullName }
}

# Decide which txAdmin entry to use
$txMain = $null
if (Test-Path $txMain1) { $txMain = $txMain1 }
elseif (Test-Path $txMain2) { $txMain = $txMain2 }

if (!(Test-Path $node) -or -not $txMain) {
  throw "Could not locate txAdmin entrypoint. node=[$node] txMain=[$txMain]. Artifacts dir: $artifacts"
}

Write-Host "Starting txAdmin via:"
Write-Host "  node=[$node]"
Write-Host "  txMain=[$txMain]"
Write-Host "  txData=[$tx]"

# IMPORTANT:
# - We do NOT pass endpoint_add_* here; txAdmin will launch FXServer with the correct args.
# - TXHOST_* env vars control txAdmin bind/port.
Set-Location $artifacts

& $node $txMain --txData "$tx"
