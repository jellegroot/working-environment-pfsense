#!/bin/bash
# Start script voor Week 1 & 2 Project - Docker Deployment

echo "=== Week 1 & 2 Project - Docker Deployment ==="
echo "Starting Webserver, Database and Office VMs..."

# Check of Docker draait
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Stop eventuele bestaande containers
echo "Stopping existing containers..."
docker compose down

# Build en start containers
echo "Building and starting containers..."
docker compose up --build -d

# Wacht tot services klaar zijn
echo "Waiting for services to start..."
sleep 15

# Test database verbinding
echo "Testing database connection..."
for i in {1..30}; do
    if docker exec database-vm mysqladmin ping -h"localhost" --silent; then
        echo "Database is ready!"
        break
    fi
    echo "Waiting for database... ($i/30)"
    sleep 2
done

# Test webserver
echo "Testing webserver..."
for i in {1..30}; do
    if curl -s http://localhost > /dev/null; then
        echo "Webserver is ready!"
        break
    fi
    echo "Waiting for webserver... ($i/30)"
    sleep 2
done

# Test office container
echo "Testing office container..."
for i in {1..10}; do
    if docker exec office-vm echo "test" > /dev/null 2>&1; then
        echo "Office environment is ready!"
        break
    fi
    echo "Waiting for office environment... ($i/10)"
    sleep 2
done

# Test router container
echo "Testing router container..."
for i in {1..10}; do
    if docker exec router-vm echo "test" > /dev/null 2>&1; then
        echo "Router is ready!"
        break
    fi
    echo "Waiting for router... ($i/10)"
    sleep 2
done

# Test router web interface
echo "Testing router web interface..."
for i in {1..15}; do
    if curl -s http://localhost:8080 > /dev/null; then
        echo "Router web interface is ready!"
        break
    fi
    echo "Waiting for router web interface... ($i/15)"
    sleep 2
done

echo ""
echo "=== Week 3 - Network Segmentation Deployment Completed ==="
echo ""
echo "🌐 Website: http://localhost"
echo "🛡️  Router Dashboard: http://localhost:8080"
echo "🔒 SSH Webserver: ssh admin@localhost -p 2222 (password: adminpassword123)"
echo "🔒 SSH Database: ssh dbadmin@localhost -p 2223 (password: dbadminpassword123)"
echo "🔒 SSH Office: ssh office@localhost -p 2224 (password: officepassword123)"
echo "🔒 SSH Router: ssh routeradmin@localhost -p 2225 (password: routerpassword123)"
echo "🗄️  MySQL: localhost:3306 (user: webapp_user, password: secure_password123)"
echo "🖥️  Office RDP: localhost:3389 (user: office, password: officepassword123)"
echo "🖱️  Office VNC: localhost:5901"
echo ""
echo "� Network Segments (Week 3):"
echo "   🏢 DMZ Network:      172.20.1.0/24 (Webserver)"
echo "   🗄️  Internal Network: 172.20.2.0/24 (Database)"
echo "   🖥️  Office Network:   172.20.3.0/24 (Office Tools)"
echo ""
echo "�📋 Test Accounts:"
echo "   Admin: admin / password123"
echo "   User:  testuser / password123"
echo ""
echo "🏢 Office Tools:"
echo "   • LibreOffice Suite (Calc, Writer, Base)"
echo "   • Database Tools: python3 /home/office/Documents/Scripts/db_extractor.py"
echo "   • Website Tools: python3 /home/office/Documents/Scripts/website_tool.py"
echo "   • MySQL Client: mysql -h database -u webapp_user -p"
echo ""
echo "🛡️  ModSecurity WAF is enabled and protecting the webserver"
echo "🌐 pfSense Router with network segmentation is active"
echo "🔥 Firewall rules enforce security between network segments"
echo "📊 View logs: docker compose logs -f"
echo "🛑 Stop services: docker compose down"
