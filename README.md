# NaiveGUI
Client/Server configuration GUI for NaiveProxy and Caddy.  
  
**Dependencies:**
+ Mageia-9 (RPM): gtk2 systemd lib64proxy-gnome lib64proxy-kde
+ Mageia-10 (RPM): gtk2 systemd lib64proxy-gnome
+ Ubuntu (DEB): libproxy1v5 systemd libgtk2.0-0

**Work directories / services:**
+ Client: ~/.config/naivegui; Service: /etc/systemd/user/naivegui.service
+ Server: /etc/caddy; Service: /etc/systemd/system/caddy.service

![](https://github.com/AKotov-dev/NaiveGUI/blob/main/Screenshot2.png)

## How It Works
1. Rent a VPS located outside your country.
2. Point a domain to your server’s IP address: buy one or use a [free option](https://www.duckdns.org/).
3. Launch NaiveGUI, enter your domain name, username, and password, then click “Create Client and Server”.
Save the generated archive containing:
- **client.json** — client configuration
- **Caddyfile** — server configuration
4. Install the `caddy-forwardproxy-naive` package on your server.
**Important:** this package includes `/usr/bin/caddy` and provides a full web server. It is intended to be the only web server running on your VPS.
5. Upload the `Caddyfile` to the server into `/etc/caddy` and start the service:
```
systemctl restart caddy
```
6. In NaiveGUI, verify that your server is reachable over HTTPS using the **"Check page…"** link.
7. If the domain is accessible, click **"Start"** and verify your proxy [using this test](https://whoer.net/ru).
---
### Connection Modes

The client and server support two modes: **QUIC** and **HTTPS (TCP)**.  
  
In some regions, QUIC may be blocked or unstable, so **HTTPS is usually the preferred option**.  
  
You can test the connection speed in each mode using the **"Check connection speed…"** link in NaiveGUI.

### Supported DEs
Budgie, GNOME, Cinnamon, Plasma 5/6, MATE. To use the system proxy in LXDE and XFCE, install [XDE-Proxy-GUI](https://github.com/AKotov-dev/xde-proxy-gui).

### Useful links
[naiveproxy](https://github.com/klzgrad/naiveproxy?tab=readme-ov-file), [forwardproxy](https://github.com/klzgrad/forwardproxy), [sing-box](https://github.com/SagerNet/sing-box)
