#!/bin/bash
#执行文件名为$0,第一个参数为trojan服务器域名$1,第二个为端口$2,第三个参数为密码$3

echo "开始检查trojan go状态"
if [ -e "/root/trojan-go.zip" ]; then
    echo "trojan-go压缩包已存在，无需下载"
else 
    echo "trojan-go压缩包不存在，开始下载"
    wget --no-check-certificate -O /root/trojan-go.zip "https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip"
fi

echo "检查unzip是否安装"
if [ `command -v unzip` ];
then
       echo "unzip已经安装"
else
       echo "开始安装unzip"
       apt -y install unzip
fi

if [ -d "/root/trojan" ]; 
then
       echo "/root/trojan 已存在，无需解压"
else   
       echo "解压trojan go到根目录/root/trojan"
       unzip -o -d /root/trojan /root/trojan-go.zip      
fi

echo "配置trojan go的/root/trojan/config.json文件"
cat >/root/trojan/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": $2,
    "remote_addr": "127.0.0.1",
    "remote_port": 9091,
    "password": [
        "$3"
    ],
    "ssl": {
        "verify_hostname": false,
        "cert": "/data/$1/fullchain.crt",
        "key": "/data/$1/$1.key",
        "fallback_port": 9091,
        "sni": ""
    }
}
EOF

echo "检查trojan go系统服务状态"
if [ -e "/etc/systemd/system/trojan.service" ]; then
    echo "trojan-go系统服务存在，无需创建"
else 
    echo "trojan-go系统服务不存在，开始创建服务"
    cat >/etc/systemd/system/trojan.service<< EOF
    [Unit]
    Description=trojan
    Documentation=sanmaoban
    After=network.target

    [Service]
    Type=simple
    StandardError=journal
    ExecStart=/root/trojan/trojan-go -config /root/trojan/config.json
    ExecStop=/root/trojan/trojan-go
    LimitNOFILE=51200
    Restart=on-failure
    RestartSec=1s

    [Install]
    WantedBy=multi-user.target
EOF
fi

systemctl daemon-reload
systemctl restart trojan
systemctl enable trojan

if lsmod | grep bbr;
then
       echo "bbr已经安装。"
else
       echo "bbr没有安装,开始安装"
       echo "开启bbr"
       echo net.core.default_qdisc=fq >> /etc/sysctl.conf
       echo net.ipv4.tcp_congestion_control=bbr >> /etc/sysctl.conf
       echo net.ipv4.tcp_fastopen=3 >> /etc/sysctl.conf
       sysctl -p
fi

#禁用密码登陆vps
sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config
