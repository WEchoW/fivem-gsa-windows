FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

# Tools (7zip minimal)
RUN New-Item -ItemType Directory -Force -Path C:\tools | Out-Null ; `
    curl.exe -L -o C:\tools\7zr.exe https://www.7-zip.org/a/7zr.exe ; `
    curl.exe -L -o C:\tools\7z.dll  https://www.7-zip.org/a/7z.dll

# Ensure expected paths exist
RUN New-Item -ItemType Directory -Force -Path C:\gsa | Out-Null

COPY entrypoint.ps1 C:\entrypoint.ps1
COPY start-server.ps1 C:\gsa\start-server.ps1

WORKDIR C:\

# Start the same script GSA is trying to run
ENTRYPOINT ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "C:\\gsa\\start-server.ps1"]
