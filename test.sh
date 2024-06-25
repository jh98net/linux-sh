#!/bin/bash

# source /dev/stdin <<<"$(curl -fsSLk https://raw.githubusercontent.com/jh98net/centos-sh/main/test.sh)" 123

STR=$1
echo $STR
export AAA=$STR
