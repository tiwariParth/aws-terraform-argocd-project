data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg_"
  description = "Security group for instance"

  # SSH access
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.ssh_cidr]
    description      = "SSH access"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self            = false
  }

  # HTTP access
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "HTTP access"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self            = false
  }

  # HTTPS access
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "HTTPS access"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self            = false
  }

  # Outbound rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self            = false
  }

  tags = {
    Name = "terraform-instance-sg"
  }
}

resource "aws_instance" "app_server" {
  ami             = data.aws_ami.amazon_linux_2.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance_sg.name]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              yum install -y docker
              systemctl start httpd
              systemctl enable httpd
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "terraform-instance"
  }
}