#!/bin/bash

mkdir -p /opt/shadowsocks
cd /opt/shadowsocks
wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.21.2/shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz

tar -xvf shadowsocks-v1.21.2.x86_64-unknown-linux-gnu.tar.xz

key=$(./ssservice genkey -m "aes-256-gcm")
port=9999

config_file="config.json"

cat <<EOL > $config_file
{
    "server": "0.0.0.0",
    "server_port": $port,
    "password": "$key",
    "method": "aes-256-gcm"
}
EOL

echo "端口(port): $port"
echo "密码(password): $key"

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

systemctl enable shadowsocks.service

systemctl start shadowsocks.service
