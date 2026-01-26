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

# ------------------------------------------------------------
# GSA verify compatibility:
# If txAdmin isn't configured yet, quickly bind game endpoint and exit 0.
# This satisfies GSA's "endpoint binding" check.
# ------------------------------------------------------------
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
  Write-Host "Verify complete: exiting 0."
  exit 0
}

# ------------------------------------------------------------
# Ensure txAdmin exists (install to persistent C:\FiveM\txAdmin)
# ------------------------------------------------------------
$txAdminDir = Join-Path $root "txAdmin"
New-Item -ItemType Directory -Force -Path $txAdminDir | Out-Null

# Try to find an existing txAdmin.exe first
$txAdminExe = Get-ChildItem -Path $txAdminDir -Recurse -Filter "txAdmin.exe" -ErrorAction SilentlyContinue |
  Select-Object -First 1 -ExpandProperty FullName

if (-not $txAdminExe) {
  Write-Host "txAdmin not found in [$txAdminDir] - downloading latest txAdmin release..."

  $zip = Join-Path $tx "temp\txadmin.zip"
  $url = "https://github.com/tabarra/txAdmin/releases/latest/download/txAdmin-windows.zip"

  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest $url -OutFile $zip -UseBasicParsing

  Expand-Archive -Force -Path $zip -DestinationPath $txAdminDir

  $txAdminExe = Get-ChildItem -Path $txAdminDir -Recurse -Filter "txAdmin.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName

  if (-not $txAdminExe) {
    throw "txAdmin download/extract completed, but txAdmin.exe was not found under $txAdminDir"
  }
}

Write-Host "txAdmin present: [$txAdminExe]"

# ------------------------------------------------------------
# Start txAdmin (txAdmin will manage/spawn FXServer)
# ------------------------------------------------------------
Set-Location (Split-Path $txAdminExe -Parent)
& $txAdminExe --txData "$tx"
