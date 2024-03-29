#!/bin/bash

# Update OS with latest patches
apt update
apt upgrade -y

# Install nginx
apt install nginx -y

# Create Nginx conf file
echo 'upstream vproapp {
    server tomcat:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}' > /etc/nginx/sites-available/vproapp

# Remove default nginx conf
rm -rf /etc/nginx/sites-enabled/default

# Create link to activate website
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# Restart Nginx
systemctl start nginx
systemctl enable nginx
systemctl restart nginx

echo "All tasks completed successfully."
