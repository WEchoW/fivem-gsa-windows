FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command"]

RUN New-Item -ItemType Directory -Force -Path C:\tools | Out-Null ; `
    curl.exe -L -o C:\tools\7zr.exe https://www.7-zip.org/a/7zr.exe ; `
    curl.exe -L -o C:\tools\7z.dll  https://www.7-zip.org/a/7z.dll

COPY bootstrap.ps1 C:\bootstrap.ps1
COPY entrypoint.ps1 C:\entrypoint.ps1

WORKDIR C:\

ENTRYPOINT ["powershell","-NoProfile","-ExecutionPolicy","Bypass","C:\\bootstrap.ps1"]
