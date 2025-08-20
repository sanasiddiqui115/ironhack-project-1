variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_pair_name" {
  type = string
}
# Subnets (choose correct public/private ones from module.network outputs)
variable "public_subnet_id" { type = string }  # public
variable "private_subnet_id" { type = string } # private
variable "subnet_vote_id" { type = string }    # private (AZ A)
variable "subnet_result_id" { type = string }  # private (AZ B)

# Security Groups (provide from module.security outputs or existing SGs)
variable "bastion_sg_id" { type = string }
variable "frontend_sg_id" { type = string }
variable "backend_sg_id" { type = string }
variable "postgres_sg_id" { type = string }
variable "vote_sg_id" { type = string }
variable "result_sg_id" { type = string }
