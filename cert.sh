#!/bin/bash
#执行文件名为$0,第一个参数为服务器域名$1
echo "检查证书依赖socat是否安装"
if [ `command -v socat` ];
then
       echo "socat已经存在"
else
       echo "socat不存在，开始安装"
       apt-get -y install socat
fi
echo "开始安装证书"
wget -O - https://raw.githubusercontent.com/MrJulo/acme.sh/master/acme.sh | sh -s -- --install-online -m smb@smb.com
/root/.acme.sh/acme.sh --issue -d $1 --standalone -k ec-256 --force
mkdir /data
mkdir /data/$1
/root/.acme.sh/acme.sh --installcert -d $1 --fullchainpath /data/$1/fullchain.crt --keypath /data/$1/$1.key --ecc --force
cat /data/$1/$1.key /data/$1/fullchain.crt > /data/$1/$1.pem

