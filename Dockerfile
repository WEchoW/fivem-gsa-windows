FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# Defaults (GSA blueprint will override via envs)
ENV FIVEM_ROOT=C:\FiveM
ENV ARTIFACTS_DIR=C:\FiveM\artifacts
ENV TXDATA=C:\FiveM\txData

ENV TXHOST_INTERFACE=0.0.0.0
ENV TXHOST_TXA_PORT=40120
ENV FIVEM_GAME_INTERFACE=0.0.0.0
ENV FIVEM_GAME_PORT=30120

WORKDIR C:/gsa

# Update Windows root CA store for TLS downloads inside ServerCore
RUN certutil -generateSSTFromWU C:\gsa\roots.sst; certutil -addstore -f root C:\gsa\roots.sst; Remove-Item C:\gsa\roots.sst -Force

COPY install-fxserver.gsa.ps1 C:/gsa/install-fxserver.ps1
COPY start-server.gsa.ps1     C:/gsa/start-server.ps1

# EXPOSE is metadata only; GSA publishes ports from the blueprint.
EXPOSE 30120/udp 30120/tcp 40120/tcp

ENTRYPOINT ["powershell.exe","-NoProfile","-ExecutionPolicy","Bypass","-File","C:/gsa/start-server.ps1"]
