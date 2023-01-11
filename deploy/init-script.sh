#!/bin/bash
sudo apt-get update -y
sudo snap install docker
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
sudo docker network create quiz_network
aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 160435408726.dkr.ecr.us-east-1.amazonaws.com
sudo docker run -d -p 5432:5432 --network=quiz_network --name quiz-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=quiz_db -v postgres_data:/var/lib/postgresql/data postgres
sudo docker run -d -p 9000:9000 --name app --network quiz_network -v quiz_volume:/app -v quiz_static_data:/vol/web/static -v quiz_media_data:/vol/web/media 160435408726.dkr.ecr.us-east-1.amazonaws.com/django-quiz-app:latest
sudo docker run -d -p 80:8000 --name django-quiz-proxy --network quiz_network -v quiz_static_data:/vol/static -v quiz_media_data:/vol/media 160435408726.dkr.ecr.us-east-1.amazonaws.com/django-quiz-app-proxy:latest