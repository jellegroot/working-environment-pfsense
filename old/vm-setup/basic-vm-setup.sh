#!/bin/bash
# VM Setup Script voor Week 1 Project
# Dit script configureert een basis Ubuntu VM voor webserver gebruik

echo "=== VM Setup Script voor Webserver ==="
echo "Updating package lists..."

# Update systeem
sudo apt update && sudo apt upgrade -y

# Installeer basis tools
sudo apt install -y curl wget git vim htop ufw openssh-server

# Configureer SSH
echo "Configuring SSH..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Configureer firewall basis regels
echo "Setting up basic firewall rules..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Maak admin gebruiker aan (optioneel)
echo "Creating admin user..."
read -p "Enter admin username: " ADMIN_USER
if [ ! -z "$ADMIN_USER" ]; then
    sudo adduser $ADMIN_USER
    sudo usermod -aG sudo $ADMIN_USER
    echo "Admin user $ADMIN_USER created and added to sudo group"
fi

# Installeer Docker (optioneel voor containerized deployment)
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Set hostname
echo "Setting hostname..."
read -p "Enter hostname for this VM (e.g., webserver): " HOSTNAME
if [ ! -z "$HOSTNAME" ]; then
    sudo hostnamectl set-hostname $HOSTNAME
    echo "127.0.1.1 $HOSTNAME" | sudo tee -a /etc/hosts
fi

echo "=== Basic VM setup completed ==="
echo "Please reboot the system and run webserver-setup.sh next"
echo "Don't forget to:"
echo "1. Configure SSH keys"
echo "2. Set up port forwarding on your router"
echo "3. Update firewall rules as needed"
