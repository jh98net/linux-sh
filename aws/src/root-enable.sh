#!/bin/bash

echo 'root:ZBqKvLzguKkt31cxPt4X' | sudo chpasswd
sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl reload sshd
