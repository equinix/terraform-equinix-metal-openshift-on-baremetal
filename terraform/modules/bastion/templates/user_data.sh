#!/bin/bash
yum install -y nginx
sed -i "s|location / {|location / {\n             autoindex on;|g" /etc/nginx/nginx.conf
rm -rf /usr/share/nginx/html/index.html
rm -rf /usr/share/nginx/html/poweredby.png
rm -rf /usr/share/nginx/html/nginx-logo.png
systemctl enable nginx
systemctl start nginx
