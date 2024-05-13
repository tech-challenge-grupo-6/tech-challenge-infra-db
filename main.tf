provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_teste" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    techchallenge = "VPC Teste"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_teste.id

  tags = {
    techchallenge = "IGW"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc_teste.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    techchallenge = "Subnet Pública A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc_teste.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    techchallenge = "Subnet Pública B"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_teste.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    techchallenge = "Public Route Table"
  }
}

resource "aws_route_table_association" "a_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "a_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "db_security_group" {
  vpc_id = aws_vpc.vpc_teste.id

  ingress {
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
    techchallenge = "Security Group Banco de Dados"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "meu-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    techchallenge = "Meu DB Subnet Group"
  }
}

resource "aws_db_instance" "controlador-pedidos" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_name                = "controlador_pedidos"
  username               = "admin"
  password               = "mypassword"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  tags = {
    techchallenge = "Instância Banco de Dados"
  }
}

resource "aws_db_instance" "controlador-pagamentos" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_name                = "controlador_pagamentos"
  username               = "admin"
  password               = "mypassword"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  tags = {
    techchallenge = "Instância Banco de Dados"
  }
}

resource "aws_db_instance" "controlador-producao" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_name                = "controlador_producao"
  username               = "admin"
  password               = "mypassword"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  tags = {
    techchallenge = "Instância Banco de Dados"
  }
}
