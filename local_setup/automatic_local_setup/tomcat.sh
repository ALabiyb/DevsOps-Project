#!/bin/bash

# Update OS with latest patches
echo "Updating OS with latest patches..."
yum update -y

# Set up Repository
echo "Setting up repository..."
yum install epel-release -y

# Install Dependencies
echo "Installing dependencies..."
dnf -y install java-11-openjdk java-11-openjdk-devel
dnf install git maven wget -y

# Change directory to /tmp
echo "Changing directory to /tmp..."
cd /tmp/

# Download & Extract Tomcat Package
echo "Downloading and extracting Tomcat package..."
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz

# Add tomcat user
echo "Adding Tomcat user..."
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

# Copy data to tomcat home directory
echo "Copying data to Tomcat home directory..."
cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/

# Make tomcat user the owner of tomcat home directory
echo "Setting Tomcat user as owner of Tomcat home directory..."
chown -R tomcat.tomcat /usr/local/tomcat

# Setup systemctl command for tomcat
echo "Setting up systemctl command for Tomcat..."
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd files
echo "Reloading systemd files..."
systemctl daemon-reload

# Start & Enable Tomcat service
echo "Starting and enabling Tomcat service..."
systemctl start tomcat
systemctl enable tomcat

git clone -b main https://github.com/ALabiyb/DevsOps-Project.git
cd DevsOps-Project/
mvn install
systemctl stop tomcat
sleep 20
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
#cp target/DevsOps-Project.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 10

# Enabling the firewall and allowing port 8080 to access Tomcat
echo "Enabling firewall and allowing port 8080..."
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload

echo "All commands executed successfully."