#!/bin/bash
# Router Firewall Rules Configuration Script

echo "Configuring pfSense-like firewall rules..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Clear existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH access to router
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP access to router web interface
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# DMZ Network Rules (172.20.1.0/24)
# Allow HTTP/HTTPS to webserver from anywhere
iptables -A FORWARD -p tcp --dport 80 -d 172.20.1.10 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -d 172.20.1.10 -j ACCEPT

# Allow webserver to access database
iptables -A FORWARD -s 172.20.1.10 -d 172.20.2.10 -p tcp --dport 3306 -j ACCEPT

# Office Network Rules (172.20.3.0/24)
# Allow office to access webserver
iptables -A FORWARD -s 172.20.3.0/24 -d 172.20.1.10 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -s 172.20.3.0/24 -d 172.20.1.10 -p tcp --dport 443 -j ACCEPT

# Allow office to access database
iptables -A FORWARD -s 172.20.3.0/24 -d 172.20.2.10 -p tcp --dport 3306 -j ACCEPT

# SSH access rules
iptables -A FORWARD -p tcp --dport 22 -j ACCEPT

# Log dropped packets
iptables -A FORWARD -j LOG --log-prefix "ROUTER-DROP: "
iptables -A INPUT -j LOG --log-prefix "ROUTER-INPUT-DROP: "

# NAT Rules for port forwarding
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 172.20.1.10:80
iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 172.20.1.10:443
iptables -t nat -A PREROUTING -p tcp --dport 2222 -j DNAT --to-destination 172.20.1.10:22
iptables -t nat -A PREROUTING -p tcp --dport 2223 -j DNAT --to-destination 172.20.2.10:22
iptables -t nat -A PREROUTING -p tcp --dport 2224 -j DNAT --to-destination 172.20.3.10:22
iptables -t nat -A PREROUTING -p tcp --dport 3306 -j DNAT --to-destination 172.20.2.10:3306

# Masquerade for outbound traffic
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo "Firewall rules configured successfully"
echo "Network segments:"
echo "  DMZ (Webserver):     172.20.1.0/24"
echo "  Internal (Database): 172.20.2.0/24" 
echo "  Office (Tools):      172.20.3.0/24"

# Display current rules
echo ""
echo "=== Current Firewall Rules ==="
iptables -L -n --line-numbers
