# C:\bootstrap.ps1
$bad = "C:\gsa\start-server.ps1"

# Wait up to 10s for GSA to create it
for ($i=0; $i -lt 20; $i++) {
  if (Test-Path $bad) { break }
  Start-Sleep -Milliseconds 500
}

if (Test-Path $bad) {
  Write-Host "Patching GSA start-server.ps1..."
  (Get-Content $bad) `
    -replace '\$iface:\$txaPort','${iface}:${txaPort}' `
    | Set-Content $bad
} else {
  Write-Host "start-server.ps1 not found; continuing anyway"
}

# Run whatever is there now
powershell -NoProfile -ExecutionPolicy Bypass -File $bad
