FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

ENV FIVEM_ROOT=C:\\FiveM
ENV ARTIFACTS_DIR=C:\\FiveM\\artifacts
ENV TXDATA=C:\\FiveM\\txData

ENV TXHOST_INTERFACE=0.0.0.0
ENV TXHOST_TXA_PORT=40120

WORKDIR C:/gsa

RUN New-Item -ItemType Directory -Force -Path 'C:\gsa' | Out-Null

COPY install-fxserver.ps1 C:/gsa/install-fxserver.ps1
COPY start-server.ps1     C:/gsa/start-server.ps1

EXPOSE 30120/udp 30120/tcp 40120/tcp

ENTRYPOINT ["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File","C:/gsa/start-server.ps1"]
