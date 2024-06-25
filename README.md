## 1. Ubuntu 24.04 LTS

### 1.1 国内安装

```bash
source /dev/stdin <<< \
  "$(curl -fsSLk https://raw.githubusercontent.com/jh98net/linux-sh/main/ubuntu.sh)" \
  y y 'https://docker.docker-cn.com.mp' '8.0' y
```

### 1.2 国外安装

```bash
source /dev/stdin <<< \
  "$(curl -fsSLk https://raw.githubusercontent.com/jh98net/linux-sh/main/ubuntu.sh)" \
  n y n '8.0' y
```

---

## 2. AlmaLinux

```bash
source /dev/stdin <<<\
  "$(curl -fsSLk https://raw.githubusercontent.com/jh98net/linux-sh/main/alma.sh)" \
  y '-26.0.2' '2.27.0' '8.0' y
```

---

## 9. 附录

### 9.1 参数

| 序号 | 参数                       | 描述                                     |
| ---: | :------------------------- | :--------------------------------------- |
|    1 | IS_CHINA=${1:-'y'}         | 国内源 ==> y:使用                        |
|    2 | INSTALL_DOCKER=${2:-'y'}   | 安装 docker ==> y:安装                   |
|    3 | DOCKER_PROXY=${3:-'n'}     | 安装 docker proxy ==> n:无代理           |
|    4 | DOTNET_VERSION=${4:-'8.0'} | 安装.net sdk ==> n:不安装 多版本竖线分割 |
|    5 | INSTALL_LCMD=${5:-'y'}     | 安装 lcmd ==> y:安装                     |

### 9.2 docker proxy

- 申请域名: https://www.registry.com.mp/ 账号: jh98net@sina.com
- FreeCDN: https://hostry.com/ 账号: jh98net@gmail.com
- 搭建 docker-proxy 脚本: https://github.com/kubesre/docker-registry-mirrors
- 已配置的 URL: https://docker.docker-cn.com.mp

### 9.3 权限

```bash
# sudo 权限
echo "$(id -un) ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# root 密码和登录
ROOT_PWD='root'
echo "root:$ROOT_PWD" | sudo chpasswd
sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl reload ssh
```
