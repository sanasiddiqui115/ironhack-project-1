provider "aws" {
  region = var.availability_zone
}

terraform {
  backend "s3" {
    bucket         = "sana-project1-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "sana-terraform-state-block"
  }
}

# --- VPC ---
resource "aws_vpc" "sana_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "SanaVPC"
  }
}

# --- Subnets ---
resource "aws_subnet" "sana_public_subnet" {
  vpc_id                  = aws_vpc.sana_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.subnet_availability_zone
  tags                    = { Name = "SanaPublicSubnet" }
}

resource "aws_subnet" "sana_private_subnet" {
  vpc_id                  = aws_vpc.sana_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.subnet_availability_zone
  tags                    = { Name = "SanaPrivateSubnet" }
}


# --- Internet Gateway + Route Tables ---
resource "aws_internet_gateway" "sana_igw" {
  vpc_id = aws_vpc.sana_vpc.id
  tags   = { Name = "SanaInternetGateway" }
}

resource "aws_route_table" "sana_public_rt" {
  vpc_id = aws_vpc.sana_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sana_igw.id
  }
  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "sana_public_rt_assoc" {
  subnet_id      = aws_subnet.sana_public_subnet.id
  route_table_id = aws_route_table.sana_public_rt.id
}

# --- Nat Gateway + Route Tables --- #

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sana_public_subnet.id

  tags = {
    Name = "SanaNATGateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.sana_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# --- Route Table Associations for private Instances --- #

resource "aws_route_table_association" "frontend_private_association" {
  subnet_id      = aws_subnet.sana_private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# --- Security Groups ---
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from my laptop"
  vpc_id      = aws_vpc.sana_vpc.id

  ingress {
    description = "SSH from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["95.91.210.84/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "BastionSG" }
}

resource "aws_security_group" "frontend_sg" {
  name   = "frontend-sg"
  vpc_id = aws_vpc.sana_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8081
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "FrontendSG" }
}

resource "aws_security_group" "backend_sg" {
  name   = "backend-sg"
  vpc_id = aws_vpc.sana_vpc.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "BackendSG" }
}

resource "aws_security_group" "postgres_sg" {
  name   = "postgres-sg"
  vpc_id = aws_vpc.sana_vpc.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.backend_sg.id,
    aws_security_group.frontend_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "PostgresSG" }
}

# --- EC2 Instances ---
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.sana_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = { Name = "bastion" }
}

resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_public_subnet.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  key_name               = var.key_pair_name

  tags = { Name = "frontend" }
}

resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_private_subnet.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_pair_name

  tags = { Name = "backend" }
}

resource "aws_instance" "postgres" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.sana_private_subnet.id
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  key_name               = var.key_pair_name

  tags = { Name = "postgres" }
}
