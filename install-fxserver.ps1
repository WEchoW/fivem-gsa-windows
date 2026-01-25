# install-fxserver.gsa.ps1
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = $env:FIVEM_ROOT
if (-not $root) { $root = "C:\FiveM" }

$artifacts = $env:ARTIFACTS_DIR
if (-not $artifacts) { $artifacts = Join-Path $root "artifacts" }

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$fxExe = Join-Path $artifacts "FXServer.exe"

$force = $env:FORCE_ARTIFACT_UPDATE
if ((Test-Path $fxExe) -and ($force -ne "1")) {
  Write-Host "FXServer already present at $fxExe - skipping."
  exit 0
}

$defaultArtifactUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"
$artifactUrl = $env:ARTIFACT_URL
if (-not $artifactUrl) { $artifactUrl = $defaultArtifactUrl }

Write-Host "Downloading FXServer artifact: $artifactUrl"

$temp7z = Join-Path $env:TEMP "fxserver.7z"
if (Test-Path $temp7z) { Remove-Item $temp7z -Force -ErrorAction SilentlyContinue }

Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $temp7z
if (!(Test-Path $temp7z)) { throw "Download failed: $temp7z was not created." }

Get-ChildItem -Path $artifacts -Force -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

$seven = Join-Path $env:TEMP "7zr.exe"
if (!(Test-Path $seven)) {
  $sevenUrl = "https://www.7-zip.org/a/7zr.exe"
  Write-Host "Downloading extractor: $sevenUrl"
  Invoke-WebRequest -UseBasicParsing -Uri $sevenUrl -OutFile $seven
}
if (!(Test-Path $seven)) { throw "Failed to download 7zr.exe to $seven" }

Write-Host "Extracting -> $artifacts"
& $seven x -y "-o$artifacts" $temp7z | Out-Host

Remove-Item $temp7z -Force -ErrorAction SilentlyContinue

if (!(Test-Path $fxExe)) {
  Write-Host "Artifacts directory contents:"
  Get-ChildItem -Path $artifacts -Force | Select-Object -First 50 Name,Length | Format-Table -AutoSize | Out-String | Write-Host
  throw "Install finished but FXServer.exe not found at $fxExe"
}

Write-Host "FXServer installed OK: $fxExe"
