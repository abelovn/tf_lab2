#! /bin/bash

sudo amazon-linux-extras install nginx1 -y

echo "Am NGINX: Hello there!\nEC2 instance: $HOSTNAME" | sudo tee /usr/share/nginx/html/index.html

sudo systemctl start nginx
sudo systemctl enable nginx

sudo yum install mariadb -y