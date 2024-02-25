variable "vpc_cidr" {
  type    = string
  default = "10.125.0.0/16"
}

variable "main_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "main_vol_size" {
  type    = number
  default = 30
}

variable "main_instance_count" {
  type    = number
  default = 1
}

output "instance_public_ip" {
  value       = aws_instance.odoo_16_server[0].public_ip
  description = "AWS EC2 instance public IP"
  sensitive   = false
}

variable "key_name" {
  type    = string
}

variable "public_key_path" {
  type    = string
}

variable "ami_owners" {
  type = list(string)
  default = []
  sensitive = true
}

variable "region" {
  type    = string

}