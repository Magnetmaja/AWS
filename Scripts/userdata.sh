#!/bin/bash
yum update -y
amazon-linux-extras install nginx1.12 -y
systemctl start nginx
systemctl enable nginx
sed -i -e "0,/nginx/s/nginx/MyNameIsAnsofy/" /usr/share/nginx/html/index.html