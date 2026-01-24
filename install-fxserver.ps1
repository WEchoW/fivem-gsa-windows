# install-fxserver.ps1
$ErrorActionPreference = "Stop"

# Ensure TLS 1.2
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

# Configurable artifact URL
$zipUrl = $env:FXSERVER_ARTIFACT_URL
if (-not $zipUrl) {
  $zipUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"
}

Write-Host "FXServer artifact URL: $zipUrl"

$serverRoot   = "C:\fivem\server"
$tempDir      = "C:\temp"
$sevenZipDir  = "C:\7zip"
$sevenZipExe  = Join-Path $sevenZipDir "7zr.exe"

New-Item -ItemType Directory -Force -Path $serverRoot  | Out-Null
New-Item -ItemType Directory -Force -Path $tempDir     | Out-Null
New-Item -ItemType Directory -Force -Path $sevenZipDir | Out-Null

# VC++ Runtime
$vcUrl  = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcPath = Join-Path $tempDir "vc_redist.x64.exe"
Invoke-WebRequest -Uri $vcUrl -OutFile $vcPath -UseBasicParsing
Start-Process -FilePath $vcPath -ArgumentList "/install","/quiet","/norestart" -Wait

# 7-Zip extractor
$sevenZipUrl = "https://www.7-zip.org/a/7zr.exe"
Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipExe -UseBasicParsing

# Download FXServer
$artifactPath = Join-Path $tempDir "server.7z"
Invoke-WebRequest -Uri $zipUrl -OutFile $artifactPath -UseBasicParsing

# Extract
& $sevenZipExe x $artifactPath "-o$serverRoot" -y | Out-Null

$fx = Join-Path $serverRoot "FXServer.exe"
if (!(Test-Path $fx)) {
  Write-Host "ERROR: FXServer.exe not found after extraction."
  Write-Host "Contents of ${serverRoot}:"
  Get-ChildItem $serverRoot -Force | Format-Table -AutoSize | Out-String | Write-Host
  throw "FXServer.exe missing"
}

Write-Host "FXServer installed successfully at $fx"
