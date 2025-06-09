#!/bin/bash

apt update && apt install -y dante-server curl

USER="user_$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)"
PASS="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)"

useradd -M -s /usr/sbin/nologin "$USER"
echo "$USER:$PASS" | chpasswd

IP=$(curl -s ifconfig.me)
PORT=$((10000 + RANDOM % 50000))

cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = $PORT
external: $IP

method: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    method: username
    log: connect disconnect error
}
EOF

systemctl restart danted
systemctl enable danted

echo "socks5://$USER:$PASS@$IP:$PORT"
