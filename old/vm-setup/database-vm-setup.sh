#!/bin/bash
# Database VM Setup Script
# Configureert een Ubuntu VM voor database gebruik

echo "=== Database VM Setup Script ==="
echo "Updating package lists..."

# Update systeem
sudo apt update && sudo apt upgrade -y

# Installeer basis tools
sudo apt install -y curl wget git vim htop ufw openssh-server

# Configureer SSH
echo "Configuring SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Configureer firewall voor database server
echo "Setting up firewall rules for database server..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh

# MySQL/MariaDB poorten
sudo ufw allow 3306/tcp comment 'MySQL'

# PostgreSQL poort (als je PostgreSQL gebruikt)
sudo ufw allow 5432/tcp comment 'PostgreSQL'

# Set hostname
echo "Setting hostname..."
read -p "Enter hostname for this VM (e.g., dbserver): " HOSTNAME
if [ ! -z "$HOSTNAME" ]; then
    sudo hostnamectl set-hostname $HOSTNAME
    echo "127.0.1.1 $HOSTNAME" | sudo tee -a /etc/hosts
fi

# Maak database gebruiker aan
echo "Creating database admin user..."
read -p "Enter database admin username: " DB_ADMIN
if [ ! -z "$DB_ADMIN" ]; then
    sudo adduser $DB_ADMIN
    sudo usermod -aG sudo $DB_ADMIN
    echo "Database admin user $DB_ADMIN created"
fi

echo "=== Database VM basic setup completed ==="
echo "Next steps:"
echo "1. Run database-install.sh to install MySQL/PostgreSQL"
echo "2. Configure database security"
echo "3. Create application database and users"
echo "4. Test connection from webserver VM"
