#!/bin/bash
# Linux iptables Firewall Rules Configuration Script

echo "Configuring advanced iptables firewall rules..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Clear existing rules - NO RESTRICTIONS MODE
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies to ACCEPT ALL
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# NO FIREWALL RULES - ALLOW ALL TRAFFIC
# All traffic is allowed by default ACCEPT policies above
echo "⚠️  WARNING: Firewall disabled - All traffic allowed!"

# NO NETWORK SEGMENTATION - ALL TRAFFIC ALLOWED

# NO LOGGING OR DROPPING - ALL PACKETS ACCEPTED

# Advanced NAT Rules for port forwarding
# Web services (HTTP/HTTPS)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 172.20.1.10:80
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 172.20.1.10:443

# SSH port forwarding
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2222 -j DNAT --to-destination 172.20.1.10:22
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2223 -j DNAT --to-destination 172.20.2.10:22
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2224 -j DNAT --to-destination 172.20.3.10:22

# Database access (restricted)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3306 -s 172.20.3.0/24 -j DNAT --to-destination 172.20.2.10:3306

# Office services (RDP, VNC)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3389 -j DNAT --to-destination 172.20.3.10:3389
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 5901 -j DNAT --to-destination 172.20.3.10:5901

# Source NAT for outbound traffic
iptables -t nat -A POSTROUTING -s 172.20.1.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.2.0/24 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.20.3.0/24 -o eth0 -j MASQUERADE

# Save iptables rules for persistence
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo "⚠️  FIREWALL DISABLED - All traffic allowed!"
echo ""
echo "🌐 Network Segments (No restrictions):"
echo "  📍 DMZ (Webserver):     172.20.1.0/24 (Gateway: 172.20.1.1)"
echo "  🔒 Internal (Database): 172.20.2.0/24 (Gateway: 172.20.2.1)" 
echo "  🏢 Office (Tools):      172.20.3.0/24 (Gateway: 172.20.3.1)"
echo ""
echo "� Security Status:"
echo "  ❌ Firewall Rules: DISABLED"
echo "  ❌ Network Segmentation: DISABLED"
echo "  ❌ Access Control: DISABLED"
echo "  ✅ Port Forwarding: ENABLED"
echo "  ✅ NAT/Masquerading: ENABLED"
echo ""

# Display current rules summary
echo "=== iptables Status ==="
echo "📊 Filter Table Policies:"
iptables -L -n | head -10
echo ""
echo "📊 NAT Table:"
iptables -t nat -L -n | grep -E "(Chain|target|DNAT|MASQ)"
