#!/bin/bash
sudo apt-get update -y
sudo apt install git -y
sudo git clone https://github.com/ccir41/django_app_deploy.git
cd django_app_deploy
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo docker volume create quiz_volume
sudo docker volume create quiz_static_data
sudo docker volume create quiz_media_data
sudo docker volume create postgres_data
sudo docker network create quiz_network
sudo docker build . -t django-quiz-app
sudo docker run -d -p 9000:9000 --name app --network quiz_network -v quiz_volume:/app -v quiz_static_data:/vol/web/static -v quiz_media_data:/vol/web/media django-quiz-app:latest
sudo docker build -f ./proxy/Dockerfile ./proxy -t django-quiz-proxy:latest
sudo docker run -d -p 80:8000 --name django-quiz-proxy --network quiz_network -v quiz_static_data:/vol/static -v quiz_media_data:/vol/media django-quiz-proxy:latest
sudo docker run -d -p 5432:5432 --network=quiz_network --name quiz-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=quiz_db -v postgres_data:/var/lib/postgresql/data postgres