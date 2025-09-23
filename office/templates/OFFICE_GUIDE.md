# Office Werkomgeving - Week 2 Project

## Overzicht

De office werkomgeving is een complete desktop omgeving met office applicaties die data kan ophalen uit de SQL database en toegang heeft tot de website.

## Toegang tot Office VM

### SSH Toegang
```bash
ssh office@localhost -p 2224
# Wachtwoord: officepassword123
```

### Remote Desktop (RDP)
- **Host:** localhost
- **Port:** 3389
- **Username:** office
- **Password:** officepassword123

### VNC Toegang
- **Host:** localhost
- **Port:** 5901
- **Password:** (wordt gevraagd bij eerste setup)

## Beschikbare Software

### Office Applicaties
- **LibreOffice Calc** - Spreadsheet applicatie voor data analyse
- **LibreOffice Writer** - Tekstverwerker voor rapporten
- **LibreOffice Base** - Database frontend (kan direct verbinden met MySQL)
- **Firefox** - Webbrowser voor website toegang

### Database Tools
- **MySQL Client** - Command line database toegang
- **Python Scripts** - Geautomatiseerde data extractie
- **Pandas/Excel** - Data analyse en export tools

## Database Connectiviteit

### Direct MySQL Toegang
```bash
mysql -h database -u webapp_user -psecure_password123 webapp_db
```

### Python Data Extractor
```bash
# Toon database statistieken
python3 /home/office/Documents/Scripts/db_extractor.py stats

# Exporteer naar Excel
python3 /home/office/Documents/Scripts/db_extractor.py excel
```

### LibreOffice Base Configuratie
1. Open LibreOffice Base
2. Kies "Connect to existing database"
3. Selecteer "MySQL/MariaDB"
4. Server: `database`
5. Database: `webapp_db`
6. Username: `webapp_user`
7. Password: `secure_password123`

## Website Toegang

### Browser Toegang
- Open Firefox
- Ga naar: `http://webserver`
- Login met beschikbare accounts

### Geautomatiseerde Website Tools
```bash
# Test website connectiviteit
python3 /home/office/Documents/Scripts/website_tool.py test

# Test login functionaliteit
python3 /home/office/Documents/Scripts/website_tool.py login admin password123

# Download gebruikersdata
python3 /home/office/Documents/Scripts/website_tool.py download
```

## Gebruik Cases

### 1. Data Analyse in Excel/Calc
1. Run database extractor: `python3 db_extractor.py excel`
2. Open gegenereerd Excel bestand in LibreOffice Calc
3. Analyseer gebruikersstatistieken en login patterns
4. Maak grafieken en pivottabellen

### 2. Rapport Generatie
1. Gebruik LibreOffice Writer
2. Importeer data uit database via copy/paste of CSV
3. Maak professionele rapporten met grafieken
4. Export naar PDF voor distributie

### 3. Real-time Database Monitoring
1. Open LibreOffice Base
2. Verbind direct met database
3. Maak queries en views
4. Monitor real-time login activiteit

### 4. Website Administration
1. Open Firefox
2. Login als admin op website
3. Beheer gebruikers via web interface
4. Download data voor offline analyse

## Netwerk Architectuur

```
┌─────────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Office VM         │◄──►│   Database VM    │    │   Webserver VM      │
│   - LibreOffice     │    │   - MySQL 8.0    │◄──►│   - Apache2         │
│   - Python Tools    │    │   - webapp_db     │    │   - Flask App       │
│   - MySQL Client    │    │   - SSH Access    │    │   - ModSecurity     │
│   - Firefox         │    │                  │    │   - SSH Access      │
│   - RDP/VNC         │    │                  │    │                     │
│   - SSH Access      │    │                  │    │                     │
└─────────────────────┘    └──────────────────┘    └─────────────────────┘
         │                           │                           │
         └───────────────────────────┼───────────────────────────┘
                                     │
                            ┌────────▼─────────┐
                            │  Docker Network  │
                            │  172.20.0.0/24   │
                            └──────────────────┘
```

## Port Mapping

| Service | Internal Port | External Port | Beschrijving |
|---------|---------------|---------------|--------------|
| Office SSH | 22 | 2224 | SSH toegang tot office VM |
| Office RDP | 3389 | 3389 | Remote Desktop Protocol |
| Office VNC | 5901 | 5901 | VNC remote desktop |

## Bestanden Locaties

- **Scripts:** `/home/office/Documents/Scripts/`
- **Data:** `/home/office/Documents/Data/`
- **Reports:** `/home/office/Documents/Reports/`
- **Templates:** `/home/office/Documents/Templates/`

## Troubleshooting

### Database Verbinding Issues
```bash
# Test database connectiviteit
ping database
mysql -h database -u webapp_user -p

# Check netwerk status
netstat -rn
```

### Website Toegang Issues
```bash
# Test website bereikbaarheid
ping webserver
curl -I http://webserver

# Check DNS resolutie
nslookup webserver
```

### Desktop Environment Issues
```bash
# Restart desktop services
service xrdp restart
vncserver -kill :1
vncserver :1
```
