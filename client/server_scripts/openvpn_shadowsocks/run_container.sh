# Run container
sudo docker run -d \
--privileged \
--log-driver none \
--restart always \
--cap-add=NET_ADMIN \
-p $SHADOWSOCKS_SERVER_PORT:$SHADOWSOCKS_SERVER_PORT/tcp \
-p $SHADOWSOCKS_SERVER_PORT:$SHADOWSOCKS_SERVER_PORT/udp \
--name $CONTAINER_NAME $CONTAINER_NAME

sudo docker network connect potok-dns-net $CONTAINER_NAME

# Create tun device if not exist
sudo docker exec -i $CONTAINER_NAME bash -c 'mkdir -p /dev/net; if [ ! -c /dev/net/tun ]; then mknod /dev/net/tun c 10 200; fi'

# Prevent to route packets outside of the container in case if server behind of the NAT
sudo docker exec -i $CONTAINER_NAME sh -c "ifconfig eth0:0 $SERVER_IP_ADDRESS netmask 255.255.255.255 up"

# OpenVPN config
sudo docker exec -i $CONTAINER_NAME bash -c 'mkdir -p /opt/potok/openvpn/clients; \
cd /opt/potok/openvpn && easyrsa init-pki; \
cd /opt/potok/openvpn && easyrsa gen-dh; \
cd /opt/potok/openvpn && cp pki/dh.pem /opt/potok/openvpn && easyrsa build-ca nopass << EOF yes EOF && easyrsa gen-req PotokReq nopass << EOF2 yes EOF2;\
cd /opt/potok/openvpn && easyrsa sign-req server PotokReq << EOF3 yes EOF3;\
cd /opt/potok/openvpn && openvpn --genkey --secret ta.key << EOF4;\
cd /opt/potok/openvpn && cp pki/ca.crt pki/issued/PotokReq.crt pki/private/PotokReq.key /opt/potok/openvpn;\
cd /opt/potok/openvpn && easyrsa gen-crl;\
cd /opt/potok/openvpn && cp pki/crl.pem /opt/potok/openvpn/crl.pem'
