#!/bin/bash
#执行文件名为$0,第一个参数为webdav端口$1,第二个为ssl域名$2,第三个参数为webdav密码$3
# apache2安装及webdav搭建

apt-get update
apt-get -y install apache2

mkdir /var/lib/transmission-daemon/downloads

#配置域名或ip地址到servername，不然会提示警告
echo "ServerName $2" | sudo tee -a /etc/apache2/apache2.conf > /dev/null

#更改端口为$1，此端口要和下面配置中的端口号一致
cat >/etc/apache2/ports.conf <<EOF
# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

Listen $1

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
<VirtualHost *:$1>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
        # SSL Configuration
    SSLEngine on
    SSLCertificateFile /data/$2/$2.pem
    SSLCertificateKeyFile /data/$2/$2.key

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
htpasswd -bc /etc/apache2/.htpasswd smb $3

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
mkdir /var/lib/transmission-daemon/downloads/上传文件
wget https://raw.githubusercontent.com/MrJulo/smbvps/main/index.html -O /var/lib/transmission-daemon/downloads/上传文件/index.html

service apache2 restart
