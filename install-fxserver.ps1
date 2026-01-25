# install-fxserver.ps1
$ErrorActionPreference = "Stop"

$root = $env:FIVEM_ROOT; if (-not $root) { $root = "C:\FiveM" }
$artifacts = $env:ARTIFACTS_DIR; if (-not $artifacts) { $artifacts = Join-Path $root "artifacts" }
$fxExe = Join-Path $artifacts "FXServer.exe"

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

Write-Host "Installing pinned FXServer build"
Write-Host "Artifacts dir: $artifacts"
Write-Host "FX exe path: $fxExe"

if (Test-Path $fxExe) {
  Write-Host "FXServer already installed - skipping."
  exit 0
}

$artifactUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"

Write-Host "Downloading: $artifactUrl"

$temp7z = Join-Path $env:TEMP "fxserver.7z"
if (Test-Path $temp7z) { Remove-Item $temp7z -Force -ErrorAction SilentlyContinue }

Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $temp7z

# Clean old artifacts
Get-ChildItem -Path $artifacts -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Download 7zr if needed
$seven = Join-Path $env:TEMP "7zr.exe"
if (!(Test-Path $seven)) {
  Invoke-WebRequest -UseBasicParsing -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile $seven
}

Write-Host "Extracting..."
& $seven x -y "-o$artifacts" $temp7z | Out-Host

Remove-Item $temp7z -Force -ErrorAction SilentlyContinue

if (!(Test-Path $fxExe)) {
  throw "FXServer.exe not found after extraction"
}

Write-Host "Pinned FXServer installed successfully."
