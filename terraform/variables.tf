variable aws_region{
     description = "AWS region"
     type = string
     default = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "ssh_cidr" {
  description = "The CIDR block for SSH access"
  type        = string
}