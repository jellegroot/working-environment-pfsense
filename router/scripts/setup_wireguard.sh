#!/bin/bash
# WireGuard VPN Server Setup Script

echo "Setting up WireGuard VPN Server..."

# Create WireGuard directories
mkdir -p /etc/wireguard/clients
mkdir -p /var/log/wireguard

# Generate server keys if they don't exist
if [ ! -f /etc/wireguard/server_private.key ]; then
    echo "Generating WireGuard server keys..."
    wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
    chmod 600 /etc/wireguard/server_private.key
    chmod 644 /etc/wireguard/server_public.key
fi

# Get server keys
SERVER_PRIVATE_KEY=$(cat /etc/wireguard/server_private.key)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

# Create WireGuard server configuration
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
# WireGuard Server Configuration
PrivateKey = ${SERVER_PRIVATE_KEY}
Address = 172.20.4.1/24
ListenPort = 51820
SaveConfig = false

# Enable IP forwarding for VPN
PostUp = echo 1 > /proc/sys/net/ipv4/ip_forward

# iptables rules for VPN traffic
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -s 172.20.4.0/24 -o eth0 -j MASQUERADE

# Allow VPN clients access to all subnets
PostUp = iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.1.0/24 -j ACCEPT
PostUp = iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.2.0/24 -j ACCEPT
PostUp = iptables -A FORWARD -s 172.20.4.0/24 -d 172.20.3.0/24 -j ACCEPT

# Cleanup rules on shutdown
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -s 172.20.4.0/24 -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -s 172.20.4.0/24 -d 172.20.1.0/24 -j ACCEPT
PostDown = iptables -D FORWARD -s 172.20.4.0/24 -d 172.20.2.0/24 -j ACCEPT
PostDown = iptables -D FORWARD -s 172.20.4.0/24 -d 172.20.3.0/24 -j ACCEPT

EOF

chmod 600 /etc/wireguard/wg0.conf

echo "WireGuard server configuration created"
echo "Server Public Key: ${SERVER_PUBLIC_KEY}"