# FiveM Server – Network & Port Setup

This guide explains how to open the required network ports so players and txAdmin can connect to your FiveM server.

---

## Required Ports

| Purpose | Protocol | Port | Description |
|--------|----------|------|-------------|
| FiveM Game Server | **UDP** | **30120** | Main game traffic |
| txAdmin Web Panel | **TCP** | **40120** | Server management panel |

---

## Router Port Forwarding

Log into your router and forward the following ports to your server’s **local IP address**.

| External Port | Internal Port | Protocol | Forward To |
|---------------|---------------|----------|-------------|
| 30120 | 30120 | UDP | Your server’s local IP |
| 40120 | 40120 | TCP | Your server’s local IP |

Save and apply the rules in your router.

---

## Windows Firewall Rules

Open **PowerShell as Administrator** and run:

```powershell
netsh advfirewall firewall add rule name="FiveM 30120 UDP" dir=in action=allow protocol=UDP localport=30120
netsh advfirewall firewall add rule name="txAdmin 40120 TCP" dir=in action=allow protocol=TCP localport=40120
