#!/bin/bash

sudo dnf install epel-release -y

sudo dnf install memcached -y

sudo systemctl enable memcached
sudo systemctl start memcached
sudo systemctl status memcached

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/memcached.conf
sudo systemctl restart memcached

firewall-cmd --add-port=11211/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=11211/tcp
firewall-cmd --permanent-to-runtime
firewall-cmd --reload
