#1- Network (VPC, Subnets, IGW, NGW, Route Tables, Route Table Assosciations) 
module "network" {
  source = "./modules/networks"
}


# 2- Security groups (ALB, vote, result, bastion, backend, postgres)
module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
  # optionally pass your existing bastion SG id if you want SSH
  #bastion_sg_id = output
}


# 3- Certificate for vote/result (multi-SAN) + validation
module "cert" {
  source      = "./modules/cert"
  root_domain = var.root_domain
}



# 4- ALB + Target groups + HTTPS Listener + host-based rules
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  alb_sg_id = module.security.alb_sg_id
  cert_arn  = module.cert.certificate_arn

  # targets
  vote_instance_id   = module.app.vote_instance_id
  result_instance_id = module.app.result_instance_id

  vote_instance2_id   = module.app.vote_instance2_id
  result_instance2_id = module.app.result_instance2_id

  root_domain = var.root_domain
}


# 5- EC2 Instances
module "app" {
  source = "./modules/app"


  # Networking
  subnet_vote_id    = module.network.private_subnet_a_id
  subnet_result_id  = module.network.private_subnet_b_id
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id

  vote_sg_id     = module.security.vote_sg_id
  result_sg_id   = module.security.result_sg_id
  bastion_sg_id  = module.security.bastion_sg_id
  backend_sg_id  = module.security.backend_sg_id
  postgres_sg_id = module.security.postgres_sg_id
  frontend_sg_id = module.security.frontend_sg_id

  key_pair_name = var.key_pair_name
  ami_id        = var.ami_id
}

# 6- DNS
module "dns" {
  source       = "./modules/dns"
  root_domain  = var.root_domain
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}