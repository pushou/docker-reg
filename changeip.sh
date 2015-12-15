#!/bin/bash
MUSER='pouchou'
METH='eth1'
PORT='5000'
IPADDRM=$(ip a|grep inet|grep $METH|awk '{print $2}')
IFS=/; read -a IPADDRS <<<"$IPADDRM"
sed -i "s/MONIP/$IPADDR/" ./openssl.cnf 
cp ./openssl.cnf /etc/ssl/openssl.cnf
mkdir -p /etc/docker/certs.d/$IPADDRS:$PORT
mkdir -p /home/$MUSER/certs$IPADDRS
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /home/$MUSER/certs$IPADDRS/domain.key -x509 -days 1800 -out /home/$MUSER/certs$IPADDRS/domain.crt
cp /home/$MUSER/certs$IPADDRS/domain.crt /etc/docker/certs.d/$IPADDRS:$PORT/ca.crt
