variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1"
}

variable "subnet_availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "secondary_subnet_availability_zone" {
  type    = string
  default = "us-east-1b"
}