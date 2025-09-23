#!/bin/bash
# Router Startup Script - pfSense-like functionality

echo "Starting pfSense Router..."

# Start SSH service
service ssh start

# Configure network interfaces and forwarding
echo "Configuring network interfaces..."
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# Load firewall rules
echo "Loading firewall configuration..."
/usr/local/bin/configure_firewall.sh

# Start nginx for web interface
echo "Starting router web interface..."
service nginx start

# Create status file
echo "ROUTER_STATUS=ONLINE" > /var/log/pfsense/status.log
echo "FIREWALL_STATUS=ACTIVE" >> /var/log/pfsense/status.log
echo "NAT_STATUS=ENABLED" >> /var/log/pfsense/status.log

# Display network configuration
echo ""
echo "=== pfSense Router Started ==="
echo "🌐 Web Interface: http://localhost:8080"
echo "🔒 SSH Access: ssh routeradmin@localhost -p 2225"
echo ""
echo "📊 Network Segments:"
echo "   DMZ Network:      172.20.1.0/24 (Gateway: 172.20.1.1)"
echo "   Internal Network: 172.20.2.0/24 (Gateway: 172.20.2.1)"
echo "   Office Network:   172.20.3.0/24 (Gateway: 172.20.3.1)"
echo ""
echo "🛡️ Security Features:"
echo "   ✓ Firewall Rules Active"
echo "   ✓ Network Segmentation"
echo "   ✓ Port Forwarding"
echo "   ✓ NAT/Masquerading"
echo ""

# Keep container running and monitor services
while true; do
    # Check if nginx is running
    if ! pgrep nginx > /dev/null; then
        echo "Warning: nginx stopped, restarting..."
        service nginx start
    fi
    
    # Check if ssh is running
    if ! pgrep sshd > /dev/null; then
        echo "Warning: SSH stopped, restarting..."
        service ssh start
    fi
    
    sleep 30
done
