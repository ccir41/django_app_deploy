# django_app_deploy
A sample django app to deploy in AWS using Terraform

### Terraform -> create defination of aws resources (pre requirements)

#### Install Terraform in ubuntu
- go to https://developer.hashicorp.com/terraform/downloads
- `wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg`
- `echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list`
- `sudo apt update && sudo apt install terraform`
- `terraform --version`

#### Install AWS CLI
- follow link `https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html`
- `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`
- `unzip awscliv2.zip`
- `sudo ./aws/install`
- `sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update`
- `aws --version`
- `aws configure`

- `terraform init`

- create s3 bucket to store terraform state (djang-quiz-tf-state)
- enable versioning of s3 bucket
`
aws s3api create-bucket --bucket djang-quiz-tf-state --region us-east-1
aws s3api put-bucket-versioning --bucket djang-quiz-tf-state --versioning-configuration Status=Enabled
`
- create dynamodb table for locking state of terraform (name: django-quiz-tf-state-lock and primarykey: LockID)
`
aws dynamodb create-table \
    --table-name django-quiz-tf-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Name,Value=DjangoQuizTfStateLock \
    --region us-east-1
`

#### create terraform file in local machine
- go to deploy folder by changing path by cd deploy
- `terraform init`
- `terraform workspace new dev`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `terraform destroy`

##### for ECR
`docker tag django-quiz:latest 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`
`docker push 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`
`aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 067198536484.dkr.ecr.us-east-1.amazonaws.com`
`docker pull 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`
`docker volume create quiz_volume`
`docker run --name django-quiz-app -d -p 9000:9000 -v quiz_volume:/app 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`

`docker build . -t django-quiz`
#####


#### deploy
- go to deploy folder
- create s3 bucket to store terraform state (djang-quiz-tf-state)
- enable versioning of s3 bucket
`
aws s3api create-bucket --bucket djang-quiz-tf-state --region us-east-1
aws s3api put-bucket-versioning --bucket djang-quiz-tf-state --versioning-configuration Status=Enabled
`
- create dynamodb table for locking state of terraform (name: django-quiz-tf-state-lock and primarykey: LockID)
`
aws dynamodb create-table \
    --table-name django-quiz-tf-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --tags Key=Name,Value=DjangoQuizTfStateLock \
    --region us-east-1
`
- `terraform init`
- `terraform workspace new dev`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`
- `terraform destroy`


##### user data
docker volume create quiz_volume
docker volume create quiz_static_data
docker volume create quiz_media_data
docker network create quiz_network

docker build . -t django-quiz-app
docker run -d -p 9000:9000 --name app --network quiz_network -v quiz_volume:/app -v quiz_static_data:/vol/web/static -v quiz_media_data:/vol/web/media django-quiz-app:latest

docker build -f ./proxy/Dockerfile ./proxy -t django-quiz-proxy:latest
docker run -d -p 80:8000 --name django-quiz-proxy --network quiz_network -v quiz_static_data:/vol/static -v quiz_media_data:/vol/media django-quiz-proxy:latest