#!/bin/bash

COLOR='\E[1;33m' #黄
RES='\E[0m'

IS_CHINA=${1:-'y'}
if [ "$IS_CHINA" = "y" ]; then
  # 阿里源
  echo -e "${COLOR} ==> 更新阿里源 ${RES}"
  sudo sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' \
    -i.bak \
    /etc/yum.repos.d/almalinux*.repo
  sudo dnf clean all -y && sudo dnf makecache -y
fi

echo -e "${COLOR} ==> 更新软件包 ${RES}"
sudo dnf update -y

# 常用包
echo -e "${COLOR} ==> 安装常用软件包 ${RES}"
sudo dnf install -y wget gcc gcc-c++ openssl openssl-devel patch net-tools lrzsz unzip git

# firewalld
echo -e "${COLOR} ==> firewalld ${RES}"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# SELinux
echo -e "${COLOR} ==> SELinux ${RES}"
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
sudo setenforce 0

# net.ipv4.ip_forward
echo -e "${COLOR} ==> net.ipv4.ip_forward ${RES}"
sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf

# journal日志
echo -e "${COLOR} ==> journald ${RES}"
JOURNAL_LOG_MAX='10M'
sudo sed -i '/#SystemMaxUse=/ a\SystemMaxUse=$JOURNAL_LOG_MAX' /etc/systemd/journald.conf
sudo sed -i '/#ForwardToSyslog=/ a\ForwardToSyslog=no' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald.service
# sudo journalctl --disk-usage

# docker
DOCKER_VERSION=${2:-'-26.0.2'}
if [ "$DOCKER_VERSION" != "n" ]; then
  echo -e "${COLOR} ==> 安装 docker ${RES}"
  DOCKER_LOG_MAX='50m'
  USER_NAME=$(id -un)
  sudo mkdir /etc/docker
  cat <<EOF | sudo tee -a /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "$DOCKER_LOG_MAX", "max-file": "3" }
}
EOF
  sudo chmod 644 /etc/docker/daemon.json
  if [ "$IS_CHINA" = "y" ]; then
    sudo dnf config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  else
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  fi
  sudo dnf install -y docker-ce$DOCKER_VERSION docker-ce-cli$DOCKER_VERSION containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker
  sudo systemctl enable docker.service
  sudo gpasswd -a $USER_NAME docker
  /usr/bin/newgrp docker <<EONG
EONG
fi

# docker-compose
DOCKER_COMPOSE_VERSION=${3:-'2.27.0'}
if [ "$DOCKER_COMPOSE_VERSION" != "n" ]; then
  echo -e "${COLOR} ==> 安装 docker-compose ${RES}"
  sudo curl -SL https://github.com/docker/compose/releases/download/v$DOCKER_COMPOSE_VERSION/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi

# runlike -p <容器名>|<容器ID>
echo -e "${COLOR} ==> runlike ${RES}"
sudo dnf install -y pip
sudo wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
sudo python get-pip.py
pip install runlike
sudo rm get-pip.py

# .net sdk
DOTNET_VERSION=${4:-'8.0'}
if [ "$DOTNET_VERSION" != "n" ]; then
  echo -e "${COLOR} ==> 安装 .net sdk ${RES}"

  export DOTNET_ROOT=/opt/dotnet
  export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
  sudo mkdir $DOTNET_ROOT/tools
  sudo chmod 777 $DOTNET_ROOT/tools

  echo 'export DOTNET_ROOT=/opt/dotnet' | sudo tee /etc/profile.d/dotnet.sh
  echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=true' | sudo tee -a /etc/profile.d/dotnet.sh
  echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' | sudo tee -a /etc/profile.d/dotnet.sh
  sudo chmod +x /etc/profile.d/dotnet.sh

  sudo dnf install -y libicu krb5-libs openssl-libs zlib
  sudo dnf install -y https://repo.almalinux.org/almalinux/8/AppStream/x86_64/os/Packages/compat-openssl10-1.0.2o-4.el8_6.x86_64.rpm
  wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
  chmod +x ./dotnet-install.sh
  DOTNET_VERSION_ARRAY=(${DOTNET_VERSION//|/ })
  for item in "${DOTNET_VERSION_ARRAY[@]}"; do
    echo -e "${COLOR} ==> .net sdk ${item} ${RES}"
    sudo ./dotnet-install.sh --channel $item --install-dir /opt/dotnet
  done

  # sudo rm ./dotnet-install.sh
  dotnet --list-sdks
fi

# .net tool - lcmd
INSTALL_LCMD=${5:-'y'}
if [ "$INSTALL_LCMD" = "y" ]; then
  echo -e "${COLOR} ==> .net tool - lcmd ${RES}"
  dotnet tool install TinyFx.Tools.LinuxCmd --tool-path $DOTNET_ROOT/tools --no-cache --add-source http://192.168.1.120:8081/repository/nuget-hosted
  # sudo ln -s /opt/dotnet/tools/lcmd /usr/local/bin/lcmd
  lcmd update -s http://192.168.1.120:8081/repository/nuget-hosted
  sudo sed -i '$a alias dps="lcmd docker-ps"' /etc/bashrc
  source ~/.bashrc
  source /etc/bashrc
fi
