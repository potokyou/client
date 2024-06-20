cat > /opt/potok/openvpn/server.conf <<EOF
port $OPENVPN_PORT
proto $OPENVPN_TRANSPORT_PROTO
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
