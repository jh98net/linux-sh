#!/bin/bash

# 系统：ubuntu 22.04
# unbuntu 登录
# sudo -i 后输入密码
# echo 'ubuntu:ivknOgGhUI5FlQRUSXsjs' | sudo chpasswd
# curl -s http://ddns.xxyy888.com:9080/root/ubuntu-sh/-/raw/main/ubuntu.22.04.install.sh | sudo bash -s 6.0 true

dotnet_var=$1
is_china=$2

# sudo
sudo bash -c 'cat > /etc/sudoers.d/ubuntu' << EOF
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF

# 阿里云源
if [ "$is_china" == "true" ];then
echo "修改阿里云apt源"
sudo mv -f /etc/apt/sources.list /etc/apt/sources.list.bak
sudo bash -c 'cat > /etc/apt/sources.list' << EOF
deb http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
EOF
fi

# 常用
sudo apt update
#sudo apt upgrade -y
sudo apt install -y dotnet-sdk-$dotnet_var

# net.ipv4.ip_forward
sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf

# docker
sudo curl -fsSL https://get.docker.com | bash -s docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker pull mcr.microsoft.com/dotnet/sdk:$dotnet_var
sudo docker pull mcr.microsoft.com/dotnet/aspnet:$dotnet_var
sudo docker pull mcr.microsoft.com/dotnet/runtime:$dotnet_var

#sudo docker run -it busybox