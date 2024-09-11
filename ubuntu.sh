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
  sudo apt remove -y needrestart
  sudo apt install -y bash-completion language-pack-zh-hans
  sudo apt install -y vim lrzsz unzip lsof parted wget
  sudo apt install -y git nfs-common
  sudo apt install -y curl iproute2 iputils-ping telnet traceroute dnsutils net-tools

  #
  echo_msg "==> 中文和时区"
  sudo sed -i "s/^LANG=.*$/LANG=zh_CN.UTF-8/" /etc/default/locale
  timedatectl set-timezone Asia/Shanghai
  timedatectl status

  # 禁用ufw selinux swap
  systemctl stop ufw.service
  systemctl disable ufw.service
  sed -ri 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  sed -ri 's/.*swap.*/#&/' /etc/fstab
  swapoff -a

  # 打开数
  cat > /etc/security/limits.conf <<EOF
* soft noproc 65535
* hard noproc 65535

* soft nofile 65535
* hard nofile 65535
EOF
  echo 'ulimit -SHn 65535' >> /etc/profile
  ulimit -n 65535
  ulimit -u 65536

  # 内核优化
  cat >> /etc/sysctl.conf <<EOF
# 缓存优化
vm.swappiness=0

# tcp优化
net.ipv4.tcp_max_tw_buckets=5000
net.ipv4.tcp_max_syn_backlog=16384
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_fin_timeout=10

net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=3

net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.neigh.default.gc_stale_time=120
net.ipv4.conf.all.rp_filter=0 
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.default.arp_announce=2
net.ipv4.conf.lo.arp_announce=2
net.ipv4.conf.all.arp_announce=2
net.ipv4.ip_local_port_range=1024 65000

net.ipv4.ip_forward=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_synack_retries=2

net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.netfilter.nf_conntrack_max=2310720
net.ipv6.neigh.default.gc_thresh1=8192
net.ipv6.neigh.default.gc_thresh2=32768
net.ipv6.neigh.default.gc_thresh3=65536
net.core.netdev_max_backlog=16384
net.core.rmem_max=16777216 
net.core.wmem_max=16777216

net.core.somaxconn = 32768 
fs.inotify.max_user_instances=8192 
fs.inotify.max_user_watches=524288 
fs.file-max=52706963
fs.nr_open=52706963
kernel.pid_max = 4194303
net.bridge.bridge-nf-call-arptables=1

vm.overcommit_memory=1 
vm.panic_on_oom=0 
vm.max_map_count=262144
EOF
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
  sudo journalctl --disk-usage
}

# 安装 docker
install_docker() {
  local is_install_docker=$1
  local docker_proxy=$2
  if [ "$is_install_docker" != "y" ]; then
    return 0
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
    return 0
  fi

  echo_msg "==> 安装 .net sdk"
  # sudo add-apt-repository -y ppa:dotnet/backports
  local version_arr=(${dotnet_version//|/ })
  for item in "${version_arr[@]}"; do
    echo_msg "==> .net sdk ${item}"
    sudo apt install -y dotnet-sdk-$item
  done

  # .net tools
  local user_name=$(id -un)
  echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=true' | sudo tee -a /etc/profile.d/dotnet.sh
  echo "export MY_DOTNET_TOOLS_PATH=/$user_name/.dotnet/tools" | sudo tee -a /etc/profile.d/dotnet.sh
  echo 'export PATH=$PATH:$MY_DOTNET_TOOLS_PATH' | sudo tee -a /etc/profile.d/dotnet.sh
  source /etc/profile.d/dotnet.sh

  dotnet --list-sdks
}

# 安装 .net tool - lcmd
install_lcmd() {
  local install_lcmd=$1
  if [ "$install_lcmd" = "n" ]; then
    return 0
  fi
  echo_msg "==> .net tool - lcmd"
  if [ "$install_lcmd" = "y" ]; then
    dotnet tool install TinyFx.Tools.LinuxCmd -g --no-cache
    cat <<EOF | sudo tee -a /etc/profile.d/lcmd.sh
alias dps="lcmd docker-ps"
EOF
  else
    dotnet tool install TinyFx.Tools.LinuxCmd -g --no-cache --add-source $install_lcmd
    cat <<EOF | sudo tee -a /etc/profile.d/lcmd.sh
export NUGET_SOURCE=$install_lcmd
alias dps="lcmd docker-ps"
EOF
  fi
  sudo chmod +x /etc/profile.d/lcmd.sh
  source /etc/profile.d/lcmd.sh
}

# vm-tools
install_vm_tools() {
  local install_vm=$1
  if [ "$install_vm" = "y" ]; then
    echo_msg "==> 安装 vmware tools"
    sudo apt install -y open-vm-tools
  fi
}
# endregion

IS_CHINA=${1:-'n'}         # 国内源 ==> y:使用
INSTALL_DOCKER=${2:-'y'}   # 安装docker ==> y:安装
DOCKER_PROXY=${3:-'n'}     # 安装docker proxy ==> n:无代理
DOTNET_VERSION=${4:-'8.0'} # 安装.net sdk ==> n:不安装 多版本:'6.0|8.0'
INSTALL_LCMD=${5:-'n'}     # 安装lcmd ==> n:不安装 y:官方source
INSTALL_VM_TOOLS=${6:-'n'} # 安装vm_tools ==> y:安装

echo_msg "系统版本:"
lsb_release -a
echo_msg "执行参数: IS_CHINA=$IS_CHINA INSTALL_DOCKER=$INSTALL_DOCKER DOCKER_PROXY=$DOCKER_PROXY DOTNET_VERSION=$DOTNET_VERSION INSTALL_LCMD=$INSTALL_LCMD INSTALL_VM_TOOLS=$INSTALL_VM_TOOLS"

update_repos $IS_CHINA
init_common
install_docker $INSTALL_DOCKER $DOCKER_PROXY
install_dotnet_sdk $DOTNET_VERSION
install_lcmd $INSTALL_LCMD
install_vm_tools $INSTALL_VM_TOOLS

# /etc/netplan/50-cloud-init.yaml 修改IP
