# FiveM Server – First Time Network Setup

Welcome! 👋  
This quick guide will help you open the correct ports so your FiveM server and txAdmin panel can be reached from the internet.

You only need to do this **once**.

---

## What Are Ports?

Think of ports like doors to your server.  
If the doors are closed, players can’t get in — even if the server is running.

We’ll open **two doors**:

| Purpose | Protocol | Port |
|--------|----------|------|
| FiveM Game Server | UDP | 30120 |
| txAdmin Web Panel | TCP | 40120 |

---

## Step 1 – Forward the Ports on Your Router

Log into your router and find **Port Forwarding** or **NAT** settings.

Add these rules and point them to your server’s **local IP address**.

| External Port | Internal Port | Protocol | Forward To |
|---------------|---------------|----------|-------------|
| 30120 | 30120 | UDP | Your server’s local IP |
| 40120 | 40120 | TCP | Your server’s local IP |

Save the changes when you’re done.

---

## Step 2 – Allow the Ports in Windows Firewall

On your server PC:

1. Right-click **Start**
2. Click **Windows Terminal (Admin)** or **PowerShell (Admin)**
3. Paste and run:

```powershell
netsh advfirewall firewall add rule name="FiveM 30120 UDP" dir=in action=allow protocol=UDP localport=30120
netsh advfirewall firewall add rule name="txAdmin 40120 TCP" dir=in action=allow protocol=TCP localport=40120
