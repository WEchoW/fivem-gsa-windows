# install-fxserver.ps1
$ErrorActionPreference = "Stop"

# Ensure TLS 1.2 for downloads on Server Core
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

# ---- Configurable artifact URL ----
# You can override this at build/run time with:
#   -e FXSERVER_ARTIFACT_URL="https://runtime.fivem.net/artifacts/.../server.7z"
$zipUrl = $env:FXSERVER_ARTIFACT_URL
if (-not $zipUrl) {
  # Default pinned artifact (update if FiveM removes this build)
  $zipUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"
}

Write-Host "FXServer artifact URL: $zipUrl"

# ---- Paths ----
$serverRoot = "C:\fivem\server"
$tempDir    = "C:\temp"
$sevenZip   = "C:\7zip"
$sevenZipExe = Join-Path $sevenZip "7za.exe"

New-Item -ItemType Directory -Force -Path $serverRoot | Out-Null
New-Item -ItemType Directory -Force -Path $tempDir    | Out-Null
New-Item -ItemType Directory -Force -Path $sevenZip   | Out-Null

# ---- Install VC++ runtime (common requirement) ----
# This is safe to re-run (idempotent-ish)
$vcUrl  = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcPath = Join-Path $tempDir "vc_redist.x64.exe"
Write-Host "Downloading VC++ Runtime..."
Invoke-WebRequest -Uri $vcUrl -OutFile $vcPath -UseBasicParsing
Write-Host "Installing VC++ Runtime..."
Start-Process -FilePath $vcPath -ArgumentList "/install","/quiet","/norestart" -Wait

# ---- Download 7-Zip standalone (7za.exe) ----
# Using 7zr/7za keeps it simple on Server Core
$sevenZipUrl = "https://www.7-zip.org/a/7zr.exe"
$sevenZipBootstrap = Join-Path $sevenZip "7zr.exe"
Write-Host "Downloading 7-Zip extractor..."
Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipBootstrap -UseBasicParsing

# 7zr.exe can extract .7z but we want 7za.exe; easiest: use 7zr to extract a 7za bundle if present.
# However 7zr alone can extract the FXServer .7z fine, so we can just use 7zr.exe directly.
# We'll use 7zr.exe as the extractor.
$extractor = $sevenZipBootstrap

# ---- Download FXServer artifact ----
$artifactPath = Join-Path $tempDir "server.7z"
Write-Host "Downloading FXServer artifact..."
Invoke-WebRequest -Uri $zipUrl -OutFile $artifactPath -UseBasicParsing

# ---- Extract FXServer ----
Write-Host "Extracting FXServer to $serverRoot ..."
& $extractor x $artifactPath "-o$serverRoot" -y | Out-Null

# ---- Validate ----
$fx = Join-Path $serverRoot "FXServer.exe"
if (!(Test-Path $fx)) {
  Write-Host "ERROR: FXServer.exe not found after extraction."
  Write-Host "Contents of $serverRoot:"
  Get-ChildItem $serverRoot -Force | Format-Table -AutoSize | Out-String | Write-Host
  throw "FXServer.exe missing"
}

Write-Host "FXServer installed successfully at $fx"
