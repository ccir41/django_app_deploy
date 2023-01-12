data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20221206"]
  }
}

resource "aws_security_group" "web-sg" {
  name = "${local.prefix}-web-server-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-web-server-sg" }
  )
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu_server.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name
  user_data              = file("init-script.sh")
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = merge(
    local.common_tags,
    { "Name" = "${local.prefix}-web-server" }
  )
}
