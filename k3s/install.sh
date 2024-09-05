# nfs server
NFS_PATH=${4:-'/root/nfs4'}

apt install -y nfs-kernel-server
mkdir -p $NFS_PATH
chown -R nobody:nogroup $NFS_PATH
chmod 777 $NFS_PATH
sudo sed -i '1i\${NFS_PATH} *(rw,sync,no_subtree_check)' /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server

# autok3s
sudo docker run -d --privileged=true --restart=always --name autok3s -p 8080:8080 cnrancher/autok3s:v0.9.3

# nacos
sudo docker run -d --privileged=true --restart=always \
  --name nacos -p 8848:8848 -p 9848:9848 \
  -m 2g -e JVM_XMS=1g -e JVM_XMX=1g -e JVM_XMN=512m \
  -e MODE=standalone -e PREFER_HOST_MODE=hostname -e TZ=Asia/Shanghai \
  -v /root/apps/nacos/logs:/home/nacos/logs \
  nacos/nacos-server:v2.4.1

# nfs client
apt update && sudo apt install nfs-common
mkdir /root/nfs4
sudo mount -t nfs 10.2.0.3:/root/nfs4 /root/nfs4
sudo vim /etc/fstab
10.2.0.3:/root/nfs4 /root/nfs4 nfs defaults 0 0
mount -a
