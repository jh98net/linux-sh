sudo -i
sudo yum update -y

# net.ipv4.ip_forward
sudo sed -i '/#net.ipv4.ip_forward=/ a\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p /etc/sysctl.conf

# amazon-linux-extras
sudo yum install -y amazon-linux-extras yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --enable extras

# docker
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo systemctl enable docker.service
cd /var/lib/docker/
journalctl --disk-usage
journalctl --vacuum-time=2d

# docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# .net 6
sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
sudo yum install -y dotnet-sdk-6.0

# aws cli
yum install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# aws efs
sudo yum install -y amazon-efs-utils
# aws botocore
if [[ "$(python3 -V 2>&1)" =~ ^(Python 3.6.*) ]]; then
  sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.5.*) ]]; then
  sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.4.*) ]]; then
  sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
else
  sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi
sudo /usr/local/bin/pip3 install botocore
# mount efs
AWS_FILE_SYSTEM_ID="fs-0931712e9cf429544"
AWS_REGION="us-west-2"
AWS_EFS_PATH="/home/ec2-user/efs"
sudo mkdir efs
sudo mount -t efs -o tls fs-0931712e9cf429544:/ efs
fs-0931712e9cf429544.efs.us-west-2.amazonaws.com:/ /home/ec2-user/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0
# umount efs

# .net tools
dotnet tool update TinyFx.Tools.CentOSInstaller -g --no-cache --add-source http://123.127.93.180:25555/v3/index.json
dotnet tool update TinyFx.Tools.CentOSCmds -g --no-cache --add-source http://123.127.93.180:25555/v3/index.json
sudo sh -c "echo export \"\\\"PATH=\\\$PATH:\\\$HOME/.dotnet/tools:$HOME/.dotnet/tools\"\\\" > /etc/profile.d/dotnet-cli-tools-bin-path.sh"
source ./.bashrc

# portainer
docker run -dit -p 9000:9000 -v /home/ec2-user/programs/portainer:/data -v /var/run/docker.sock:/var/run/docker.sock --name portainer portainer/portainer:latest
# 添加配置文件内容
vim /usr/lib/systemd/system/docker.service
ExecStart= xxxx -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
# 保存启动文件后重启服务
systemctl daemon-reload
systemctl restart docker

# nginx-proxy-manager
version: '3.8'
services:
app:
image: 'jc21/nginx-proxy-manager:latest'
restart: unless-stopped
ports:
- '80:80'
- '81:81'
- '443:443'
volumes:
- /home/programs/nginx-proxy-manager/data:/data
- /home/programs/nginx-proxy-manager/letsencrypt:/etc/letsencrypt

# 默认站点：http://localhost:81 默认账号：admin@example.com changeme

# 导出导入数据
sudo apt remove mysql-client -y && sudo apt install mariadb-client -y

db_name="ing"
date="20230912"
# --no-data 不导出任何数据 --ignore-table忽略表
mysqldump -h my-db.cvn4awncphwh.us-west-2.rds.amazonaws.com \
  -u admin -p'jfjptKzEg2JRMsnp3Xud0' \
  --ssl-mode=DISABLED --set-gtid-purged=OFF \
  --single-transaction --routines \
  --no-create-db \
  ${db_name} | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip >${db_name}-${date}.sql.gz

db_name="gdb"
date="20230912"
mysqldump -h my-db.cvn4awncphwh.us-west-2.rds.amazonaws.com \
  -u admin -p'jfjptKzEg2JRMsnp3Xud0' \
  --ssl-mode=DISABLED --set-gtid-purged=OFF \
  --single-transaction --routines \
  --no-create-db \
  ${db_name} | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip >${db_name}-${date}.sql.gz

# 导入数据
db_name="ing"
date="20230912"
target_db="ing_uat"
gunzip <${db_name}-${date}.sql.gz | mysql -h192.168.1.128 -uroot -proot -P3306 ${target_db}

db_name="gdb"
date="20230912"
target_db="gdb_uat"
gunzip <${db_name}-${date}.sql.gz | mysql -h192.168.1.128 -uroot -proot -P3306 ${target_db}

# netdata 19999
# 有问题：bash <(curl -Ss https://my-netdata.io/kickstart.sh) --no-updates --stable-channel
docker run -d --name=netdata \
  -p 19999:19999 \
  -v /home/ec2-user/programs/netdata/config:/etc/netdata \
  -v /home/ec2-user/programs/netdata/lib:/var/lib/netdata \
  -v /home/ec2-user/programs/netdata/cache:/var/cache/netdata \
  -v /etc/passwd:/host/etc/passwd:ro \
  -v /etc/group:/host/etc/group:ro \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /etc/os-release:/host/etc/os-release:ro \
  --restart unless-stopped \
  --cap-add SYS_PTRACE \
  --security-opt apparmor=unconfined \
  netdata/netdata

# acme.sh
curl https://get.acme.sh | sh -s email=ja6922785@gmail.com
export GD_Key="gHKhjanoNQGD_M7T1Wh9SNEyWNEiDS5AYwu"
export GD_Secret="RaREMbtxZh1EqgZyL8jmuU"
acme.sh --issue --dns dns_gd -d ingame777.com -d '*.ingame777.com'
