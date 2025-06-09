#!/bin/bash

USERNAME="user_$(head /dev/urandom | tr -dc a-z0-9 | head -c 8)"
PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)"
PORT=$((RANDOM % 20000 + 20000))

apt update -y && apt install -y dante-server curl || {
    echo "❌ Không cài được dante-server. Hãy chạy script bằng quyền sudo/root."
    exit 1
}

useradd -M $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

IFACE=$(ip route | grep default | awk '{print $5}')
IP=$(curl -s ifconfig.me)

cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log

internal: 0.0.0.0 port = $PORT
external: $IFACE

method: username none
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    log: connect disconnect
}
EOF

touch /var/log/danted.log
chown nobody:nogroup /var/log/danted.log

systemctl restart danted
systemctl enable danted

echo ""
echo "🎉 SOCKS5 Proxy đã sẵn sàng!"
echo "➡️  Proxy: socks5://$USERNAME:$PASSWORD@$IP:$PORT"
