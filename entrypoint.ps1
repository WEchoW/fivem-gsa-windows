$ErrorActionPreference = "Stop"

# {container.home_root}
$homeRoot = $env:HOME_ROOT
if ([string]::IsNullOrWhiteSpace($homeRoot)) {
  # Default inside container
  $homeRoot = "C:\gsa"
}

$serverfiles = Join-Path $homeRoot "serverfiles"
$artifacts   = Join-Path $serverfiles "artifacts"

New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$fxExe = Join-Path $artifacts "FXServer.exe"

# Download/extract if missing (idempotent)
if (!(Test-Path $fxExe)) {
  $artifactUrl = $env:ARTIFACT_URL
  if ([string]::IsNullOrWhiteSpace($artifactUrl)) {
    throw "ARTIFACT_URL env var is not set."
  }

  Write-Host "FXServer.exe not found. Downloading artifact..."
  $tmp7z = Join-Path $env:TEMP "server.7z"
  curl.exe -L -o $tmp7z $artifactUrl

  Write-Host "Extracting to: $artifacts"
  & C:\tools\7zr.exe x $tmp7z "-o$artifacts" -y | Out-Null

  Remove-Item $tmp7z -Force -ErrorAction SilentlyContinue

  if (!(Test-Path $fxExe)) {
    throw "Extraction finished but FXServer.exe still not found in $artifacts"
  }
}

# Run from within artifacts folder (your “run the folder artifacts” requirement)
Set-Location $artifacts

# Match your txAdmin port requirement
$txPort = $env:TXADMIN_PORT
if ([string]::IsNullOrWhiteSpace($txPort)) { $txPort = "40120" }

Write-Host "Starting FXServer (no +exec; txAdmin wizard mode)."
Write-Host "Artifacts: $artifacts"
Write-Host "txAdmin port: $txPort"
Write-Host "NOTE: Logs are stdout only."

# IMPORTANT: do not pass +exec server.cfg
.\FXServer.exe +set txAdminPort $txPort
