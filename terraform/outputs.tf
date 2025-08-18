output "frontend_public_ip" {
  description = "The public IP address of the Frontend instance"
  value       = aws_instance.frontend_server.public_ip
}
output "backend_private_ip" {
  description = "The private IP address of the Backend instance"
  value       = aws_instance.backend_server.private_ip
}
output "postgres_private_ip" {
  description = "The private IP address of the Postgres instance"
  value       = aws_instance.postgres_server.private_ip
}