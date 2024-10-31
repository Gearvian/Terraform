#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy git curl

curl -fsSL https://get.docker.com -o get-docker.sh

sudo sh ./get-docker.sh

sudo docker run -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=password -d mysql:latest