output "bastion_public_ip" {
  description = "The public IP address of the bastion instance"
  value       = aws_instance.bastion.public_ip
}
output "frontend_public_ip" {
  description = "The public IP address of the Frontend instance"
  value       = aws_instance.frontend.private_ip
}
output "backend_private_ip" {
  description = "The private IP address of the Backend instance"
  value       = aws_instance.backend.private_ip
}
output "postgres_private_ip" {
  description = "The private IP address of the Postgres instance"
  value       = aws_instance.postgres.private_ip
}
