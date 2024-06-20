mkdir -p /opt/potok/wireguard
cd /opt/potok/wireguard
WIREGUARD_SERVER_PRIVATE_KEY=$(wg genkey)
echo $WIREGUARD_SERVER_PRIVATE_KEY > /opt/potok/wireguard/wireguard_server_private_key.key

WIREGUARD_SERVER_PUBLIC_KEY=$(echo $WIREGUARD_SERVER_PRIVATE_KEY | wg pubkey)
echo $WIREGUARD_SERVER_PUBLIC_KEY > /opt/potok/wireguard/wireguard_server_public_key.key

WIREGUARD_PSK=$(wg genpsk)
echo $WIREGUARD_PSK > /opt/potok/wireguard/wireguard_psk.key

cat > /opt/potok/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $WIREGUARD_SERVER_PRIVATE_KEY
Address = $WIREGUARD_SUBNET_IP/$WIREGUARD_SUBNET_CIDR
ListenPort = $WIREGUARD_SERVER_PORT
EOF
