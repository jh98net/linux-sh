#!/bin/bash

sudo bash -c 'cat > /etc/sudoers.d/ubuntu' << EOF
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF

# net.ipv4.ip_forward
sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf

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

# 常用
sudo apt update
sudo apt upgrade -y
sudo apt-get install open-vm-tools -y

# docker + docker-compose
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo systemctl enable docker
sudo systemctl status docker
#sudo curl -fsSL https://get.docker.com | bash -s docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# dotnet 6.0
sudo apt install -y dotnet-sdk-6.0

# gitlab runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh|sudo bash
sudo apt update
sudo apt-get install gitlab-runner

# tcmd
dotnet tool update TinyFx.Tools.UbuntuCmds -g --no-cache --add-source http://123.127.93.180:25555/v3/index.json
sudo sh -c "echo export \"\\\"PATH=\\\$PATH:\\\$HOME/.dotnet/tools:$HOME/.dotnet/tools\"\\\" > /etc/profile.d/dotnet-cli-tools-bin-path.sh"
source /etc/profile


# container设置不同时间
docker exec -it xxx /bin/bash
apt-get update && apt-get upgrade -y && apt-get install -y git make gcc g++
git clone https://github.com/wolfcw/libfaketime.git
cd libfaketime  && make install
export LD_PRELOAD=/usr/local/lib/faketime/libfaketime.so.1 FAKETIME="2020-01-01 00:01:02"



