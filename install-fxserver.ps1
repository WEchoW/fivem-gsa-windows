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

function Get-LatestArtifactZipUrl {
  param(
    [Parameter(Mandatory=$true)][ValidateSet("recommended","master")] $Channel
  )

  # These endpoints are commonly used for FiveM artifacts
  $base =
    if ($Channel -eq "recommended") {
      "https://runtime.fivem.net/artifacts/fivem/build_server_windows/recommended/"
    } else {
      "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/"
    }

  Write-Host "Fetching artifacts index: $base"
  $html = (Invoke-WebRequest -UseBasicParsing -Uri $base).Content

  # Find all .zip links and choose the last/highest one (page is typically sorted ascending)
  $zipLinks = [regex]::Matches($html, 'href="([^"]+\.zip)"') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique
  if (-not $zipLinks -or $zipLinks.Count -lt 1) {
    throw "Could not find any .zip artifacts at $base"
  }

  # Prefer server.zip if present, otherwise any zip
  $preferred = $zipLinks | Where-Object { $_ -match 'server.*\.zip$' }
  $pick = if ($preferred.Count -gt 0) { $preferred[-1] } else { $zipLinks[-1] }

  # If link is relative, make it absolute
  if ($pick -notmatch '^https?://') {
    return ($base.TrimEnd('/') + "/" + $pick.TrimStart('/'))
  }
  return $pick
}

# Allow direct override
$artifactUrl = $env:FXSERVER_ARTIFACT_URL
$channel = $env:FXSERVER_CHANNEL
if (-not $channel) { $channel = "recommended" }

if (-not $artifactUrl) {
  $artifactUrl = Get-LatestArtifactZipUrl -Channel $channel
}

Write-Host "Downloading FXServer artifact: $artifactUrl"

$tempZip = Join-Path $env:TEMP "fxserver.zip"
if (Test-Path $tempZip) { Remove-Item $tempZip -Force -ErrorAction SilentlyContinue }

Invoke-WebRequest -UseBasicParsing -Uri $artifactUrl -OutFile $tempZip

# Clean existing server dir (but keep folder)
Get-ChildItem -Path $serverDir -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Extracting to: $serverDir"
Expand-Archive -Path $tempZip -DestinationPath $serverDir -Force

Remove-Item $tempZip -Force -ErrorAction SilentlyContinue

if (!(Test-Path $fxExe)) {
  Write-Host "Directory contents:"
  Get-ChildItem $serverDir -Force | Format-Table -AutoSize | Out-String | Write-Host
  throw "Install finished but FXServer.exe not found at $fxExe"
}

Write-Host "FXServer installed OK: $fxExe"
