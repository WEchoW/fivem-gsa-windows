# install-fxserver.ps1
$ErrorActionPreference = "Stop"

$fivemHome = $env:FIVEM_HOME
if (-not $fivemHome) { $fivemHome = "C:\fivem" }

$serverDir = Join-Path $fivemHome "server"
$fxExe = Join-Path $serverDir "FXServer.exe"

New-Item -ItemType Directory -Force -Path $fivemHome | Out-Null
New-Item -ItemType Directory -Force -Path $serverDir | Out-Null

if (Test-Path $fxExe) {
  Write-Host "FXServer already installed at $fxExe - skipping."
  exit 0
}

function Get-LatestRecommendedArtifactUrl {
  # NOTE: "recommended/" endpoint can 404 now; master contains "LATEST RECOMMENDED"
  $indexUrl = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/"
  Write-Host "Fetching artifacts index: $indexUrl"

  $html = (Invoke-WebRequest -UseBasicParsing -Uri $indexUrl).Content

  # Try to find the href for "LATEST RECOMMENDED"
  # Page contains something like: LATEST RECOMMENDED (...) <a href=".../server.7z">
  $m = [regex]::Match($html, 'LATEST RECOMMENDED.*?href="([^"]*server\.7z)"', 'Singleline,IgnoreCase')

  if (-not $m.Success) {
    # fallback: first server.7z on the page
    $m = [regex]::Match($html, 'href="([^"]*server\.7z)"', 'Singleline,IgnoreCase')
  }

  if (-not $m.Success) {
    throw "Could not find server.7z link on artifacts index."
  }

  $href = $m.Groups[1].Value

  # make absolute if needed
  if ($href -notmatch '^https?://') {
    $base = $indexUrl.TrimEnd('/')
    $href = "$base/$($href.TrimStart('/'))"
  }

  return $href
}

function Ensure-7zr {
  param([string]$Path)

  if (Test-Path $Path) { return }

  # Small standalone 7zip extractor (7zr.exe) from official 7-zip site
  $url = "https://www.7-zip.org/a/7zr.exe"
  Write-Host "Downloading 7zr.exe: $url"
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $Path
}

# Allow direct override
$artifactUrl = $env:FXSERVER_ARTIFACT_URL
if (-not $artifactUrl) {
  $artifactUrl = Get-LatestRecommendedArtifactUrl
}

Write-Host "Downloading FXServer artifact: $artifactUrl"

$temp7z = Join-Path $env:TEMP "fxserver.7z"
if (Test-Path $temp7z) { Remove-Item $temp7z -Force -ErrorAction SilentlyContinue }

Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $temp7z

# Clean existing server dir contents (keep folder)
Get-ChildItem -Path $serverDir -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# Try native tar first (sometimes supports 7z via libarchive)
$extracted = $false
try {
  Write-Host "Trying extraction via tar..."
  & tar -xf $temp7z -C $serverDir
  if (Test-Path $fxExe) { $extracted = $true }
} catch {
  $extracted = $false
}

if (-not $extracted) {
  $seven = Join-Path $env:TEMP "7zr.exe"
  Ensure-7zr -Path $seven

  Write-Host "Extracting via 7zr.exe..."
  & $seven x -y "-o$serverDir" $temp7z | Out-Host
}

Remove-Item $temp7z -Force -ErrorAction SilentlyContinue

if (!(Test-Path $fxExe)) {
  Write-Host "Directory contents:"
  Get-ChildItem $serverDir -Force | Format-Table -AutoSize | Out-String | Write-Host
  throw "Install finished but FXServer.exe not found at $fxExe"
}

Write-Host "FXServer installed OK: $fxExe"
