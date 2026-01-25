# install-fxserver.ps1
$ErrorActionPreference = "Stop"

$root = $env:FIVEM_ROOT; if (-not $root) { $root = "C:\FiveM" }
$artifacts = $env:ARTIFACTS_DIR; if (-not $artifacts) { $artifacts = Join-Path $root "artifacts" }

$fxExe = Join-Path $artifacts "FXServer.exe"

New-Item -ItemType Directory -Force -Path $root | Out-Null
New-Item -ItemType Directory -Force -Path $artifacts | Out-Null

Write-Host "INSTALL: root=$root"
Write-Host "INSTALL: artifacts=$artifacts"
Write-Host "INSTALL: fxExe=$fxExe"

if (Test-Path $fxExe) {
  Write-Host "FXServer already installed at $fxExe - skipping."
  exit 0
}

function Get-LatestRecommended7zUrl {
  $indexUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/"
  Write-Host "Fetching artifacts index: $indexUrl"

  $html = (Invoke-WebRequest -UseBasicParsing -Uri $indexUrl).Content

  # Robust: find the section containing "LATEST RECOMMENDED", then find the first server.7z href after it
  $idx = $html.IndexOf("LATEST RECOMMENDED")
  if ($idx -lt 0) { throw "Could not find 'LATEST RECOMMENDED' on artifacts page." }

  $tail = $html.Substring($idx)
  $m = [regex]::Match($tail, 'href="([^"]*server\.7z)"', 'Singleline,IgnoreCase')
  if (-not $m.Success) { throw "Could not find server.7z link under LATEST RECOMMENDED." }

  $href = $m.Groups[1].Value
  if ($href -notmatch '^https?://') {
    $href = ($indexUrl.TrimEnd('/') + "/" + $href.TrimStart('/'))
  }
  return $href
}

function Ensure-7zr {
  param([string]$SevenPath)
  if (Test-Path $SevenPath) { return }

  $url = "https://www.7-zip.org/a/7zr.exe"
  Write-Host "Downloading extractor: $url -> $SevenPath"
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $SevenPath

  if (!(Test-Path $SevenPath)) {
    throw "Failed to download 7zr.exe to $SevenPath"
  }
}

# Allow pinning/override if you want
$artifactUrl = $env:FXSERVER_ARTIFACT_URL
if (-not $artifactUrl) { $artifactUrl = Get-LatestRecommended7zUrl }

Write-Host "Downloading FXServer artifact: $artifactUrl"

$temp7z = Join-Path $env:TEMP "fxserver.7z"
if (Test-Path $temp7z) { Remove-Item $temp7z -Force -ErrorAction SilentlyContinue }

Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $temp7z
Write-Host "Downloaded: $temp7z ($(Get-Item $temp7z).Length bytes)"

# Clean artifacts folder
Write-Host "Cleaning artifacts dir: $artifacts"
Get-ChildItem -Path $artifacts -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Extract with 7zr
$seven = Join-Path $env:TEMP "7zr.exe"
Ensure-7zr -SevenPath $seven

Write-Host "Extracting: $temp7z -> $artifacts"
& $seven x -y "-o$artifacts" $temp7z | Out-Host

Remove-Item $temp7z -Force -ErrorAction SilentlyContinue

Write-Host "Post-extract listing (top 30):"
Get-ChildItem -Path $artifacts -Force | Select-Object -First 30 Name,Length | Format-Table -AutoSize | Out-String | Write-Host

if (!(Test-Path $fxExe)) {
  throw "Install finished but FXServer.exe not found at $fxExe"
}

Write-Host "FXServer installed OK: $fxExe"
