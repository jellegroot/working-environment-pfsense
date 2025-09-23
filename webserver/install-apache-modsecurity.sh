#!/bin/bash
# Apache2 en ModSecurity WAF Installatie Script

echo "=== Apache2 en ModSecurity Installatie ==="

# Installeer Apache2
echo "Installing Apache2..."
sudo apt update
sudo apt install -y apache2 apache2-utils

# Start en enable Apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Installeer ModSecurity en afhankelijkheden
echo "Installing ModSecurity WAF..."
sudo apt install -y libapache2-mod-security2 modsecurity-crs

# Enable Apache modules
sudo a2enmod security2
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers

# Configureer ModSecurity
echo "Configuring ModSecurity..."

# Backup originele configuratie
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

# Update ModSecurity configuratie
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

# Configureer OWASP Core Rule Set
echo "Setting up OWASP Core Rule Set..."
sudo cp /usr/share/modsecurity-crs/crs-setup.conf.example /etc/modsecurity/crs-setup.conf

# Maak custom Apache configuratie voor ModSecurity
sudo tee /etc/apache2/conf-available/security.conf > /dev/null << 'EOF'
# ModSecurity Configuration
<IfModule mod_security2.c>
    # Include ModSecurity configuration
    Include /etc/modsecurity/modsecurity.conf
    
    # Include OWASP Core Rule Set
    Include /etc/modsecurity/crs-setup.conf
    Include /usr/share/modsecurity-crs/rules/*.conf
    
    # Custom rules directory
    Include /etc/modsecurity/custom-rules/*.conf
</IfModule>

# Security headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set Referrer-Policy strict-origin-when-cross-origin
EOF

# Enable security configuratie
sudo a2enconf security

# Maak custom rules directory
sudo mkdir -p /etc/modsecurity/custom-rules

# Restart Apache
sudo systemctl restart apache2

# Test configuratie
echo "Testing Apache configuration..."
sudo apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "=== Apache2 en ModSecurity succesvol geïnstalleerd ==="
    echo "ModSecurity status: ENABLED"
    echo "OWASP Core Rule Set: ENABLED"
    echo ""
    echo "Next steps:"
    echo "1. Configure virtual hosts (run configure-vhost.sh)"
    echo "2. Install SSL certificates"
    echo "3. Deploy Flask application"
    echo "4. Test WAF functionality"
else
    echo "ERROR: Apache configuration test failed!"
    exit 1
fi
