#!/bin/bash

DATABASE_PASS='admin123'

# Update OS with latest patches
sudo yum update -y

# Set Repository
sudo yum install epel-release -y

# Install MariaDB Package
sudo yum install git zip unzip mariadb-server -y

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
#mysql -u root -padmin123 <<MYSQL_SCRIPT
#create database accounts;
#grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123';
#FLUSH PRIVILEGES;
#exit
#MYSQL_SCRIPT


# Download Source code & Initialize Database.
cd /tmp/
git clone -b main https://github.com/ALabiyb/DevsOps-Project.git
sudo mysql -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
sudo mysql -u root -p"$DATABASE_PASS" accounts < src/db.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
mysql -u root -padmin123 accounts < /tmp/DevsOps-Project/src/db.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

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
