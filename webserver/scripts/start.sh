#!/bin/bash

# Start SSH service
service ssh start

# Start Apache in foreground
echo "Starting Apache2 with ModSecurity..."
echo "ModSecurity WAF: ENABLED"
echo "OWASP Core Rules: ENABLED"
echo "SSH Access: Port 22 (mapped to 2222)"
echo "Web Access: Port 80"

# Test Apache configuration
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Apache configuration OK"
    # Start Apache in foreground
    apache2ctl -D FOREGROUND
else
    echo "Apache configuration error!"
    exit 1
fi
