#!/bin/bash

# Update OS with latest patches
sudo yum update -y

# Set Repository
sudo yum install -y epel-release

# Install Git Package
sudo yum install git -y

# Install MariaDB Package
sudo yum install mariadb-server -y

# Install zip unzip package
sudo yum install zip unzip -y

# Starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Run mysql secure installation script.
mysql_secure_installation <<EOF

Y
admin123
admin123
Y
n
Y
Y
Y
EOF

# Set DB name and users.
mysql -u root -padmin123 <<MYSQL_SCRIPT
create database accounts;
grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123';
FLUSH PRIVILEGES;
exit
MYSQL_SCRIPT

# Download Source code & Initialize Database.
git clone -b main https://github.com/ALabiyb/DevsOps-Project.git
cd DevsOps-Project
mysql -u root -padmin123 accounts < src/db.sql
mysql -u root -padmin123 accounts <<MYSQL_SCRIPT
show tables;
exit
MYSQL_SCRIPT

# Restart mariadb-server
systemctl restart mariadb

# Starting the firewall and allowing the mariadb to access from port no. 3306
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload
systemctl restart mariadb

echo "Script execution completed."