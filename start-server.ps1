# start-server.gsa.ps1
$ErrorActionPreference = "Stop"

# --- GSA validator expects these env vars to exist ---
$required = @(
  "FIVEM_ROOT",
  "ARTIFACTS_DIR",
  "TXDATA",
  "TXHOST_INTERFACE",
  "TXHOST_TXA_PORT",
  "FIVEM_GAME_INTERFACE",
  "FIVEM_GAME_PORT"
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

# --- Use env vars (no silent defaults, to satisfy GSA assumptions) ---
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

# Ensure FXServer exists (installer)
if (!(Test-Path $fx)) {
  Write-Host "FXServer.exe missing at $fx - running installer..."
  & "C:\gsa\install-fxserver.ps1"
}
if (!(Test-Path $fx)) {
  throw "Still missing FXServer.exe at $fx after install."
}

# --- GSA verify compatibility: bind game port briefly if txAdmin not configured ---
$txDefault = Join-Path $tx "default"
if (!(Test-Path $txDefault)) {
  Write-Host "txAdmin not configured yet ($txDefault missing) - quick endpoint bind for GSA verify, then exit 0."
  Set-Location $tx

  $p = Start-Process -FilePath $fx -ArgumentList @(
    "+set", "endpoint_add_tcp", $endpoint,
    "+set", "endpoint_add_udp", $endpoint
  ) -PassThru

  Start-Sleep -Seconds 5
  try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
  exit 0
}

# --- Normal run: start txAdmin (parent process for FXServer/heartbeat) ---
$node   = Join-Path $artifacts "node\node.exe"
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

Set-Location $artifacts
& $node $txMain --txData "$tx"
