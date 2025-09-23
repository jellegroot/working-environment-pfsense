#!/bin/bash
# Linux iptables Secure Firewall Configuration Script
# Beperkt externe toegang tot alleen gepubliceerde website in DMZ

echo "🔒 Configuring SECURE iptables firewall..."

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Run the secure firewall configuration
/usr/local/bin/secure_firewall.sh

echo ""
echo "📊 Current iptables rules status:"
echo "=== Filter Table ==="
iptables -L -n --line-numbers | head -20

echo ""
echo "=== NAT Table ==="  
iptables -t nat -L -n | head -15

echo ""
echo "🛡️ Secure firewall configuration applied!"
echo "   External access is now limited to DMZ webserver only"
echo "   Management access only via WireGuard VPN (172.20.4.0/24)"