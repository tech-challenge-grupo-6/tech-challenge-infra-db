provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_teste" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "VPC Teste"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_teste.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc_teste.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Subnet Pública A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc_teste.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Subnet Pública B"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_teste.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
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
    Name = "Security Group Banco de Dados"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "meu-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "Meu DB Subnet Group"
  }
}

resource "aws_db_instance" "bancodedados" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_name                = "databaseone"
  username               = "admin"
  password               = "mypassword"
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  tags = {
    Name = "Instância Banco de Dados"
  }
}
