# Set Up redis in the server and creating the docker image and composing the image
#!/bin/sh

sudo apt-get update -yy
sudo apt-get install -yy git curl

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh

docker run -d -p 6379:6379 --name redis redis