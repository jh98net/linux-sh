#!/bin/bash

# region methods

echo_msg() {
  local msg=$1
  local msg_color='\E[1;33m' #黄
  local msg_res='\E[0m'
  echo -e "${msg_color} ${msg} ${msg_res}"
}

# 更新阿里源
update_repos() {
  local is_china=$1
  if [ "$is_china" = "y" ]; then
    echo_msg "==> 添加阿里源"
    sudo sed -i '1i\Enabled: no' /etc/apt/sources.list.d/ubuntu.sources
    cat <<EOF | sudo tee -a /etc/apt/sources.list.d/aliyun.sources
Enabled: yes
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
  fi

  echo_msg "==> 更新软件源和软件列表"
  sudo apt update
  sudo apt upgrade -y
}

# 常规初始化
init_common() {
  #
  echo_msg "==> 安装常用软件包"
  sudo apt install -y vim wget curl lrzsz unzip git language-pack-zh-hans
  sudo apt install -y openssh-server openssh-client net-tools iputils-ping telnetd

  #
  echo_msg "==> 中文和时区"
  # export LANG="zh_CN.UTF-8"
  # sudo sed -i "s/^LANG=.*$/LANG=zh_CN.UTF-8/" /etc/default/locale
  timedatectl set-timezone Asia/Shanghai
  timedatectl status

  #
  echo_msg "==> 禁止AppArmor"
  sudo systemctl stop apparmor
  sudo systemctl disable apparmor

  #
  echo_msg "==> net.ipv4.ip_forward"
  sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
  sudo sysctl -w net.ipv4.ip_forward=1
  sudo sysctl -p /etc/sysctl.conf

  #
  echo_msg "==> journal日志"
  local journal_time='1w'
  local journal_max='100M'
  journalctl --vacuum-time=$journal_time
  journalctl --vacuum-size=$journal_max
  sudo sed -i "s/^#SystemMaxUse=.*$/SystemMaxUse=$journal_max/" /etc/systemd/journald.conf
  sudo sed -i "s/^#ForwardToSyslog=.*$/ForwardToSyslog=no/" /etc/systemd/journald.conf
  sudo systemctl restart systemd-journald.service
  # sudo journalctl --disk-usage
}

# 安装 docker
install_docker() {
  local is_install_docker=$1
  local docker_proxy=$2
  if [ "$is_install_docker" != "y" ]; then
    exit 0
  fi
  echo_msg "==> 安装 docker"
  # daemon.json
  local log_max='50m'
  sudo mkdir /etc/docker
  if [ "$docker_proxy" != "n" ]; then
    cat <<EOF | sudo tee -a /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "$log_max", "max-file": "3" },
  "registry-mirrors": [
    "$docker_proxy"
  ]
}
EOF
  else
    cat <<EOF | sudo tee -a /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "$log_max", "max-file": "3" }
}
EOF
  fi
  sudo chmod 644 /etc/docker/daemon.json
  # 设置存储库
  sudo apt install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings
  local docker_url='https://download.docker.com/linux/ubuntu'
  local gpg_file='/etc/apt/keyrings/docker.gpg'
  if [ "$docker_proxy" != "n" ]; then
    docker_url='https://mirrors.aliyun.com/docker-ce/linux/ubuntu'
  fi
  curl -fsSL $docker_url/gpg | sudo gpg --dearmor -o $gpg_file
  sudo chmod a+r $gpg_file
  echo "deb [arch=$(dpkg --print-architecture) signed-by=$gpg_file] $docker_url $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt update
  # 安装
  sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo usermod -aG docker $USER
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo docker info
}

# 安装.net sdk
install_dotnet_sdk() {
  local dotnet_version=$1
  if [ "$dotnet_version" = "n" ]; then
    exit 0
  fi

  echo_msg "==> 安装 .net sdk"
  # sudo add-apt-repository -y ppa:dotnet/backports
  local version_arr=(${dotnet_version//|/ })
  for item in "${version_arr[@]}"; do
    echo_msg "==> .net sdk ${item}"
    sudo apt install -y dotnet-sdk-$item
  done

  # .net tools
  export MY_DOTNET_TOOLS_PATH=/opt/dotnet-tools
  sudo mkdir -p $MY_DOTNET_TOOLS_PATH
  sudo chmod 777 $MY_DOTNET_TOOLS_PATH
  #sed -i "s/^DOTNET_TOOLS_PATH=.*$/# &/g" /etc/profile.d/dotnet.sh
  #sed -i '/^# DOTNET_TOOLS_PATH=.*$/a\DOTNET_TOOLS_PATH="\/opt\/dotnet-tools"' /etc/profile.d/dotnet.sh
  echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=true' | sudo tee -a /etc/profile.d/dotnet.sh
  echo 'export MY_DOTNET_TOOLS_PATH=/opt/dotnet-tools' | sudo tee -a /etc/profile.d/dotnet.sh
  echo 'export PATH=$PATH:$MY_DOTNET_TOOLS_PATH' | sudo tee -a /etc/profile.d/dotnet.sh
  source /etc/profile.d/dotnet.sh

  dotnet --list-sdks
}

# 安装 .net tool - lcmd
install_lcmd() {
  local is_install_lcmd=$1
  if [ "$is_install_lcmd" != "y" ]; then
    exit 0
  fi
  echo_msg "==> .net tool - lcmd"
  dotnet tool install TinyFx.Tools.LinuxCmd --tool-path $MY_DOTNET_TOOLS_PATH --no-cache --add-source http://192.168.1.120:8081/repository/nuget-hosted
  # sudo ln -s /opt/dotnet/tools/lcmd /usr/local/bin/lcmd
  lcmd update -s http://192.168.1.120:8081/repository/nuget-hosted
  cat <<EOF | sudo tee -a /etc/profile.d/lcmd.sh
alias dps="lcmd docker-ps"
EOF
  sudo chmod +x /etc/profile.d/lcmd.sh
  source /etc/profile.d/lcmd.sh
}
# endregion

IS_CHINA=${1:-'n'}         # 国内源 ==> y:使用
INSTALL_DOCKER=${2:-'y'}   # 安装docker ==> y:安装
DOCKER_PROXY=${3:-'n'}     # 安装docker proxy ==> n:无代理
DOTNET_VERSION=${4:-'8.0'} # 安装.net sdk ==> n:不安装 多版本:'6.0|8.0'
INSTALL_LCMD=${5:-'y'}     # 安装lcmd ==> y:安装

echo_msg "系统版本:"
lsb_release -a
echo_msg "执行参数: IS_CHINA=$IS_CHINA INSTALL_DOCKER=$INSTALL_DOCKER DOCKER_PROXY=$DOCKER_PROXY DOTNET_VERSION=$DOTNET_VERSION INSTALL_LCMD=$INSTALL_LCMD"

update_repos $IS_CHINA
init_common
install_docker $INSTALL_DOCKER $DOCKER_PROXY
install_dotnet_sdk $DOTNET_VERSION
install_lcmd $INSTALL_LCMD
