#!/bin/bash

sudo -i
sudo yum update -y

# 阿里源
sudo mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sudo yum clean all -y && sudo yum makecache -y && sudo yum update -y

# 时间同步
sudo yum install -y ntp
sudo cat <<EOF >>/var/spool/cron/root
00 12 * * * /usr/sbin/ntpdate -u ntp1.aliyun.com && /usr/sbin/hwclock -w
EOF
crontab -l
/usr/sbin/ntpdate -u ntp1.aliyun.com && /usr/sbin/hwclock -w

# firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# SELinux
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
sudo setenforce 0

# net.ipv4.ip_forward
sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf
# sudo cat /proc/sys/net/ipv4/ip_forward

# journal日志
JOURNAL_LOG_MAX='10M'
sudo sed -i '/#SystemMaxUse=/ a\SystemMaxUse=$JOURNAL_LOG_MAX' /etc/systemd/journald.conf
sudo sed -i '/#ForwardToSyslog=/ a\ForwardToSyslog=no' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald.service
# journalctl --disk-usage

# 常用包
sudo yum install -y wget gcc gcc-c++ openssl openssl-devel patch net-tools lrzsz

# docker
#docker kill $(docker ps -a -q)
#docker rm $(docker ps -a -q)
#docker rmi $(docker images -q)
#systemctl stop docker
#umount /var/lib/docker/devicemapper
#rm -rf /etc/docker
#rm -rf /run/docker
#rm -rf /var/lib/dockershim
#rm -rf /var/lib/docker
#yum remove -y docker-ce*
#yum remove -y containerd.io.x86_64

DOCKER_VERSION='' #默认最新版，指定如: '-24.0.9'
DOCKER_LOG_MAX='50m'
USER_NAME=$(id -un)
sudo mkdir /etc/docker
sudo cat >/etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "$DOCKER_LOG_MAX", "max-file": "3" }
}
EOF
sudo chmod 644 /etc/docker/daemon.json
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install -y docker-ce$DOCKER_VERSION docker-ce-cli$DOCKER_VERSION containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -a -G docker $USER_NAME
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker.service

# docker-compose
DOCKER_COMPOSE_VERSION='v2.26.0'
sudo curl -L https://github.com/docker/compose/releases/$DOCKER_COMPOSE_VERSION/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# runlike -p <容器名>|<容器ID>
sudo yum install -y wget
sudo wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
sudo python get-pip.py
sudo pip install runlike
sudo rm get-pip.py

# .net sdk
DOTNET_VERSION='6.0'
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sudo yum install -y dotnet-sdk-$DOTNET_VERSION

# .net tool - tcmd
dotnet tool update TinyFx.Tools.CentOSCmds -g --no-cache --add-source http://192.168.1.120:8081/repository/nuget-group/index.json
source /etc/profile
tcmd alias -a -n dps -c 'tcmd dockerps'
source ~/.bashrc
