terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = "~>1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}





data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]  
  }
}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg-web.id]

  user_data = file("data_nginx.sh")

  tags = {
    Name = "nginx"
    Owner = "a.belov.n@gmail.com"
  }

}


resource "aws_security_group" "sg-web" {
  name = "my-sg-web"
  description = "sg-web"
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  


 ingress {
    description = "Allow SSH inbound"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    
    Owner = "a.belov.n@gmail.com"
  }

}

resource "random_string" "mysql_password" {
  length  = 10
  special = false
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.20"
  instance_class       = "db.t2.micro"
  identifier           = "mysqldb"
  port                 = "3306"
  identifier_prefix    = null
  multi_az             = false
  storage_encrypted    = false
  final_snapshot_identifier = "DELETEME"
  skip_final_snapshot  = true
  snapshot_identifier  = null
  db_name                = var.DB_NAME
  username             = var.DB_USER
  password             = random_string.mysql_password.result
  vpc_security_group_ids = [aws_security_group.sg-db.id]
  
  tags = {
   
    Owner = "a.belov.n@gmail.com"
  }
}

resource "aws_security_group" "sg-db" {
  name = "my-sg-db"
  description = "sg-db"
  ingress {
    description = "http"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
   
    Owner = "a.belov.n@gmail.com"
  }

}





