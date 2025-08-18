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