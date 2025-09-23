#!/bin/bash
# Office Werkomgeving Startup Script

echo "🏢 OFFICE WERKOMGEVING OPSTART"
echo "================================"

# Start SSH service
echo "📡 Starting SSH service..."
service ssh start

# Start XRDP voor remote desktop
echo "🖥️  Starting XRDP service..."
service xrdp start

# Start VNC server voor office gebruiker
echo "🖱️  Setting up VNC server..."
su - office -c "vncserver :1 -geometry 1024x768 -depth 24" &

# Maak data directories
echo "📁 Creating office directories..."
mkdir -p /home/office/Documents/Data
mkdir -p /home/office/Documents/Reports
mkdir -p /home/office/Documents/Scripts
chown -R office:office /home/office/Documents

# Test database connectiviteit
echo "🗄️  Testing database connectivity..."
if timeout 10 mysql -h database -u webapp_user -psecure_password123 webapp_db -e "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ Database connection successful"
else
    echo "⚠️  Database connection failed - will retry later"
fi

# Test website toegang
echo "🌐 Testing website access..."
if timeout 10 curl -s http://webserver >/dev/null 2>&1; then
    echo "✅ Website access successful"
else
    echo "⚠️  Website access failed - will retry later"
fi

echo ""
echo "🎯 OFFICE WERKOMGEVING GEREED"
echo "=============================="
echo "💻 SSH Access: Port 22 (mapped to 2224)"
echo "🖥️  RDP Access: Port 3389 (mapped to 3389)"
echo "🖱️  VNC Access: Port 5901 (mapped to 5901)"
echo "👤 Office User: office / officepassword123"
echo ""
echo "📊 Available Tools:"
echo "   • python3 /home/office/Documents/Scripts/db_extractor.py"
echo "   • python3 /home/office/Documents/Scripts/website_tool.py"
echo "   • libreoffice (LibreOffice Suite)"
echo "   • mysql -h database -u webapp_user -p"
echo ""
echo "🔄 Services running in background..."

# Keep container running met logs
tail -f /var/log/xrdp.log
