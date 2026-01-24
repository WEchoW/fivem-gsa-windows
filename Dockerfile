FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# IMPORTANT: escape backslashes so \t, \f aren't treated like escapes
ENV FIVEM_HOME="C:\\fivem" `
    TXDATA="C:\\txdata" `
    TXADMIN_PORT="40120"

WORKDIR C:\gsa

# Make base dirs (single RUN, no stray lines)
RUN New-Item -ItemType Directory -Force -Path "C:\\gsa" | Out-Null; `
    New-Item -ItemType Directory -Force -Path $env:FIVEM_HOME | Out-Null; `
    New-Item -ItemType Directory -Force -Path $env:TXDATA | Out-Null

# Copy scripts
COPY install-fxserver.ps1 C:\gsa\install-fxserver.ps1
COPY start-server.ps1     C:\gsa\start-server.ps1

# Install FXServer (your script handles downloading/extracting)
RUN powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\gsa\install-fxserver.ps1

# Ports are informational; GSA does actual mapping
EXPOSE 31120/udp 31120/tcp 31121/tcp 40120/tcp 41120/tcp 42120/tcp

ENTRYPOINT ["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\gsa\\start-server.ps1"]
