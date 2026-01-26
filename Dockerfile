FROM mcr.microsoft.com/windows:2004-amd64

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# Download latest FXServer artifact (master) and VC++ 2019 redist
RUN $ErrorActionPreference='Stop' ; \
    $base='https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/' ; \
    $html = (Invoke-WebRequest -UseBasicParsing $base).Content ; \
    $latest = ([regex]::Matches($html, 'href=\"\.\/([0-9\-]+\/)\"') | Select-Object -Last 1).Groups[1].Value ; \
    Invoke-WebRequest -UseBasicParsing ($base + $latest + 'server.zip') -OutFile 'server.zip' ; \
    Invoke-WebRequest -UseBasicParsing 'https://aka.ms/vs/16/release/VC_redist.x64.exe' -OutFile 'VC_redist.x64.exe' ; \
    Expand-Archive .\server.zip -DestinationPath .\server -Force

SHELL ["cmd", "/S", "/C"]
RUN VC_redist.x64.exe /install /quiet /norestart

WORKDIR C:\\server-data

EXPOSE 30120/tcp 30120/udp

SHELL ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]
ENTRYPOINT ["..\\server\\FXServer.exe", "+exec", "server.cfg"]
