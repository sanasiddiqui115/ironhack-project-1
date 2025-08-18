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
output "alb_public_dns" {
  description = "The Public DNS of the Applicaiton Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "ansible_inventory" {
  description = "Dynamic Ansible inventory"
  value       = <<EOT
[bastion]
${aws_instance.bastion_server.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/sana_project1.pem

[frontend]
${aws_instance.frontend_server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/sana_project1.pem

[backend]
${aws_instance.backend_server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/sana_project1.pem

[db]
${aws_instance.postgres_server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/sana_project1.pem
EOT
}