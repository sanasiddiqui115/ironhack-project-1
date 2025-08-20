output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.sana_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = [
    aws_subnet.sana_public_subnet_a.id,
    aws_subnet.sana_public_subnet_b.id,
  ]
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.sana_public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = aws_subnet.sana_private_subnet.id
}

output "private_subnet_a_id" {
  description = "Private subnet A ID"
  value       = aws_subnet.sana_private_subnet_a.id
}

output "private_subnet_b_id" {
  description = "Private subnet B ID"
  value       = aws_subnet.sana_private_subnet_b.id
}
