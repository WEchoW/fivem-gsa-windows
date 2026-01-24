FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# Use escaped backslashes so Dockerfile parsing doesn't treat \t, \f as escapes
ENV FIVEM_HOME="C:\\fivem"
ENV TXDATA="C:\\txdata"
ENV TXADMIN_PORT="40120"

# Base folders
RUN New-Item -ItemType Directory -Force -Path "C:\\gsa" | Out-Null; `
    New-Item -ItemType Directory -Force -Path $env:FIVEM_HOME | Out-Null; `
    New-Item -ItemType Directory -Force -Path $env:TXDATA | Out-Null

# Copy + run installer (this script downloads and extracts FXServer)
COPY install-fxserver.ps1 C:\\gsa\\install-fxserver.ps1
RUN powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\\gsa\\install-fxserver.ps1

# VC++ runtime (common requirement)
RUN Invoke-WebRequest "https://aka.ms/vs/16/release/VC_redist.x64.exe" -OutFile "C:\\gsa\\VC_redist.x64.exe"; `
    Start-Process "C:\\gsa\\VC_redist.x64.exe" -ArgumentList "/install","/quiet","/norestart" -Wait

# Start script
COPY start-server.ps1 C:\\gsa\\start-server.ps1

# Ports are documentation; GSA maps ports externally
EXPOSE 31120/udp 31120/tcp 31121/tcp 40120/tcp 41120/tcp 42120/tcp

ENTRYPOINT ["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\gsa\\start-server.ps1"]
