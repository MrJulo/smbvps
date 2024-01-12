#!/bin/bash

echo "请输入要下载的URL（输入 'e' 退出）："
read url

if [ "$url" == "e" ]; then
    echo "用户选择退出。"
    exit 1
fi

download_folder="/var/lib/transmission-daemon/downloads"

# 使用wget下载文件
wget -P "$download_folder" "$url"
