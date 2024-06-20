cat > /opt/potok/openvpn/server.conf <<EOF
port $OPENVPN_PORT
proto tcp
dev tun
ca /opt/potok/openvpn/ca.crt
cert /opt/potok/openvpn/PotokReq.crt
key /opt/potok/openvpn/PotokReq.key
dh /opt/potok/openvpn/dh.pem
server $OPENVPN_SUBNET_IP $OPENVPN_SUBNET_MASK
ifconfig-pool-persist ipp.txt
duplicate-cn
keepalive 10 120
$OPENVPN_NCP_DISABLE
cipher $OPENVPN_CIPHER
data-ciphers $OPENVPN_CIPHER
auth $OPENVPN_HASH
user nobody
group nobody
persist-key
persist-tun
crl-verify /opt/potok/openvpn/crl.pem
status openvpn-status.log
verb 1
tls-server
tls-version-min 1.2
$OPENVPN_TLS_AUTH
$OPENVPN_ADDITIONAL_SERVER_CONFIG
EOF

# Cloak config
mkdir -p /opt/potok/cloak
cd /opt/potok/cloak || exit 1
CLOAK_ADMIN_UID=$(ck-server -u) && echo $CLOAK_ADMIN_UID > /opt/potok/cloak/cloak_admin_uid.key
CLOAK_BYPASS_UID=$(ck-server -u) && echo $CLOAK_BYPASS_UID > /opt/potok/cloak/cloak_bypass_uid.key
IFS=, read CLOAK_PUBLIC_KEY CLOAK_PRIVATE_KEY <<<$(ck-server -k)
echo $CLOAK_PUBLIC_KEY > /opt/potok/cloak/cloak_public.key
echo $CLOAK_PRIVATE_KEY > /opt/potok/cloak/cloak_private.key

cat > /opt/potok/cloak/ck-config.json <<EOF
{
  "ProxyBook": {
     "openvpn": [
     "tcp",
     "localhost:$OPENVPN_PORT"
    ],
     "shadowsocks": [
     "tcp",
     "localhost:$SHADOWSOCKS_SERVER_PORT"
   ]
  },
  "BypassUID": [
    "$CLOAK_BYPASS_UID"
  ],
  "BindAddr":[":443"],
  "RedirAddr": "$FAKE_WEB_SITE_ADDRESS",
  "PrivateKey": "$CLOAK_PRIVATE_KEY",
  "AdminUID": "$CLOAK_ADMIN_UID",
  "DatabasePath": "userinfo.db",
  "StreamTimeout": 300
}
EOF

# ShadowSocks config
mkdir -p /opt/potok/shadowsocks; \
cd /opt/potok/shadowsocks || exit 1; \
SHADOWSOCKS_PASSWORD=$(openssl rand -base64 32 | tr "=" "A" | tr "+" "A" | tr "/" "A")
echo $SHADOWSOCKS_PASSWORD > /opt/potok/shadowsocks/shadowsocks.key
cat > /opt/potok/shadowsocks/ss-config.json <<EOF
{
    "local_port": 8585,
    "method": "$SHADOWSOCKS_CIPHER",
    "password": "$SHADOWSOCKS_PASSWORD",
    "server": "0.0.0.0",
    "server_port": $SHADOWSOCKS_SERVER_PORT,
    "timeout": 60
}
EOF
