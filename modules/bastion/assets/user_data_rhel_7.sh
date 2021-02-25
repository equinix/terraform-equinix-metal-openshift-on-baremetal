#!/bin/bash

wget -O /tmp/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x /tmp/jq
cp /tmp/jq /usr/bin

cat <<EOT >> /etc/yum.repos.d/nginx.repo
[nginx]
name=nginx repo
baseurl=https://nginx.org/packages/rhel/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOT

yum install -y nginx nfs-utils haproxy

# Update nginx configs for file hosting
sed -i "s|location / {|location / {\n             autoindex on;|g" /etc/nginx/nginx.conf
sed -i "s/80/8080/g" /etc/nginx/nginx.conf
sed -i "s|location / {|location / {\n             autoindex on;|g" /etc/nginx/conf.d/default.conf
sed -i "s/80/8080/g" /etc/nginx/conf.d/default.conf
rm -rf /usr/share/nginx/html/index.html

# Update firewalld

## Openshift firewall exceptions
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --zone=public --permanent --add-port=6443/tcp
firewall-cmd --zone=public --permanent --add-port=22623/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=1936/tcp

## NFS firewall exceptions
firewall-cmd --zone=public --permanent --add-service=nfs
firewall-cmd --zone=public --permanent --add-service=mountd
firewall-cmd --zone=public --permanent --add-service=rpc-bind


# Restart services
systemctl restart firewalld
systemctl enable nginx
systemctl start nginx

systemctl enable haproxy
systemctl start haproxy

systemctl enable nfs-server.service
systemctl start nfs-server.service


mkdir -p /mnt/nfs/ocp
chmod -R 777 /mnt/nfs/ocp