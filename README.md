# NaiveGUI
Client/Server configuration GUI for NaiveProxy and Caddy  
  
**Dependencies:**
+ Mageia-9 (RPM): gtk2 systemd lib64proxy-gnome lib64proxy-kde
+ Mageia-10 (RPM): gtk2 systemd lib64proxy-gnome
+ Ubuntu (DEB): libproxy1v5 systemd libgtk2.0-0

**Work directories / services:**
+ Client: ~/.config/naivegui; Service: /etc/systemd/user/naivegui.service
+ Server: /etc/caddy; Service: /etc/systemd/system/caddy.service

![](https://github.com/AKotov-dev/NaiveGUI/blob/main/Screenshot1.png)
