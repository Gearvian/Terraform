#Bash Code for installing Docker and cloning the repo and then compose the docker image

#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy git curl

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

git clone https://github.com/faialotaibi/docker-compose-flask-app.git
cd docker-compose-flask-app
echo "REDIS_HOST=${redis_host}" > .env
docker compose up -d