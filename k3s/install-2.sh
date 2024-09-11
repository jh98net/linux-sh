10.250.128.11 k3s-master1
10.250.128.21 k3s-worker1
10.250.128.71 k3s-middle1
10.250.128.81 k3s-msyql1

# 10.2.0.10 vip
# 10.2.0.11 k3s-master1 nfs-master
# 10.2.0.12 k3s-master2 nfs-slave

# nfs server
apt install -y nfs-kernel-server rpcbind nfs-common rsync
mkdir -p /root/nfs4
chown -R nobody:nogroup /root/nfs4
chmod 777 /root/nfs4
sudo sed -i '1i\/root/nfs4 *(rw,sync,no_subtree_check)' /etc/exports
sudo exportfs -a
systemctl restart rpcbind && systemctl enable rpcbind
systemctl restart nfs-server && systemctl enable nfs-server
cat /var/lib/nfs/etab

# nfs client
apt install -y nfs-common
mkdir -p /root/nfs4
mount -t nfs 10.2.0.10:/root/nfs4 /root/nfs4
echo '10.2.0.10:/root/nfs4 /root/nfs4 nfs defaults 0 0' | sudo tee -a /etc/fstab
