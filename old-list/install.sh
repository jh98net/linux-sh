#!/bin/bash

items=(
    "启用root|./src/root-enable.sh"
    "禁用root|./src/root-disable.sh"
    "取消sudo输入密码|./src/sodu-nopwd.sh"
    "apt切换阿里云源|./src/apt-aliyun.sh"
    "安装dotnet-sdk-7.0|./src/dotnet-sdk.sh"
    "安装tcmd工具|./src/tcmd.sh"
    "测试|./src/echo.sh"
)

for i in "${!items[@]}";
do
    item=${items[$i]}
    echo "$i - $(cut -d'|' -f1 <<<"$item")"
done

read -p '输入选项:' cmdids
cids=(${cmdids//,/ }) 
for cid in ${cids[@]}
do
    item=${items[$cid]}
    bash $(cut -d'|' -f2 <<<"$item")
done 

