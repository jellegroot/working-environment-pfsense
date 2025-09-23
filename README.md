# Week 1, 2 & 3: Secure Multi-VM Environment met Network Segmentatie

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
✅ **Router VM:**
- Ubuntu 22.04 Linux VM (Docker container)
- pfSense-like router functionaliteit
- Network segmentatie in 3 subnets
- iptables firewall rules voor security
- NAT en port forwarding configuratie
- Router web interface (poort 8080)
- SSH toegang voor beheer (poort 2225)

## 🏗️ Netwerkarchitectuur (Week 3)

```
                    [External Network / Host]
                             |
                      🛡️ [Router VM]
                  (pfSense-like Firewall)
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
- **Router:** Controleert en logt alle traffic tussen zones, implementeert firewall rules

### 🛡️ Firewall Rules
- DMZ → Internal: Alleen MySQL (poort 3306) toegestaan
- Office → DMZ: HTTP/HTTPS (poorten 80/443) toegestaan
- Office → Internal: MySQL (poort 3306) toegestaan  
- SSH: Toegestaan naar alle netwerken voor beheer
- Default: Alle andere traffic wordt geblokkeerd en gelogd
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
✅ **Week 3:** Router met network segmentatie en firewall beveiliging  

**Alle requirements voor Weeks 1-3 zijn volledig geïmplementeerd en getest!**
