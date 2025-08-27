#!/bin/bash

# Wait for Gitea to be ready
echo "Waiting for Gitea to start..."
sleep 10

# Check if admin user already exists
if /usr/local/bin/gitea admin user list --admin | grep -q "admin"; then
    echo "Admin user already exists, skipping creation."
else
    echo "Creating default admin user..."
    /usr/local/bin/gitea admin user create \
        --admin \
        --username admin \
        --password admin123 \
        --email admin@gitea.local \
        --must-change-password \
        --config /data/gitea/conf/app.ini
    
    echo "Default admin user created!"
    echo "Username: admin"
    echo "Password: admin123 (must be changed on first login)"
    echo "Email: admin@gitea.local"
fi
