#!/bin/bash

# Start SSH service
service ssh start &

echo "Starting MySQL Database Server..."
echo "SSH Access: Port 22 (mapped to 2223)"
echo "MySQL Access: Port 3306"
echo "Database: webapp_db"
echo "User: webapp_user"

# Initialize database if needed
if [ ! -d "/var/lib/mysql/webapp_db" ]; then
    echo "Initializing database..."
    service mysql start
    
    # Run initialization scripts if they exist
    if [ -d "/tmp/init" ]; then
        for f in /tmp/init/*.sql; do
            if [ -f "$f" ]; then
                echo "Running $f..."
                mysql -u root -proot_password123 < "$f"
            fi
        done
    fi
    
    service mysql stop
fi

# Start MySQL in foreground
echo "Starting MySQL server..."
exec mysqld --user=mysql --bind-address=0.0.0.0 --console
