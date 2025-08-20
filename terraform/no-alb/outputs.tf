# --- Network ---
output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "private_subnet_a_id" {
  value = module.network.private_subnet_a_id
}
output "private_subnet_b_id" {
  value = module.network.private_subnet_b_id
}

# --- Security groups (add only those you need) ---
output "alb_sg_id" {
  value = module.security.alb_sg_id
}
output "vote_sg_id" {
  value = module.security.vote_sg_id
}
output "result_sg_id" {
  value = module.security.result_sg_id
}
# If you added these in the security module:
# output "bastion_sg_id"  { value = module.security.bastion_sg_id }
# output "frontend_sg_id" { value = module.security.frontend_sg_id }
# output "backend_sg_id"  { value = module.security.backend_sg_id }
# output "postgres_sg_id" { value = module.security.postgres_sg_id }

# --- App instances ---
output "bastion_public_ip" { value = module.app.bastion_public_ip }

output "frontend_private_ip" { value = module.app.frontend_private_ip }
output "backend_private_ip" { value = module.app.backend_private_ip }
output "postgres_private_ip" { value = module.app.postgres_private_ip }
output "vote_private_ip" { value = module.app.vote_private_ip }
output "result_private_ip" { value = module.app.result_private_ip }

output "vote_instance_id" { value = module.app.vote_instance_id }
output "result_instance_id" { value = module.app.result_instance_id }

# --- ALB / DNS ---
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "vote_url" { value = module.dns.vote_url }
output "result_url" { value = module.dns.result_url }

# --- ACM ---
output "certificate_arn" {
  value     = module.cert.certificate_arn
  sensitive = true
}