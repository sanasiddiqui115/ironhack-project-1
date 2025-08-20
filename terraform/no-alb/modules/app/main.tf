# Plain EC2 instances (Ansible will configure containers/ports)
resource "aws_instance" "vote" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_vote_id
  vpc_security_group_ids = [var.vote_sg_id]
  key_name               = var.key_pair_name
  tags                   = { Name = "vote" }
}

resource "aws_instance" "result" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_result_id
  vpc_security_group_ids = [var.result_sg_id]
  key_name               = var.key_pair_name
  tags                   = { Name = "result" }
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = { Name = "bastion" }
}

resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.frontend_sg_id]
  key_name               = var.key_pair_name

  tags = { Name = "frontend" }
}

resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.backend_sg_id]
  key_name               = var.key_pair_name

  tags = { Name = "backend" }
}

resource "aws_instance" "postgres" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.postgres_sg_id]
  key_name               = var.key_pair_name

  tags = { Name = "postgres" }
}

resource "aws_instance" "vote_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_vote_id
  vpc_security_group_ids = [var.vote_sg_id]
  key_name               = var.key_pair_name

  tags = { Name = "vote-2" }
}

resource "aws_instance" "result_2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_result_id
  vpc_security_group_ids = [var.result_sg_id]
  key_name               = var.key_pair_name

  tags = { Name = "result-2" }
}