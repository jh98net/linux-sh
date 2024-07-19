
# aws cli
yum install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#登录
AKIAULAJHBY2BKJZPTHN
dyS3He0Ht1zSos3tvm4WsLhsTxHdW+SCp7b+6183
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 298519563828.dkr.ecr.us-west-2.amazonaws.com
docker tag xxyy.webapi:0.0.2 298519563828.dkr.ecr.us-west-2.amazonaws.com/xxyy.webapi:0.0.2
docker push 298519563828.dkr.ecr.us-west-2.amazonaws.com/xxyy.webapi:0.0.2


# amazon-efs-utils
sudo apt-get update
sudo apt-get -y install git binutils
git clone https://github.com/aws/efs-utils
cd efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
#botocore
sudo apt-get -y install wget
if echo $(python3 -V 2>&1) | grep -e "Python 3.6"; then
    sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif echo $(python3 -V 2>&1) | grep -e "Python 3.5"; then
    sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif echo $(python3 -V 2>&1) | grep -e "Python 3.4"; then
    sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
else
    sudo apt-get -y install python3-distutils
    sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi
sudo /usr/local/bin/pip3 install --target /usr/lib/python3/dist-packages botocore

# 挂载efs
sudo mkdir efs
sudo mount -t efs -o tls fs-0507084d3789989e2:/ efs