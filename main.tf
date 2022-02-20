terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow mysql inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "MySql"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "testmysql" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = var.ec2_type
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = var.key_name

  user_data = <<EOF
#!/bin/bash
yum install -y mysql
EOF
  tags = {
    Name = "testmysql"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "doka"
  password               = var.dbpassword
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  apply_immediately      = true
  multi_az               = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.allow_mysql.id]
  tags = {
    Name = "mysql-server-01"
  }
}
