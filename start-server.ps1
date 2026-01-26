# C:\gsa\start-server.ps1
$ErrorActionPreference = "Stop"

$homeRoot = $env:HOME_ROOT
if ([string]::IsNullOrWhiteSpace($homeRoot)) { $homeRoot = "C:\gsa" }

Write-Host "HOME_ROOT: $homeRoot"

$serverfiles = Join-Path $homeRoot "serverfiles"
$artifacts   = Join-Path $serverfiles "artifacts"
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$fxExe = Join-Path $artifacts "FXServer.exe"

if (!(Test-Path $fxExe)) {
  $artifactUrl = $env:ARTIFACT_URL
  if ([string]::IsNullOrWhiteSpace($artifactUrl)) { throw "ARTIFACT_URL env var is not set." }

  Write-Host "Downloading FiveM artifact..."
  $tmp7z = Join-Path $env:TEMP "server.7z"
  curl.exe -L -o $tmp7z $artifactUrl

  Write-Host "Extracting to $artifacts"
  & C:\tools\7zr.exe x $tmp7z "-o$artifacts" -y | Out-Null
  Remove-Item $tmp7z -Force -ErrorAction SilentlyContinue

  try {
    Get-ChildItem -Path $artifacts -Recurse -File -ErrorAction SilentlyContinue |
      Unblock-File -ErrorAction SilentlyContinue
  } catch { }

  if (!(Test-Path $fxExe)) {
    throw "FXServer.exe not found after extraction into $artifacts"
  }
}

Set-Location $artifacts

$txPort = $env:TXADMIN_PORT
if ([string]::IsNullOrWhiteSpace($txPort)) { $txPort = "40120" }

$fivemPort = $env:FIVEM_PORT
if ([string]::IsNullOrWhiteSpace($fivemPort)) { $fivemPort = "30120" }

Write-Host "Starting FXServer (txAdmin wizard mode)"
Write-Host "FXServer port: $fivemPort"
Write-Host "txAdmin port: $txPort"
Write-Host "Artifacts: $artifacts"

& .\FXServer.exe +set netPort $fivemPort +set txAdminPort $txPort
exit $LASTEXITCODE
