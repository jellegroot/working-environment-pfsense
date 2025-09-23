#!/bin/bash
# WireGuard Client Configuration Generator

CLIENT_NAME=${1:-"laptop"}
CLIENT_IP=${2:-"172.20.4.100"}

echo "Generating WireGuard client configuration for: ${CLIENT_NAME}"

# Get server public key
if [ ! -f /etc/wireguard/server_public.key ]; then
    echo "Error: Server keys not found. Run setup_wireguard.sh first"
    exit 1
fi

SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)

# Generate client keys
CLIENT_PRIVATE_KEY=$(wg genkey)
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# Save client keys
echo "$CLIENT_PRIVATE_KEY" > /etc/wireguard/clients/${CLIENT_NAME}_private.key
echo "$CLIENT_PUBLIC_KEY" > /etc/wireguard/clients/${CLIENT_NAME}_public.key
chmod 600 /etc/wireguard/clients/${CLIENT_NAME}_private.key

# Create client configuration
cat > /etc/wireguard/clients/${CLIENT_NAME}.conf << EOF
[Interface]
# WireGuard Client Configuration for ${CLIENT_NAME}
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_IP}/24
DNS = 8.8.8.8, 8.8.4.4

[Peer]
# WireGuard Server
PublicKey = ${SERVER_PUBLIC_KEY}
Endpoint = YOUR_SERVER_IP:51820
AllowedIPs = 172.20.4.0/24

# Keep connection alive
PersistentKeepalive = 25
EOF

# Add client peer to server configuration
echo "" >> /etc/wireguard/wg0.conf
echo "# Client: ${CLIENT_NAME}" >> /etc/wireguard/wg0.conf
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "PublicKey = ${CLIENT_PUBLIC_KEY}" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = ${CLIENT_IP}/32" >> /etc/wireguard/wg0.conf
echo "" >> /etc/wireguard/wg0.conf

# Generate QR code for mobile clients
qrencode -t ansiutf8 < /etc/wireguard/clients/${CLIENT_NAME}.conf

echo ""
echo "Client configuration generated:"
echo "Config file: /etc/wireguard/clients/${CLIENT_NAME}.conf"
echo "Client Private Key: ${CLIENT_PRIVATE_KEY}"
echo "Client Public Key: ${CLIENT_PUBLIC_KEY}"
echo "Client IP: ${CLIENT_IP}"
echo ""
echo "QR Code generated above for mobile import"
echo "Copy the .conf file for desktop clients"
echo ""
echo "Remember to update 'YOUR_SERVER_IP' in the client config!"
echo "Restart WireGuard service: wg-quick down wg0 && wg-quick up wg0"