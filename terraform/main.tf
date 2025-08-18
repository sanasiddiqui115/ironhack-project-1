provider "aws" {
  region = var.availability_zone
}

terraform {

  backend "s3" {

    bucket = "sana-project1-terraform-state"

    key = "terraform.tfstate" # The file path to store the state

    region = "us-east-1" # Your AWS region

    encrypt = true # Encrypt state file at rest

    dynamodb_table = "sana-terraform-state-block" # DynamoDB table for state locking

  }

}

resource "aws_vpc" "sana_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "SanaVPC"
  }
}

resource "aws_subnet" "sana_public_subnet" {
  vpc_id                  = aws_vpc.sana_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone

  tags = {
    Name = "SanaPublicSubnet"
  }
}

resource "aws_subnet" "sana_private_subnet" {
  vpc_id                  = aws_vpc.sana_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone

  tags = {
    Name = "SanaPrivateSubnet"
  }
}

resource "aws_internet_gateway" "sana_igw" {
  vpc_id = aws_vpc.sana_vpc.id

  tags = {
    Name = "SanaInternetGateway"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sana_public_subnet.id # Must be a public subnet
  depends_on    = [aws_internet_gateway.sana_igw]  # Ensure IGW is attached first

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route_table" "sana_public_rt" {
  vpc_id = aws_vpc.sana_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sana_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "sana_private_rt" {
  vpc_id = aws_vpc.sana_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "sana_public_rt_assoc" {
  subnet_id      = aws_subnet.sana_public_subnet.id
  route_table_id = aws_route_table.sana_public_rt.id
}

resource "aws_route_table_association" "sana_private_rt_assoc" {
  subnet_id      = aws_subnet.sana_private_subnet.id
  route_table_id = aws_route_table.sana_private_rt.id
}

resource "aws_security_group" "frontend_sg" {
  name        = "FrontendSecurityGroup"
  description = "Allowing incoming HTTP and HTTPS from the Internet"
  vpc_id      = aws_vpc.sana_vpc.id


  ingress {
    description = "Allowing incoming HTTP from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allowing incoming HTTPS from the Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "FrontendSecurityGroup"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "BackendSecurityGroup"
  description = "Allow Redis access from Frontend and connect to Postgres"
  vpc_id      = aws_vpc.sana_vpc.id

  ingress {
    description     = "Allow Redis from Frontend"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id] # ✅ only allow vote/result EC2 instances
  }

  ingress {
    description     = "Allow SSH from Frontend Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    description = "Allow outbound to Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Or use a more specific range or SG if needed
  }

  tags = {
    Name = "BackendSecurityGroup"
  }
}

resource "aws_security_group" "postgres_sg" {
  name        = "PostgresSecurityGroup"
  description = "Allowing incoming from Frontend and outbound to Postgres"
  vpc_id      = aws_vpc.sana_vpc.id

  ingress {
    description     = "Allowing incoming HTTP from the Internet"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id] # 👈 more secure
  }

  ingress {
    description     = "Allow SSH from Frontend Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  ingress {
    description = "Allowing incoming HTTPS from the Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PostgresSecurityGroup"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH only from my laptop"
  vpc_id      = aws_vpc.sana_vpc.id

  ingress {
    description = "SSH from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["95.91.210.84/32"] # My laptop's IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionSSHAccess"
  }
}

resource "aws_instance" "backend_server" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_private_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "backend server"
  }
}

resource "aws_instance" "frontend_server" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "frontend server"
  }
}

resource "aws_instance" "postgres_server" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_private_subnet.id
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "postgres server"
  }
}

resource "aws_instance" "bastion_server" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_public_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "frontend server"
  }
}