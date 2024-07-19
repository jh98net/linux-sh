mkdir ./install
sudo wget -c https://gitee.com/JohnyJiang/ubuntu-sh/raw/main/install.tar.gz | sudo tar -zxvf install.tar.gz -C ./install



tar -cvzf archive install.tar.gz "./*"


server硬件 mysql+redis+RabbitMQ+QuartzUI
    +gitlab+BaGet+Verdaccio
    16G+500G
开发服务器
    8G+200G

harbor 硬件需求 ubuntu
    8G内存+200G硬盘

k3s 硬件需求
    2G+50G*1
    8G内存+100G硬盘*2

jira+Confluence
    8G内存

/boot/efi 250m
/boot 500m
/   剩余

