variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "cert_arn" {
  type = string
}

variable "vote_instance_id" {
  type = string
}

variable "result_instance_id" {
  type = string
}

variable "root_domain" {
  type = string
}
    