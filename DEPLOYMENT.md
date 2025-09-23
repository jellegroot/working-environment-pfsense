# Week 1, 2 & 3 Project - Deployment en Test Handleiding

## 🚀 Quick Start

1. **Start het complete project (Weeks 1-3):**
   ```bash
   chmod +x start.sh
   ./start.sh
   ```

2. **Open de website:**
   - Ga naar: http://localhost
   - Login met: admin / password123

3. **Open de Router Dashboard (Week 3):**
   - Ga naar: http://localhost:8080
   - pfSense-like interface voor network management

4. **Test network segmentation:**
   ```bash
   chmod +x test_network.sh
   ./test_network.sh
   ```

## Project Structuur (Weeks 1-3)

```
Protect/
├── docker-compose.yml          # Docker orchestratie (multi-network)
├── start.sh                    # Start script (all weeks)
├── stop.sh                     # Stop script
├── test_network.sh             # Network segmentation tests
├── webserver/                  # Webserver VM (Week 1)
│   ├── Dockerfile             # Apache + ModSecurity + Flask
│   ├── config/                # Apache configuratie
│   └── scripts/               # Start scripts
├── database/                   # Database VM (Week 1)
│   ├── Dockerfile             # MySQL + SSH
│   ├── config/                # MySQL configuratie
│   ├── init/                  # Database initialisatie
│   └── scripts/               # Start scripts
├── office/                     # Office VM (Week 2)
│   ├── Dockerfile             # LibreOffice + SSH + RDP/VNC
│   ├── scripts/               # Database en website tools
│   └── templates/             # Documentatie
├── router/                     # Router VM (Week 3)
│   ├── Dockerfile             # pfSense-like router
│   ├── config/                # Router configuratie
│   ├── scripts/               # Firewall scripts
│   ├── webui/                 # Web interface
│   ├── nginx.conf             # Nginx configuratie
│   └── start.sh               # Router startup
└── website/                    # Flask website
    ├── app.py                 # Hoofd applicatie
    ├── app.wsgi              # WSGI configuratie
    └── templates/             # HTML templates
```

## 🌐 Toegangsinformatie (Weeks 1-3)

### Website (Week 1)
- **URL:** http://localhost
- **Test Accounts:**
  - Admin: admin / password123
  - User: testuser / password123

### Router Dashboard (Week 3)
- **URL:** http://localhost:8080
- **pfSense-like interface** voor network management en monitoring

### SSH Toegang
- **Webserver:** ssh admin@localhost -p 2222 (password: adminpassword123)
- **Database:** ssh dbadmin@localhost -p 2223 (password: dbadminpassword123)
- **Office:** ssh office@localhost -p 2224 (password: officepassword123)
- **Router:** ssh routeradmin@localhost -p 2225 (password: routerpassword123)

### Office Environment (Week 2)
- **RDP:** localhost:3389 (user: office, password: officepassword123)
- **VNC:** localhost:5901
- **LibreOffice Suite** geïnstalleerd
- **Database Tools:** python3 /home/office/Documents/Scripts/db_extractor.py
- **Website Tools:** python3 /home/office/Documents/Scripts/website_tool.py

### Database Toegang
- **MySQL:** localhost:3306
- **User:** webapp_user
- **Password:** secure_password123
- **Database:** webapp_db

## 🏗️ Network Architectuur (Week 3)

### Network Segmentatie
```
┌─────────────────────────────────────────────────────────────────┐
│                        🛡️  pfSense Router                        │
│                     (172.20.x.1 Gateways)                      │
└─────────────────────┬───────────────┬───────────────────────────┘
                      │               │               │
      ┌───────────────▼──┐    ┌──────▼──────┐    ┌───▼──────────┐
      │   DMZ Network    │    │   Internal   │    │    Office    │
      │  172.20.1.0/24   │    │   Network    │    │   Network    │
      │                  │    │ 172.20.2.0/24│    │172.20.3.0/24 │
      │ ┌──────────────┐ │    │┌────────────┐│    │┌─────────────┐│
      │ │  Webserver   │ │    ││ Database   ││    ││ Office Tools││
      │ │ 172.20.1.10  │ │    ││172.20.2.10 ││    ││ 172.20.3.10 ││
      │ │  Apache +    │ │    ││  MySQL     ││    ││ LibreOffice ││
      │ │ ModSecurity  │ │    ││  Server    ││    ││    Suite    ││
      │ └──────────────┘ │    │└────────────┘│    │└─────────────┘│
      └──────────────────┘    └─────────────┘    └──────────────┘
```

### Firewall Rules
- **DMZ → Internal:** Alleen MySQL (poort 3306) toegestaan
- **Office → DMZ:** HTTP/HTTPS (poorten 80/443) toegestaan  
- **Office → Internal:** MySQL (poort 3306) toegestaan
- **SSH:** Toegestaan naar alle netwerken voor beheer
- **Default:** Alle andere traffic geblokkeerd

### Port Forwarding
| Externe Poort | Interne Bestemming | Service |
|---------------|-------------------|---------|
| 80 | 172.20.1.10:80 | HTTP Webserver |
| 443 | 172.20.1.10:443 | HTTPS Webserver |
| 2222 | 172.20.1.10:22 | SSH Webserver |
| 2223 | 172.20.2.10:22 | SSH Database |
| 2224 | 172.20.3.10:22 | SSH Office |
| 2225 | Router:22 | SSH Router |
| 3306 | 172.20.2.10:3306 | MySQL Database |
| 8080 | Router:80 | Router Web Interface |

## 🔧 Functionaliteiten (Weeks 1-3)

### ✅ Webserver Features (Week 1)
- Ubuntu 22.04 Linux VM (Docker container)
- Apache2 webserver
- ModSecurity WAF met OWASP Core Rules
- Flask website via mod_wsgi
- SSH toegang voor beheer
- Port forwarding (80, 443, 2222)
- Security headers en SSL ondersteuning

### ✅ Database Features (Week 1)
- Ubuntu 22.04 Linux VM (Docker container)
- MySQL 8.0 database server
- User/password tabel met login validatie
- SSH toegang voor beheer
- Port forwarding (3306, 2223)
- Automatische database initialisatie

### ✅ Office Features (Week 2)
- Ubuntu 22.04 Linux VM (Docker container)
- LibreOffice Suite (Calc, Writer, Base)
- RDP en VNC toegang
- SSH toegang voor beheer
- Database connectiviteit tools
- Website interactie scripts
- Port forwarding (3389, 5901, 2224)

### ✅ Router Features (Week 3)
- Ubuntu 22.04 Linux VM (Docker container)
- pfSense-like router functionaliteit
- Network segmentatie (3 subnets)
- iptables firewall rules
- NAT en port forwarding
- Router web interface (http://localhost:8080)
- SSH toegang voor beheer (poort 2225)
- Traffic logging en monitoring

### ✅ Website Features
- Modern responsive design (Bootstrap)
- User authentication met bcrypt password hashing
- Admin dashboard met gebruikersbeheer
- Login logging en activiteit tracking
- Database-driven user management

## 🧪 Testing (Weeks 1-3)

### 1. Network Segmentation Tests (Week 3)
```bash
# Run automated network tests
./test_network.sh

# Manual connectivity tests
# Test office to webserver (should work)
docker exec office-vm curl -s http://172.20.1.10

# Test office to database (should work)
docker exec office-vm nc -z 172.20.2.10 3306

# Test router web interface
curl -s http://localhost:8080
```

### 2. Test ModSecurity WAF (Week 1)
```bash
# Test basis XSS protectie
curl -X POST http://localhost/login -d "username=<script>alert('xss')</script>&password=test"

# Test SQL injection protectie
curl -X POST http://localhost/login -d "username=admin'; DROP TABLE users; --&password=test"
```

### 3. Test Database Connectiviteit (Week 1)
```bash
# Vanuit webserver container
docker exec -it webserver-vm mysql -h database -u webapp_user -p webapp_db

# Vanuit office container (Week 2)
docker exec -it office-vm mysql -h database -u webapp_user -p webapp_db

# Vanuit host systeem
mysql -h localhost -P 3306 -u webapp_user -p webapp_db
```

### 4. Test SSH Toegang (All Weeks)
```bash
# Test webserver SSH (Week 1)
ssh admin@localhost -p 2222 'whoami && hostname'

# Test database SSH (Week 1)
ssh dbadmin@localhost -p 2223 'whoami && hostname'

# Test office SSH (Week 2)
ssh office@localhost -p 2224 'whoami && hostname'

# Test router SSH (Week 3)
ssh routeradmin@localhost -p 2225 'whoami && hostname'
```

### 5. Test Office Environment (Week 2)
```bash
# Test RDP connection (use RDP client)
# Connect to: localhost:3389
# User: office, Password: officepassword123

# Test VNC connection (use VNC client)
# Connect to: localhost:5901

# Test office tools
docker exec office-vm python3 /home/office/Documents/Scripts/db_extractor.py
docker exec office-vm python3 /home/office/Documents/Scripts/website_tool.py
```

### 6. Test Router Functionality (Week 3)
```bash
# Check firewall rules
docker exec router-vm iptables -L -n

# Check NAT rules
docker exec router-vm iptables -t nat -L -n

# Test port forwarding
curl -s http://localhost        # Should reach webserver
curl -s http://localhost:8080   # Should reach router interface
```

# Test database SSH
ssh dbadmin@localhost -p 2223 'whoami && hostname'
```

### 4. Test Website Functionaliteit
1. Ga naar http://localhost
2. Login met admin/ikbeneenadmin
3. Controleer dashboard functionaliteit
4. Test user management (alleen admin)
5. Test logout functionaliteit

## Monitoring en Logs

### Container Status
```bash
docker-compose ps
docker-compose logs -f
```

### Apache Logs
```bash
docker exec webserver-vm tail -f /var/log/apache2/webapp_access.log
docker exec webserver-vm tail -f /var/log/apache2/webapp_error.log
docker exec webserver-vm tail -f /var/log/apache2/modsec_audit.log
```

### MySQL Logs
```bash
docker exec database-vm tail -f /var/log/mysql/error.log
docker exec database-vm tail -f /var/log/mysql/general.log
```

## Troubleshooting

### Container start problemen
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs webserver
docker-compose logs database

# Rebuild containers
docker-compose down
docker-compose up --build
```

### Database verbinding problemen
```bash
# Test database ping
docker exec database-vm mysqladmin ping

# Check database users
docker exec database-vm mysql -u root -p -e "SELECT user, host FROM mysql.user;"
```

### ModSecurity configuratie problemen
```bash
# Test Apache configuratie
docker exec webserver-vm apache2ctl configtest

# Check ModSecurity status
docker exec webserver-vm apache2ctl -M | grep security
```

## Netwerk Architectuur

```
┌─────────────────┐    Port Forwarding    ┌──────────────────┐
│   Laptop/Host   │ ◄──────────────────► │   Docker Host    │
└─────────────────┘                       └──────────────────┘
                                                    │
                              ┌─────────────────────┼─────────────────────┐
                              │             Docker Network                │
                              │                     │                     │
                    ┌─────────▼──────────┐         │         ┌──────────▼────────┐
                    │   Webserver VM     │◄────────┼────────►│  Database VM      │
                    │   - Apache2        │         │         │  - MySQL 8.0      │
                    │   - ModSecurity    │         │         │  - SSH Server     │
                    │   - Flask App      │         │         │  - Admin Tools    │
                    │   - SSH Server     │         │         │                   │
                    └────────────────────┘         │         └───────────────────┘
                                                   │
                              ┌─────────────────────┼─────────────────────┐
                              │        Port Mappings                      │
                              │  80:80   (HTTP)                          │
                              │  443:443 (HTTPS)                         │
                              │  2222:22 (SSH Webserver)                 │
                              │  3306:3306 (MySQL)                       │
                              │  2223:22 (SSH Database)                  │
                              └───────────────────────────────────────────┘
```

## Beveiliging

### ModSecurity WAF
- **Status:** Actief in blocking mode
- **Rules:** OWASP Core Rule Set 3.x
- **Protection:** XSS, SQL Injection, RFI, LFI, etc.
- **Logging:** Alle attacks worden gelogd in audit log

### Password Security
- **Hashing:** bcrypt met salt
- **Storage:** Geen plaintext passwords in database
- **Validation:** Server-side validatie

### Network Security
- **Firewall:** Container isolation
- **SSH:** Key-based authentication mogelijk
- **Database:** Restricted network access

### Security Headers
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security (HTTPS)
- Content-Security-Policy

## Clean Up

```bash
# Stop containers
./stop.sh

# Remove containers and volumes
docker-compose down -v

# Remove images
docker-compose down --rmi all
```
