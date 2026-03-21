# NaiveGUI
Client/Server configuration GUI for NaiveProxy and Caddy  
  
**Dependencies:**
+ Mageia-9 (RPM): gtk2 systemd lib64proxy-gnome lib64proxy-kde
+ Mageia-10 (RPM): gtk2 systemd lib64proxy-gnome
+ Ubuntu (DEB): libproxy1v5 systemd libgtk2.0-0

Client ports: SOCKS5 - 127.0.0.1:1080 (changeable), HTTP - 127.0.0.1:8889 (fixed, ver. >= 0.4.1)

Work directories / services:

Client: ~/.config/ss-cloak-client; Service: /etc/systemd/user/ss-cloak-client.service
Server: /etc/ss-cloak-server; Service: /etc/systemd/system/ss-cloak-server.service

  
![](https://github.com/AKotov-dev/NaiveGUI/blob/main/Screenshot1.png)
