FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

ENV FIVEM_HOME=C:\\fivem
ENV TXDATA=C:\\txdata
ENV TXADMIN_PORT=40120

WORKDIR C:\gsa

# IMPORTANT: single-line RUN so Docker never parses New-Item as a Dockerfile instruction
RUN powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "New-Item -ItemType Directory -Force -Path 'C:\gsa' | Out-Null; New-Item -ItemType Directory -Force -Path $env:FIVEM_HOME | Out-Null; New-Item -ItemType Directory -Force -Path $env:TXDATA | Out-Null"

COPY install-fxserver.ps1 C:\gsa\install-fxserver.ps1
COPY start-server.ps1     C:\gsa\start-server.ps1

RUN powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\gsa\install-fxserver.ps1

EXPOSE 31120/udp 31120/tcp 31121/tcp 40120/tcp 41120/tcp 42120/tcp

ENTRYPOINT ["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\gsa\\start-server.ps1"]
