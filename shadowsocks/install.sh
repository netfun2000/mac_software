#!/bin/bash

mkdir -p /opt/shadowsocks
cd /opt/shadowsocks
# wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.21.2/shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz
wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.23.4/shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz

# tar -xvf shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz
tar -xvf shadowsocks-v1.23.4.x86_64-unknown-linux-gnu.tar.xz

method="aes-256-gcm"
password=$(./ssservice genkey -m "$method")
port=9999

config_file="config.json"

cat <<EOL > $config_file
{
    "server": "0.0.0.0",
    "server_port": $port,
    "password": "$password",
    "method": "$method"
}
EOL

SERVICE_FILE="/etc/systemd/system/shadowsocks.service"
SSSERVER_CMD="/opt/shadowsocks/ssserver -c /opt/shadowsocks/config.json"

echo "[Unit]
Description=Shadowsocks Server
After=network.target

[Service]
ExecStart=/bin/bash -c '$SSSERVER_CMD'
Restart=on-failure
User=nobody
Group=nogroup
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target" > $SERVICE_FILE

systemctl daemon-reload
systemctl start shadowsocks.service
systemctl enable shadowsocks.service

ip=$(hostname -I | awk '{print $1}')

base64_credentials=$(echo -n "$method:$password" | base64 -w 0)
server_url="ss://$base64_credentials@$ip:$port#cloudcone"

printf "\r\n\r\n"
echo "######################### finish ################################"
echo "Shadowsocks 服务器信息："
echo "IP地址: $ip"
echo "端口号: $port"
echo "加密方式: $method"
echo "密码: $password"
echo "服务器URL: $server_url"
