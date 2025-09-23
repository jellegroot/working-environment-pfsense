#!/bin/bash
# Configureer Apache Virtual Host voor Flask applicatie

echo "=== Apache Virtual Host Configuratie ==="

# Vraag om website details
read -p "Enter your domain name (e.g., example.com or localhost): " DOMAIN
read -p "Enter webmaster email: " EMAIL
read -p "Enter Flask app directory path [/var/www/flaskapp]: " APP_DIR
APP_DIR=${APP_DIR:-/var/www/flaskapp}

# Maak applicatie directory
sudo mkdir -p $APP_DIR
sudo chown -R www-data:www-data $APP_DIR

# Maak virtual host configuratie
sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null << EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $EMAIL
    DocumentRoot $APP_DIR
    
    # Flask WSGI configuratie
    WSGIDaemonProcess flaskapp python-path=$APP_DIR
    WSGIProcessGroup flaskapp
    WSGIScriptAlias / $APP_DIR/app.wsgi
    
    <Directory $APP_DIR>
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
    
    # Security headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>

# HTTPS Virtual Host (optioneel)
<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $EMAIL
    DocumentRoot $APP_DIR
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
    
    # Flask WSGI configuratie
    WSGIDaemonProcess flaskapp-ssl python-path=$APP_DIR
    WSGIProcessGroup flaskapp-ssl
    WSGIScriptAlias / $APP_DIR/app.wsgi
    
    <Directory $APP_DIR>
        WSGIApplicationGroup %{GLOBAL}
        Require all granted
    </Directory>
    
    # Logging
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_ssl_access.log combined
    
    # Enhanced security headers for HTTPS
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</VirtualHost>
</IfModule>
EOF

# Installeer mod_wsgi voor Flask
echo "Installing mod_wsgi..."
sudo apt install -y libapache2-mod-wsgi-py3 python3-pip python3-venv

# Enable mod_wsgi
sudo a2enmod wsgi

# Enable site
sudo a2ensite $DOMAIN.conf

# Disable default site
sudo a2dissite 000-default.conf

# Test configuratie
sudo apache2ctl configtest

if [ $? -eq 0 ]; then
    # Restart Apache
    sudo systemctl reload apache2
    
    echo "=== Virtual Host succesvol geconfigureerd ==="
    echo "Site: $DOMAIN"
    echo "Document Root: $APP_DIR"
    echo "WSGI enabled: YES"
    echo ""
    echo "Next steps:"
    echo "1. Deploy Flask application to $APP_DIR"
    echo "2. Create app.wsgi file"
    echo "3. Install SSL certificate (optional)"
    echo "4. Configure firewall rules"
else
    echo "ERROR: Apache configuration test failed!"
    exit 1
fi
