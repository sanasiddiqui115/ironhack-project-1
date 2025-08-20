variable "key_pair_name" {
  description = "The name of the AWS key pair to use for SSH access"
  type        = string
  default     = "sana_project1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1"
}

variable "subnet_availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "ami_id" {
  description = "Static AMI ID for EC2 instances"
  type        = string
  default     = "ami-0fd804ee843cc8bf9"
}

variable "secondary_subnet_availability_zone" {
  type    = string
  default = "us-east-1b"
}

variable "root_domain"         { type = string, default = "sanasiddiquiaws.info" }
variable "public_subnet_ids"   { type = list(string) }  # two public subnets (AZ A/B)
variable "private_subnet_a_id" { type = string }        # vote instance subnet
variable "private_subnet_b_id" { type = string }        # result instance subnet
variable "vpc_id"              { type = string }
# existing backend/private IPs
variable "redis_host"          { type = string, default = "10.0.2.247" }
variable "postgres_host"       { type = string, default = "10.0.2.190" }
variable "postgres_user"       { type = string, default = "postgres" }
variable "postgres_pass"       { type = string, default = "postgres" }
variable "postgres_db"         { type = string, default = "postgres" }