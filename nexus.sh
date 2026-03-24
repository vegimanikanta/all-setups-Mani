#!/bin/bash

# Update system
sudo dnf update -y

# Install required packages
sudo dnf install -y wget java-17-amazon-corretto

# Create application directory
sudo mkdir -p /app
cd /app

# Download Nexus (stable archive version to avoid 404)
sudo wget https://download.sonatype.com/nexus/3/nexus-3.77.0-08-unix.tar.gz

# Extract
sudo tar -xvzf nexus-3.77.0-08-unix.tar.gz

# Rename folder
sudo mv nexus-3.77.0-08 nexus

# Create nexus user
sudo useradd nexus

# Fix permissions
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Configure run user
echo 'run_as_user="nexus"' | sudo tee /app/nexus/bin/nexus.rc

# Create systemd service
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Enable and start Nexus
sudo systemctl enable nexus
sudo systemctl start nexus

# Show status
sudo systemctl status nexus
