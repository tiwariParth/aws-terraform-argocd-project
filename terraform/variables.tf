variable aws_region{
     description = "AWS region"
     type = string
     default = "ap-south-1"
}

variable "instance-type" {
  description = "EC2 instance type"
  type = string
  default = "t2.micro"
}

variable "ssh_cdir" {
  description = "Your IP address for SSH access (CIDR notation)"
  type = string
}