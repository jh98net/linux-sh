#################### k3s-master 10.250.128.11 ###################
# 1. nfs server
NFS_PATH='/root/nfs4'
apt install -y nfs-kernel-server
mkdir -p $NFS_PATH
chown -R nobody:nogroup $NFS_PATH
chmod 777 $NFS_PATH
echo "$NFS_PATH *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server
# 2. k3s server
curl -sfL https://get.k3s.io | sh -
# 自动补全
apt install -y bash-completion
source /usr/share/bash-completion/bash_completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >>~/.bashrc
# 3. 获取node token
cat /var/lib/rancher/k3s/server/node-token

################### k3s-worker1 10.250.128.21 ###################
K3S_SERVER='10.250.128.11'
K3S_TOKEN=''
curl -sfL https://get.k3s.io | K3S_URL=https://$K3S_SERVER:6443 K3S_TOKEN=$K3S_TOKEN sh -
# nfs client
apt update && sudo apt install -y nfs-common
mkdir /root/nfs4
sudo mount -t nfs $K3S_SERVER:/root/nfs4 /root/nfs4
echo "$K3S_SERVER:/root/nfs4 /root/nfs4 nfs defaults 0 0" | sudo tee -a /etc/fstab
mount -a

##################### my-public 10.250.128.6 #####################
# openvpn
# kuboard docker
mkdir /root/apps/kuboard
chmod 777 /root/apps/kuboard
sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard \
  -p 8090:80/tcp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://10.250.128.6:80" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/apps/kuboard:/data \
  eipwork/kuboard:v3
# nacos nginx-proxy-manager quartzui

10.250.128.71 k3s-middle1
# redis rebitmq elk
10.250.128.81 k3s-msyql1

# autok3s
sudo docker run -d --privileged=true --restart=always --name autok3s -p 8080:8080 cnrancher/autok3s:v0.9.3

# traefik
- '--entrypoints.web.forwardedHeaders.insecure=true' - '--entrypoints.websecure.forwardedHeaders.insecure=true'
