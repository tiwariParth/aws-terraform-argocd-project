data "aws_ami" "amazion_linux_2"{
     most_recent = true
     owners = ["amazon"]
     filter{
          name = "name"
          values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
     }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg_"
  description = "Security group for instance"

  ingress = [
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.ssh_cdir]
    },
    {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
          from_port = 443
          to_port = 443
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress = {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-instance-sg"
  }
}

resource "aws_instance" "app_server" {
  ami = data.aws.ami.amazion_linux_2.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance_sg.name]
  user_data = <<-EOF
     #!/bin/bash
     yum update -y
     yum install httpd -y
     systemctl start httpd
     systemctl enable httpd
     systecmctl start docker
     systemctl enable docker
     EOF

 tags = {
          Name = "terraform-instance"
 }
}