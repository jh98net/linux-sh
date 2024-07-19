#!/bin/bash

# 2Core/8GB RAM/60G HDD
sudo apt-get update
sudo apt-get install -y wget curl tar gettext iptables
curl -sSL https://resource.fit2cloud.com/jumpserver/jumpserver/releases/latest/download/quick_start.sh | sudo bash

#地址: http://<JumpServer服务器IP地址>:<服务运行端口>
#用户名: admin
#密码: admin