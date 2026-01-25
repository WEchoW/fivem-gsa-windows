# install-fxserver.ps1 (PINNED)
$ErrorActionPreference = "Stop"

$root = $env:FIVEM_ROOT; if (-not $root) { $root = "C:\FiveM" }
$artifacts = $env:ARTIFACTS_DIR; if (-not $artifacts) { $artifacts = Join-Path $root "artifacts" }

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

$fxExe = Join-Path $artifacts "FXServer.exe"

Write-Host "INSTALL: FIVEM_ROOT=$root"
Write-Host "INSTALL: ARTIFACTS_DIR=$artifacts"
Write-Host "INSTALL: fxExe=$fxExe"

# If you ever want to force reinstall, set FORCE_ARTIFACT_UPDATE=1 in blueprint
$force = $env:FORCE_ARTIFACT_UPDATE
if ((Test-Path $fxExe) -and ($force -ne "1")) {
  Write-Host "FXServer already present - skipping."
  exit 0
}

if ($force -eq "1") {
  Write-Host "FORCE_ARTIFACT_UPDATE=1 -> reinstalling artifacts."
}

# Your pinned artifact URL:
$artifactUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"
Write-Host "Downloading pinned artifact: $artifactUrl"

$temp7z = Join-Path $env:TEMP "fxserver.7z"
if (Test-Path $temp7z) { Remove-Item $temp7z -Force -ErrorAction SilentlyContinue }
Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $temp7z

# Clean artifacts dir
Get-ChildItem -Path $artifacts -Force -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Ensure 7zr
$seven = Join-Path $env:TEMP "7zr.exe"
if (!(Test-Path $seven)) {
  Invoke-WebRequest -UseBasicParsing -Uri "https://www.7-zip.org/a/7zr.exe" -OutFile $seven
}

Write-Host "Extracting -> $artifacts"
& $seven x -y "-o$artifacts" $temp7z | Out-Host

Remove-Item $temp7z -Force -ErrorAction SilentlyContinue

if (!(Test-Path $fxExe)) {
  throw "Install finished but FXServer.exe not found at $fxExe"
}

Write-Host "FXServer installed OK: $fxExe"
