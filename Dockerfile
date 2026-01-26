FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Use PowerShell for build steps
SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# ---- URLs (pinned for repeatable builds) ----
ARG FIVEM_ARTIFACT_URL="https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z"
ARG VCREDIST_URL="https://aka.ms/vs/16/release/VC_redist.x64.exe"

# ---- Download artifact + tools ----
RUN $ErrorActionPreference='Stop' ; \
    Invoke-WebRequest -UseBasicParsing $env:FIVEM_ARTIFACT_URL -OutFile 'server.7z' ; \
    Invoke-WebRequest -UseBasicParsing $env:VCREDIST_URL -OutFile 'VC_redist.x64.exe' ; \
    Invoke-WebRequest -UseBasicParsing 'https://www.7-zip.org/a/7zr.exe' -OutFile '7zr.exe' ; \
    New-Item -ItemType Directory -Force -Path 'C:\server' | Out-Null ; \
    .\7zr.exe x .\server.7z -oC:\server -y ; \
    Remove-Item -Force .\server.7z,.\7zr.exe

# ---- Install VC++ Redist ----
SHELL ["cmd", "/S", "/C"]
RUN VC_redist.x64.exe /install /quiet /norestart && del VC_redist.x64.exe

# ---- Runtime setup ----
WORKDIR C:\\server-data
EXPOSE 30120/tcp 30120/udp

# ---- Start server (expand env vars via cmd) ----
ENTRYPOINT cmd /S /C "C:\server\FXServer.exe +set sv_licenseKey %SV_LICENSE% +exec C:\server-data\server.cfg"



