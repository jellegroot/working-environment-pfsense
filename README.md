# Week 1, 2 & 3: Secure Multi-VM Environment                     [External Network / Host]
                             |
                      🐧 [Router VM + WireGuard VPN]
                  (Linux iptables Firewall + VPN Server)
                     172.20.x.1 Gateways
                    /     |     |     \       \
                   /      |     |      \       \
         [DMZ]    [Internal] [Office] [Mgmt] [VPN Clients]
      172.20.1.0/24 172.20.2.0/24 172.20.3.0/24 172.20.4.0/24 10.0.100.0/24
           |         |         |         |         |
     [Webserver] [Database] [Office]  [Admin]  [Laptops/Mobile]
     172.20.1.10 172.20.2.10 172.20.3.10          10.0.100.x
     Apache2 +   MySQL 8.0   LibreOffice          WireGuard
     ModSecurity Database     Suite + Tools       Remote Access
     Flask App   SSH Access  RDP/VNC/SSH         Full Networkmentatie

## 🎯 Overzicht van het Project

Dit project implementeert een complete bedrijfsomgeving met webserver, database, office werkomgeving en router voor netwerk segmentatie volgens een 3-weekse planning:

### Week 1: Webserver (VM1) + Database Server (VM2)
✅ **Webserver VM:**
- Ubuntu 22.04 Linux VM (Docker container)
- Apache2 webserver met ModSecurity WAF
- Flask website met user authentication
- SSH toegang voor beheer (poort 2222)
- Port forwarding voor externe toegang

✅ **Database VM:**
- Ubuntu 22.04 Linux VM (Docker container) 
- MySQL 8.0 database server
- Database met user/password tabel (bcrypt hashes)
- SSH toegang voor beheer (poort 2223)
- Secure netwerk toegang vanaf webserver

### Week 2: Office Werkomgeving (VM3)
✅ **Office VM:**
- Ubuntu 22.04 Linux VM (Docker container)
- LibreOffice Suite (Calc, Writer, Base)
- Remote Desktop (RDP) toegang (poort 3389)
- VNC toegang (poort 5901)
- Python scripts voor database analyse
- Website toegang tools
- SSH toegang voor beheer (poort 2224)

### Week 3: Router (VM4) + Network Segmentatie
✅ **Linux iptables Router VM:**
- Ubuntu 22.04 Linux VM (Docker container)
- Linux iptables firewall functionaliteit  
- Network segmentatie in 3 subnets
- Geavanceerde iptables rules voor security
- NAT/DNAT/SNAT en port forwarding configuratie
- Connection tracking en anti-spoofing
- Router web interface (poort 8080)
- SSH toegang voor beheer (poort 2225)

## 🏗️ Netwerkarchitectuur (Week 3)

```
                    [External Network / Host]
                             |
                      � [Router VM]
                  (Linux iptables Firewall)
                     172.20.x.1 Gateways
                    /        |        \
                   /         |         \
         [DMZ Network]  [Internal]  [Office Network]
         172.20.1.0/24  172.20.2.0/24  172.20.3.0/24
               |            |            |
         [Webserver VM] [Database VM] [Office VM]
         172.20.1.10    172.20.2.10   172.20.3.10
         Apache2 +      MySQL 8.0     LibreOffice
         ModSecurity    Database      Suite + Tools
         Flask App      SSH Access    RDP/VNC/SSH
```

### 🔒 Security Zones
- **DMZ Network (172.20.1.0/24):** Public-facing webserver met WAF beveiliging
- **Internal Network (172.20.2.0/24):** Secure database backend, alleen toegankelijk via gecontroleerde routes
- **Office Network (172.20.3.0/24):** User workspace met desktop tools, gecontroleerde toegang tot andere zones
- **Management Network (172.20.4.0/24):** Administrative access en management tools
- **VPN Network (10.0.100.0/24):** WireGuard VPN voor remote access naar alle netwerken
- **Router:** Controleert alle traffic tussen zones, WireGuard VPN server

### 🛡️ iptables Firewall Rules
- DMZ → Internal: Alleen MySQL (poort 3306) met connection tracking
- Office → DMZ: HTTP/HTTPS (poorten 80/443) toegestaan
- Office → Internal: MySQL (poort 3306) toegestaan  
- SSH: Rate-limited toegang naar alle netwerken voor beheer
- Anti-spoofing: Bescherming tegen IP spoofing aanvallen
- Port scan protection: Detectie en blokkering van port scans
- Default: DROP policy, alle ongewenste traffic wordt geblokkeerd en gelogd
## 🚀 Quick Start

1. **Start alle services:**
   ```bash
   chmod +x start.sh
   ./start.sh
   ```

2. **Test network segmentation:**
   ```bash
   chmod +x test_network.sh
   ./test_network.sh
   ```

3. **Stop alle services:**
   ```bash
   chmod +x stop.sh
   ./stop.sh
   ```

## 🌐 Toegangspunten

| Service | URL/Connection | Credentials |
|---------|----------------|-------------|
| **Website** | http://localhost | admin/password123, testuser/password123 |
| **Router Dashboard** | http://localhost:8080 | Web interface (geen login vereist) |
| **WireGuard VPN** | Port 51820/udp | Client config via web interface |
| **Office RDP** | localhost:3389 | office/officepassword123 |
| **Office VNC** | localhost:5901 | Via VNC client |
| **MySQL Database** | localhost:3306 | webapp_user/secure_password123 |

### SSH Toegang
| VM | Connection | Credentials |
|----|------------|-------------|
| Webserver | `ssh admin@localhost -p 2222` | adminpassword123 |
| Database | `ssh dbadmin@localhost -p 2223` | dbadminpassword123 |
| Office | `ssh office@localhost -p 2224` | officepassword123 |
| Router | `ssh routeradmin@localhost -p 2225` | routerpassword123 |

## 🎯 Project Doelen Behaald

✅ **Week 1:** Webserver + Database met security (ModSecurity WAF)  
✅ **Week 2:** Office werkomgeving met database en website toegang  
✅ **Week 3:** Linux iptables Router met geavanceerde network segmentatie en firewall beveiliging  

**Alle requirements voor Weeks 1-3 zijn volledig geïmplementeerd en getest!**
