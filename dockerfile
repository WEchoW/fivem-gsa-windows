FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

RUN New-Item -ItemType Directory -Force -Path C:\tools | Out-Null ; `
    curl.exe -L -o C:\tools\7zr.exe https://www.7-zip.org/a/7zr.exe ; `
    curl.exe -L -o C:\tools\7z.dll  https://www.7-zip.org/a/7z.dll

COPY entrypoint.ps1 C:\entrypoint.ps1

ENTRYPOINT ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "C:\\entrypoint.ps1"]
