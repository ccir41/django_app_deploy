# django_app_deploy
A sample django app to deploy in AWS using Terraform


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

### Terraform -> create defination of aws resources (pre requirements)
- create s3 bucket to store terraform state (djang-quiz-tf-state)
- enable versioning of s3 bucket
- `aws s3api create-bucket --bucket djang-quiz-tf-state --region us-east-1`
- `aws s3api put-bucket-versioning --bucket djang-quiz-tf-state --versioning-configuration Status=Enabled`
- create dynamodb table for locking state of terraform (name: django-quiz-tf-state-lock and primarykey: LockID)
- `aws dynamodb create-table \
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
- `docker tag django-quiz:latest 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`
- `docker push 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`
- `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 067198536484.dkr.ecr.us-east-1.amazonaws.com`
- `docker pull 067198536484.dkr.ecr.us-east-1.amazonaws.com/django-quiz:latest`