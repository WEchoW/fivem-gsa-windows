# Dockerfile (Windows container)
FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# ---- Defaults ----
ENV TXDATA="C:\\txdata" `
    TXADMIN_PORT="40120"

# Allow overriding the artifact at build time if desired
ARG FXSERVER_ARTIFACT_URL=""
ENV FXSERVER_ARTIFACT_URL=$FXSERVER_ARTIFACT_URL

# ---- Working dir ----
WORKDIR C:\

# ---- Copy scripts ----
COPY install-fxserver.ps1 C:\install-fxserver.ps1
COPY start-server.ps1     C:\start-server.ps1

# ---- Install FXServer + prereqs ----
RUN C:\install-fxserver.ps1

# ---- Ports (documentation; real ports come from -p / your panel) ----
# Matches your blueprint ports: 31120/31121 game/raw, 40120 txAdmin, 41120 query, 42120 rcon
EXPOSE 31120/udp 31120/tcp 31121/tcp 40120/tcp 41120/tcp 42120/tcp

# ---- Start ----
ENTRYPOINT ["powershell","-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\start-server.ps1"]
