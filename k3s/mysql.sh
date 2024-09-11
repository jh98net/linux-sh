# 安装
apt install -y mysql-server mysql-client

# 密码和远程
sudo mysql -uroot
use mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '新密码'
FLUSH PRIVILEGES
update user set host='%' where user='root'
flush privileges
grant all on *.* to 'root'@'%'
flush privileges
#
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
bind-address = 0.0.0.0
systemctl restart mysql

# 修改目录
sudo systemctl stop mysql
sudo cp -R -p /var/lib/mysql /newpath
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
datadir=/newpath/mysql
vim /etc/apparmor.d/usr.sbin.mysqld
/newpath/mysql/ r,
/newpath/mysql/** rwk,
sudo systemctl restart apparmor
sudo systemctl start mysql
