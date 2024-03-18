variable "vpc_cidr" {
  type    = string
  default = "10.130.0.0/16"
}

variable "main_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "main_vol_size" {
  type    = number
  default = 15
}

variable "main_instance_count" {
  type    = number
  default = 1
}

output "instance_public_ip" {
  value       = aws_instance.mock_server[0].public_ip
  description = "AWS EC2 instance public IP"
  sensitive   = false
}

variable "key_name" {
  type    = string
}


variable "public_key" {
  type    = string
  sensitive = true
}

variable "ami_owners" {
  type = list(string)
  default = []
  sensitive = true
}

variable "region" {
  type    = string
  default = "eu-west-3"
}