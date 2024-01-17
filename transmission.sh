#!/bin/bash
#执行文件名为$0,第一个参数为个参数为transmission密码$1

#安装transmission
apt-get update
apt-get install -y transmission-daemon

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
    "rpc-password": "$1",
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

mkdir /var/lib/transmission-daemon/downloads/uploads 
chmod 777 /var/lib/transmission-daemon/downloads/uploads
chown -R debian-transmission:debian-transmission /var/lib/transmission-daemon/downloads
