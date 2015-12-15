#!/bin/bash
MUSER='pouchou'
METH='eth1'
PORT='5000'
DEFAULT_DOCKER='/etc/default/docker'
MYLINE='DOCKER_OPTS="—insecure-registry localhost:5000  —insecure-registry'
LIGNE="$MYLINE $IPADDRS:$PORT \""
echo $LIGNE
IPADDRM=$(ip a|grep inet|grep $METH|awk '{print $2}')
OLDIFS=IFS
IFS=/; read -a IPADDRS <<<"$IPADDRM"
IFS=OLDIFS
sed -i "s/MONIP/$IPADDR/" ./openssl.cnf 
cp ./openssl.cnf /etc/ssl/openssl.cnf
mkdir -p /etc/docker/certs.d/$IPADDRS:$PORT
mkdir -p /home/$MUSER/certs$IPADDRS
openssl req -newkey rsa:4096 -nodes -sha256 -keyout /home/$MUSER/certs$IPADDRS/domain.key -x509 -days 1800 -out /home/$MUSER/certs$IPADDRS/domain.crt
cp /home/$MUSER/certs$IPADDRS/domain.crt /etc/docker/certs.d/$IPADDRS:$PORT/ca.crt
chown -R $MUSER.$MUSER /home/$MUSER/
DOCKER_OPTS="—insecure-registry localhost:5000  —insecure-registry $IPADDRS:$PORT"
sed -i '/DOCKER_OPTS/d' $DEFAULT_DOCKER
echo $LIGNE >> $DEFAULT_DOCKER
service docker restart
docker run -d -p $PORT:5000 --restart=always --name registry_$IPADDRS -v  /home/$MUSER/data:/var/lib/registry -v /home/$MUSER/certs$IPADDRS:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/home/$MUSER/certs$IPADDRS/domain.crt -e REGISTRY_HTTP_TLS_KEY=/home/$MUSER/certs$IPADDRS/domain.key registry:2
