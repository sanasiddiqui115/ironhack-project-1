output "vote_instance_id" { value = aws_instance.vote.id }
output "result_instance_id" { value = aws_instance.result.id }
output "vote_private_ip" { value = aws_instance.vote.private_ip }
output "result_private_ip" { value = aws_instance.result.private_ip }
output "bastion_public_ip" { value = aws_instance.bastion.public_ip }

output "frontend_private_ip" { value = aws_instance.frontend.private_ip }
output "backend_private_ip" { value = aws_instance.backend.private_ip }
output "postgres_private_ip" { value = aws_instance.postgres.private_ip }


output "vote_instance2_id" { value = aws_instance.vote_2.id }
output "result_instance2_id" { value = aws_instance.result_2.id }