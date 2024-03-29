#!/bin/bash

#Update OS with the latest patches
sudo yum update -y

#Set up EPEL Repository
sudo yum install -y epel-release

#Install Dependencies
sudo yum install wget -y
cd /tmp/
dnf install -y centos-release-rabbitmq-38
dnf --enablerepo=centos-release-rabbitmq-38 install -y rabbitmq-server
sudo systemctl enable rabbitmq-server

sudo systemctl start firewalld
sudo systemctl enable firewalld
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent

sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator

sudo systemctl restart rabbitmq-server