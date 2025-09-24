#!/usr/bin/env bash
set -euo pipefail

# Run as root
[ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }


# Linux iptables Router Configuration  
# Advanced Network Segmentation Rules

# Network Segments:
# DMZ Network:        172.20.1.0/24 (Webserver)
# Internal Network:   172.20.2.0/24 (Database) 
# Office Network:     172.20.3.0/24 (Office Tools)
# Management Network: 172.20.4.0/24 (Admin Access)


echo "Configuring iptables firewall..."
# BELANGRIJK: Flush alleen onze eigen rules, niet Docker's chains
iptables -F INPUT
iptables -F FORWARD
iptables -F OUTPUT
# Bewaar Docker chains maar flush alleen onze custom rules
iptables -t nat -F PREROUTING
iptables -t nat -F POSTROUTING
# Laat Docker's DOCKER chain intact

# Default policies - ALLES BLOKKEREN
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Loopback interface toestaan (voor lokale services)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ===== EXTERNE TOEGANG RESTRICTIES =====

# Externe toegang tot DMZ webserver (HTTP/HTTPS)
iptables -A FORWARD -s 172.20.0.0/16 -d 172.20.1.10 -p tcp -m multiport --dports 80,443 -j ACCEPT

# Blokkeer rest van management subnet naar andere netwerken (indien gewenst)
iptables -A FORWARD -s 172.20.0.0/16 ! -d 172.20.1.10 -j LOG --log-prefix "MGMT-OTHER-BLOCK: " --log-level 4
iptables -A FORWARD -s 172.20.0.0/16 -j DROP

# ===== MANAGEMENT TOEGANG - BEPERKT =====

# Management subnet mag ALLEEN SSH toegang naar alle omgevingen
iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.1.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.2.0/24 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.3.0/24 -p tcp --dport 22 -j ACCEPT

# Management subnet mag toegang tot extern gepubliceerde website (DMZ webserver)
iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.1.10 -p tcp -m multiport --dports 80,443 -j ACCEPT

# BLOKKEREN: Office toegang tot firewall zelf
iptables -A INPUT -s 172.20.4.0/24 -j LOG --log-prefix "OFFICE-FW-BLOCK: " --log-level 4
iptables -A INPUT -s 172.20.4.0/24 -j DROP

# BLOKKEREN: Alle andere management toegang
iptables -A FORWARD -s 172.20.4.0/24 -j LOG --log-prefix "MGMT-DENY: " --log-level 4
iptables -A FORWARD -s 172.20.4.0/24 -j DROP

# ===== KANTOOR NETWERK RESTRICTIES =====

# Office netwerk toegang - BEPERKT volgens nieuwe specificaties
# Office mag toegang tot extern gepubliceerde website (via externe route)
iptables -A FORWARD -s 172.20.3.0/24 -d 172.20.1.10 -p tcp -m multiport --dports 80,443 -j ACCEPT

# Office mag toegang tot database (lezen/schrijven)
iptables -A FORWARD -s 172.20.3.0/24 -d 172.20.2.10 -p tcp --dport 3306 -j ACCEPT

# Office mag toegang tot internet (eth0)
iptables -A FORWARD -s 172.20.3.0/24 -o eth0 -j ACCEPT

# BLOKKEREN: Office toegang tot DMZ webserver (direct)
iptables -A FORWARD -s 172.20.3.0/24 -j LOG --log-prefix "OFFICE-DROP: " --log-level 4
iptables -A FORWARD -s 172.20.3.0/24 -j DROP

# BLOKKEREN: Office toegang tot firewall zelf
iptables -A INPUT -s 172.20.3.0/24 -j LOG --log-prefix "OFFICE-FW-DROP: " --log-level 4
iptables -A INPUT -s 172.20.3.0/24 -j DROP


# ===== DATABASE SERVER RESTRICTIES =====

# Laat geen enkele ESTABLISHED verbinding terug naar DB-subnet
iptables -I FORWARD 1 -d 172.20.2.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -j DROP
#  Database Server mag ALLEEN reageren op inkomende database verbindingen (vanuit Office)
iptables -I FORWARD 2 -s 172.20.2.0/24 -j LOG --log-prefix "DB-BLOCK: " --log-level 4
iptables -I FORWARD 3 -s 172.20.2.0/24 -j DROP



# BLOKKEREN: Database toegang tot firewall zelf
iptables -A INPUT -s 172.20.2.0/24 -j LOG --log-prefix "DB-FW-BLOCK: " --log-level 4
iptables -A INPUT -s 172.20.2.0/24 -j DROP



# ===== DMZ WEBSERVER RESTRICTIES =====
# DMZ Webserver mag ALLEEN reageren op inkomende HTTP(S) verbindingen

# BLOKKEREN: DMZ Server uitgaand verkeer
iptables -A FORWARD -s 172.20.1.0/24 -o eth0 -j LOG --log-prefix "DMZ-ETH-DROP: " --log-level 4
iptables -A FORWARD -s 172.20.1.0/24 -d 172.20.2.0/24 -j LOG --log-prefix "DMZ-DB-BLOCK: " --log-level 4
iptables -A FORWARD -s 172.20.1.0/24 -d 172.20.3.0/24 -j LOG --log-prefix "DMZ-OFFICE-BLOCK: " --log-level 4
iptables -A FORWARD -s 172.20.1.0/24 -d 172.20.4.0/24 -j LOG --log-prefix "DMZ-MGMT-BLOCK: " --log-level 4
iptables -A FORWARD -s 172.20.1.0/24 -j DROP

# BLOKKEREN: DMZ toegang tot firewall zelf
iptables -A INPUT -s 172.20.1.0/24 -j LOG --log-prefix "DMZ-FW-BLOCK: " --log-level 4
iptables -A INPUT -s 172.20.1.0/24 -j DROP

# ===== PORT FORWARDING VOOR EXTERNE TOEGANG =====

# Website toegang (HTTP/HTTPS) - ALLEEN naar DMZ webserver
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.20.1.10:80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.20.1.10:443

# ===== UITGAANDE NAT (MASQUERADING) =====
iptables -t nat -A POSTROUTING -s 172.20.3.0/24 -o eth0 -j MASQUERADE


# ESTABLISHED en RELATED connections toestaan (voor terugkerend verkeer)
# iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT



echo "Configuring ip forwarding."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

echo ""
echo "Current iptables rules status:"
echo "=== Filter Table ==="
iptables -L -n --line-numbers | head -20

echo ""
echo "=== NAT Table ==="  
iptables -t nat -L -n | head -15

echo ""
echo "   Secure firewall configuration applied!"
echo "   External access is now limited to DMZ webserver only"