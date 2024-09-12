# 安装
apt install -y mysql-server mysql-client

# 密码和远程
sudo mysql -uroot
use mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mDUHlrY1g8HbiyZn'
FLUSH PRIVILEGES
update user set host='%' where user='root'
flush privileges
grant all on *.* to 'root'@'%'
flush privileges
#
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = 0.0.0.0
systemctl restart mysql

# 扩容
parted -s /dev/vdb mklabel gpt
parted -s /dev/vdb unit mib mkpart primary 0% 100%
mkfs.ext4 /dev/vdb1
mkdir /mnt/mysql-data
echo >>/etc/fstab
echo /dev/vdb1 /mnt/mysql-data ext4 defaults,noatime,nofail 0 0 >>/etc/fstab
mount /mnt/mysql-data

# 修改目录
sudo systemctl stop mysql
sudo cp -R -p /var/lib/mysql /mnt/mysql-data
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
datadir=/mnt/mysql-data/mysql
vim /etc/apparmor.d/usr.sbin.mysqld
/mnt/mysql-data/mysql/ r,
/mnt/mysql-data/mysql/** rwk,
sudo systemctl restart apparmor
sudo systemctl start mysql
