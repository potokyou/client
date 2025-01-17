#!/bin/bash

# This scripts copied from Potok client to Docker container to /opt/potok and launched every time container starts

echo "Container startup"
ifconfig eth0:0 $SERVER_IP_ADDRESS netmask 255.255.255.255 up

if [ ! -c /dev/net/tun ]; then mkdir -p /dev/net; mknod /dev/net/tun c 10 200; fi

# Allow traffic on the TUN interface.
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

# Allow forwarding traffic only from the VPN.
iptables -A FORWARD -i tun0 -o eth0 -s $OPENVPN_SUBNET_IP/$OPENVPN_SUBNET_CIDR -j ACCEPT
iptables -A FORWARD -i tun0 -o eth1 -s $OPENVPN_SUBNET_IP/$OPENVPN_SUBNET_CIDR -j ACCEPT

iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -t nat -A POSTROUTING -s $OPENVPN_SUBNET_IP/$OPENVPN_SUBNET_CIDR -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s $OPENVPN_SUBNET_IP/$OPENVPN_SUBNET_CIDR -o eth1 -j MASQUERADE

# kill daemons in case of restart
killall -KILL openvpn
killall -KILL ssserver

# start daemons if configured
if [ -f /opt/potok/openvpn/ca.crt ]; then (openvpn --config /opt/potok/openvpn/server.conf --daemon); fi
if [ -f /opt/potok/shadowsocks/ss-config.json ]; then (ssserver -c /opt/potok/shadowsocks/ss-config.json &); fi

tail -f /dev/null
