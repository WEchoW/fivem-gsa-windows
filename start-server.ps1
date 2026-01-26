# start-server.gsa.ps1
$ErrorActionPreference = "Stop"

# ---- REQUIRED ENVS (GSA verify) ----
$required = @(
  "FIVEM_ROOT","ARTIFACTS_DIR","TXDATA",
  "TXHOST_INTERFACE","TXHOST_TXA_PORT",
  "FIVEM_GAME_INTERFACE","FIVEM_GAME_PORT"
)

$missing = @()
foreach ($k in $required) {
  $v = [Environment]::GetEnvironmentVariable($k)
  if ([string]::IsNullOrWhiteSpace($v)) { $missing += $k }
}
if ($missing.Count -gt 0) {
  Write-Host "Missing expected env vars: $($missing -join ', ')"
  exit 1
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

Write-Host "DEBUG FIVEM_ROOT=[$root] ARTIFACTS_DIR=[$artifacts] TXDATA=[$tx]"
Write-Host "DEBUG Game endpoint_add_tcp/udp=[$endpoint]"
Write-Host "DEBUG txAdmin bind (env)=[$($env:TXHOST_INTERFACE):$($env:TXHOST_TXA_PORT)]"

# Ensure FXServer exists
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) { throw "Still missing FXServer.exe at $fx after install." }

# --- Try to locate txAdmin (optional) ---
$node   = Join-Path $artifacts "node\node.exe"
$txMain = $null

# common txAdmin locations (if present)
$txCandidates = @(
  (Join-Path $artifacts "txAdmin\main.js"),
  (Join-Path $artifacts "citizen\system_resources\monitor\txAdmin\main.js")
)

foreach ($c in $txCandidates) {
  if (Test-Path $c) { $txMain = $c; break }
}

# If txAdmin is NOT present, fall back to FXServer direct (do NOT crash)
if (-not $txMain -or !(Test-Path $node)) {
  Write-Host "txAdmin not present in artifacts. Starting FXServer directly (no txAdmin heartbeat)."
  Set-Location $tx
  & $fx +set "endpoint_add_tcp" "$endpoint" +set "endpoint_add_udp" "$endpoint"
  exit $LASTEXITCODE
}

# If txAdmin IS present, start it (txAdmin will spawn FXServer)
Write-Host "Starting txAdmin via node:"
Write-Host "  node=[$node]"
Write-Host "  txMain=[$txMain]"
Write-Host "  --txData $tx"
Set-Location $artifacts
& $node $txMain --txData "$tx"
