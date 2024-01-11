#!/bin/bash
#执行文件名为$0,第一个参数为域名$1,第二个为trojan-go端口$2,第三个为trojan-go密码$3，第四个为webdav端口$4，第五个为webdav和transmission的密码$5账户默认设定smb
apt-get update
echo "检查证书依赖socat是否安装"
if [ `command -v socat` ];
then
       echo "socat已经存在"
else
       echo "socat不存在，开始安装"
       apt-get -y install socat
fi

echo "开始检查证书状态"
if [ -e "/data/$1/fullchain.crt" ] && [ -e "/data/$1/$1.key" ]; then
    echo "证书已存在，请查看证书注册shell反馈，若有红色的代码错误，请单独重新注册证书，否则节点不通"
else 
    echo "证书不存在，开始安装注册"
    echo "开始安装证书"
    wget -O - https://raw.githubusercontent.com/MrJulo/acme.sh/master/acme.sh | sh -s -- --install-online -m smb@smb.com
    /root/.acme.sh/acme.sh --issue -d $1 --standalone -k ec-256 --force
    mkdir /data
    mkdir /data/$1
    /root/.acme.sh/acme.sh --installcert -d $1 --fullchainpath /data/$1/fullchain.crt --keypath /data/$1/$1.key --ecc --force
    cat /data/$1/$1.key /data/$1/fullchain.crt > /data/$1/$1.pem
fi

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

#禁用密码连接ssh
# 检查文件是否存在
if [ -e /etc/ssh/sshd_config ]; then
    # 检查文件中是否包含 "PasswordAuthentication yes"
    if grep -q "^PasswordAuthentication yes$" /etc/ssh/sshd_config; then
        # 如果包含，则用 sed 替换
        sed -i 's/^PasswordAuthentication yes$/PasswordAuthentication no/' /etc/ssh/sshd_config
    else
        # 如果不包含，则在文件末尾追加
        echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
    fi

    # 检查文件中是否包含 "PubkeyAuthentication yes"
    if grep -q "^PubkeyAuthentication no$" /etc/ssh/sshd_config; then
        # 如果包含，则用 sed 替换
        sed -i 's/^PubkeyAuthentication no$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
    else
        # 如果不包含，则在文件末尾追加
        echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
    fi
else
    echo "Error: /etc/ssh/sshd_config not found."
fi
service ssh restart

#安装transmission

echo "检查transmission-daemon是否安装"
if [ `command -v transmission-daemon` ];
then
       echo "transmission-daemon已经安装"
else
       echo "开始安装transmission-daemon"
       apt-get install -y transmission-daemon
fi


#Transmission的配置文件settings.json，默认在 /etc/transmission-daemon/目录下。安装完毕后，我们首先停止transmission软件，停止命令：

service transmission-daemon stop

#然后打开setting.json文件，我们将umask修改为0即可获得777权限，为的是能对文件服务器上的文件进行修改和删除，默认为18，有如下配置：

cat >/etc/transmission-daemon/settings.json <<EOF
{
    "alt-speed-down": 1000000,
    "alt-speed-enabled": false,
    "alt-speed-time-begin": 540,
    "alt-speed-time-day": 127,
    "alt-speed-time-enabled": false,
    "alt-speed-time-end": 1020,
    "alt-speed-up": 1,
    "bind-address-ipv4": "0.0.0.0",
    "bind-address-ipv6": "::",
    "blocklist-enabled": false,
    "blocklist-url": "http://www.example.com/blocklist",
    "cache-size-mb": 4,
    "dht-enabled": true,
    "download-dir": "/var/lib/transmission-daemon/downloads",
    "download-limit": 100,
    "download-limit-enabled": 0,
    "download-queue-enabled": true,
    "download-queue-size": 5,
    "encryption": 1,
    "idle-seeding-limit": 30,
    "idle-seeding-limit-enabled": false,
    "incomplete-dir": "/var/lib/transmission-daemon/Downloads",
    "incomplete-dir-enabled": false,
    "lpd-enabled": false,
    "max-peers-global": 200,
    "message-level": 1,
    "peer-congestion-algorithm": "",
    "peer-id-ttl-hours": 6,
    "peer-limit-global": 200,
    "peer-limit-per-torrent": 50,
    "peer-port": 51413,
    "peer-port-random-high": 65535,
    "peer-port-random-low": 49152,
    "peer-port-random-on-start": false,
    "peer-socket-tos": "default",
    "pex-enabled": true,
    "port-forwarding-enabled": false,
    "preallocation": 1,
    "prefetch-enabled": true,
    "queue-stalled-enabled": true,
    "queue-stalled-minutes": 30,
    "ratio-limit": 2,
    "ratio-limit-enabled": false,
    "rename-partial-files": true,
    "rpc-authentication-required": true,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-host-whitelist": "",
    "rpc-host-whitelist-enabled": false,
    "rpc-password": "$5",
    "rpc-port": 9091,
    "rpc-url": "/transmission/",
    "rpc-username": "smb",
    "rpc-whitelist": "127.0.0.1",
    "rpc-whitelist-enabled": false,
    "scrape-paused-torrents-enabled": true,
    "script-torrent-done-enabled": false,
    "script-torrent-done-filename": "",
    "seed-queue-enabled": false,
    "seed-queue-size": 10,
    "speed-limit-down": 1000000,
    "speed-limit-down-enabled": false,
    "speed-limit-up": 1,
    "speed-limit-up-enabled": true,
    "start-added-torrents": false,
    "trash-original-torrent-files": false,
    "umask": 0,
    "upload-limit": 100,
    "upload-limit-enabled": 0,
    "upload-slots-per-torrent": 7,
    "utp-enabled": true,
    "watch-dir": "/var/lib/transmission-daemon/downloads/uploads",
    "watch-dir-enabled": true
}
EOF

service transmission-daemon start

#建立一个监控自动下载种子的文件夹，对应上面配置中watch-dir选项路径,修改该文件夹的权限，使得软件可以修改已下载种子文件的后缀，来区分是否下载过

if [ -d "/var/lib/transmission-daemon/downloads/uploads" ]; 
then
       echo "/var/lib/transmission-daemon/downloads/uploads 已存在，无需解压"
else   
       mkdir /var/lib/transmission-daemon/downloads/uploads      
fi

chmod 777 /var/lib/transmission-daemon/downloads/uploads
usermod -aG debian-transmission www-data
chown -R debian-transmission:debian-transmission /var/lib/transmission-daemon/downloads

echo "检查apache2是否安装"
if [ `command -v apache2` ];
then
       echo "apache2已经存在"
else
       echo "apache2不存在，开始安装"
       apt-get -y install apache2
fi

if [ -d "/var/lib/transmission-daemon/downloads" ]; 
then
       echo "/var/lib/transmission-daemon/downloads 已存在，无需创建"
else  
       mkdir /var/lib/transmission-daemon/downloads
fi

#配置域名或ip地址到servername，不然会提示警告
echo "ServerName $1" | sudo tee -a /etc/apache2/apache2.conf > /dev/null

#更改端口为$4，此端口要和下面配置中的端口号一致
cat >/etc/apache2/ports.conf <<EOF
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen $4

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

#如果需要开启ssl
if apache2ctl -M | grep -q ssl_module; then
    echo "ssl module 已开启"
else
    a2enmod ssl
fi

#其中LimitExcept字段只允许下载，如果不限制则把此段代码去掉
cat >/etc/apache2/sites-enabled/000-default.conf <<EOF
<VirtualHost *:$4>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
        # SSL Configuration
    SSLEngine on
    SSLCertificateFile /data/$1/$1.pem
    SSLCertificateKeyFile /data/$1/$1.key

    Alias /webdav /var/lib/transmission-daemon/downloads

    <Location /webdav>
        DAV On
        AuthType Basic
        AuthName "WebDAV"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
        Options Indexes FollowSymLinks
        AllowOverride None
    </Location>
  # <LimitExcept GET HEAD OPTIONS>
      # Require all denied
  # </LimitExcept>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
#添加密码
htpasswd -bc /etc/apache2/.htpasswd smb $5

# 步骤 5：启用必要的模块
if apache2ctl -M | grep -q dav_module; then
    echo "dav module 已启用"
else
    a2enmod dav
fi
if apache2ctl -M | grep -q dav_fs_module; then
    echo "dav_fs module 已启用"
else
    a2enmod dav_fs
fi

# 步骤 6：重启 Apache2 服务
if [ -e "/var/lib/transmission-daemon/downloads/上传文件/index.html" ]; 
then
       echo "/var/lib/transmission-daemon/downloads/上传文件/index.html 已存在，无需创建"
else  
       mkdir /var/lib/transmission-daemon/downloads/上传文件
       wget https://raw.githubusercontent.com/MrJulo/smbvps/main/index.html -O /var/lib/transmission-daemon/downloads/上传文件/index.html
fi

service apache2 restart

# 安装rclone及fuse用来挂载网盘
if [ `command -v rclone` ];
then
       echo "rclone已经存在"
else
       echo "rclone不存在，开始安装"
       apt-get install rclone
fi

if command -v dpkg &> /dev/null && dpkg -l | grep -q fuse; then
    echo "fuse已经存在"
else
    echo "fuse不存在，开始安装"
    apt install -y fuse
fi
