

docker swarm init
docker swarm join-token worker
# docker swarm join --token SWMTKN-1-4lzr2216s61ecbyayyqynjwybmxy5y5th5ru8aal2a0d1t2vn3-ekdgf4swlz8fiq4nnzgnbhr5u 192.168.99.100:2377

# 开放端口
# TCP协议端口 2377 ：集群管理端口
# TCP/UDP协议端口 7946 ：节点之间通讯端口（不开放则会负载均衡失效）
# UDP协议端口 4789 ：overlay网络通讯端口

# manager
firewall-cmd --zone=public --add-port=2377/tcp --permanent
# node
firewall-cmd --zone=public --add-port=7946/tcp --permanent
firewall-cmd --zone=public --add-port=7946/udp --permanent
firewall-cmd --zone=public --add-port=4789/tcp --permanent
firewall-cmd --zone=public --add-port=4789/udp --permanent
# 所有
firewall-cmd --reload
systemctl restart docker

# 分别修改机器的主机名，更改成 swarm01，swarm02 …
# hostnamectl set-hostname swarm01

# portainer
docker run -d --net=host --restart=unless-stopped --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /data/portainer_data:/data \
  portainer/portainer:2.19.4

# rancher
sudo docker run -d --restart=unless-stopped -p 8080:8080 --name rancher rancher/server
# 开放端口
# UDP协议端口 50 4500



