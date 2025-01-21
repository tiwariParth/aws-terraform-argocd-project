data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
    

# Create key pair using your existing Ed25519 public key
resource "aws_key_pair" "deployer" {
  key_name   = "parth-terraform-key"
  public_key = file("/Users/parthtiwari/.ssh/id_ed25519.pub")
}

# Create security group
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg_"
  description = "Security group for instance"

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]  # Will fetch your current IP
    description = "SSH access from my IP"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "terraform-instance-sg"
    User = "tiwariParth"
  }
}

# Data source to get current public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Create EC2 instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"  # You can change this if needed
  key_name              = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  
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
    Name        = "terraform-instance"
    User        = "tiwariParth"
    Created     = "2025-01-21"
  }
}

# Output the public IP
output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address of the instance"
}

# Output the instance ID
output "instance_id" {
  value       = aws_instance.app_server.id
  description = "The ID of the instance"
}