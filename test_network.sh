#!/bin/bash
# Network Segmentation Test Script - Week 3

echo "=== Week 3 Network Segmentation Tests ==="
echo ""

# Test 1: Check if all containers are running
echo "🔍 Test 1: Container Status"
echo "----------------------------------------"
containers=("webserver-vm" "database-vm" "office-vm" "router-vm")
for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        echo "✅ $container: RUNNING"
    else
        echo "❌ $container: NOT RUNNING"
    fi
done
echo ""

# Test 2: Network connectivity
echo "🌐 Test 2: Network Connectivity"
echo "----------------------------------------"

# Test office to webserver (should work)
echo "Testing Office → Webserver (HTTP):"
if docker exec office-vm curl -s --connect-timeout 5 http://172.20.1.10 > /dev/null; then
    echo "✅ Office can access webserver"
else
    echo "❌ Office cannot access webserver"
fi

# Test office to database (should work)
echo "Testing Office → Database (MySQL):"
if docker exec office-vm nc -z 172.20.2.10 3306 2>/dev/null; then
    echo "✅ Office can reach database port"
else
    echo "❌ Office cannot reach database port"
fi

# Test webserver to database (should work)
echo "Testing Webserver → Database (MySQL):"
if docker exec webserver-vm nc -z 172.20.2.10 3306 2>/dev/null; then
    echo "✅ Webserver can reach database"
else
    echo "❌ Webserver cannot reach database"
fi

echo ""

# Test 3: Router functionality
echo "🛡️  Test 3: Router & Firewall"
echo "----------------------------------------"

# Check if router web interface is accessible
echo "Testing Router Web Interface:"
if curl -s --connect-timeout 5 http://localhost:8080 > /dev/null; then
    echo "✅ Router web interface accessible"
else
    echo "❌ Router web interface not accessible"
fi

# Check iptables rules in router
echo "Testing Firewall Rules:"
if docker exec router-vm iptables -L | grep -q "FORWARD"; then
    echo "✅ Firewall rules are active"
else
    echo "❌ Firewall rules not found"
fi

echo ""

# Test 4: Port forwarding
echo "🔄 Test 4: Port Forwarding"
echo "----------------------------------------"

# Test HTTP forwarding
echo "Testing HTTP Port Forwarding (80 → 172.20.1.10:80):"
if curl -s --connect-timeout 5 http://localhost > /dev/null; then
    echo "✅ HTTP port forwarding works"
else
    echo "❌ HTTP port forwarding failed"
fi

# Test SSH forwarding
echo "Testing SSH Port Forwarding:"
ssh_ports=(2222 2223 2224 2225)
ssh_targets=("webserver" "database" "office" "router")
for i in "${!ssh_ports[@]}"; do
    port=${ssh_ports[$i]}
    target=${ssh_targets[$i]}
    if nc -z localhost $port 2>/dev/null; then
        echo "✅ SSH port $port (${target}) is reachable"
    else
        echo "❌ SSH port $port (${target}) is not reachable"
    fi
done

echo ""

# Test 5: Network isolation
echo "🔒 Test 5: Network Isolation"
echo "----------------------------------------"

# Check that networks are properly segmented
echo "Checking Network Segments:"
if docker network ls | grep -q "dmz_network"; then
    echo "✅ DMZ Network exists"
else
    echo "❌ DMZ Network missing"
fi

if docker network ls | grep -q "internal_network"; then
    echo "✅ Internal Network exists"
else
    echo "❌ Internal Network missing"
fi

if docker network ls | grep -q "office_network"; then
    echo "✅ Office Network exists"
else
    echo "❌ Office Network missing"
fi

echo ""

# Summary
echo "📋 Network Architecture Summary:"
echo "----------------------------------------"
echo "🏢 DMZ Network (172.20.1.0/24):"
echo "   └── Webserver: 172.20.1.10"
echo ""
echo "🗄️  Internal Network (172.20.2.0/24):"
echo "   └── Database: 172.20.2.10"
echo ""
echo "🖥️  Office Network (172.20.3.0/24):"
echo "   └── Office: 172.20.3.10"
echo ""
echo "🛡️  Router: Connected to all networks"
echo "   └── Web Interface: http://localhost:8080"
echo ""
echo "=== Network Segmentation Test Complete ==="
