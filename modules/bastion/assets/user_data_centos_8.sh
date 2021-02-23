#!/bin/bash
yum install -y nginx jq nfs-utils haproxy
sed -i "s|location / {|location / {\n             autoindex on;|g" /etc/nginx/nginx.conf
sed -i "s/80/8080/g" /etc/nginx/nginx.conf
rm -rf /usr/share/nginx/html/index.html
rm -rf /usr/share/nginx/html/poweredby.png
rm -rf /usr/share/nginx/html/nginx-logo.png

systemctl enable nginx
systemctl start nginx

systemctl enable haproxy
systemctl start haproxy

systemctl enable nfs-server.service
systemctl start nfs-server.service

mkdir -p /mnt/nfs/ocp
chmod -R 777 /mnt/nfs/ocp