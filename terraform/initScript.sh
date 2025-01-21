#!/bin/bash

set -ex
exec > >(tee -a /tmp/output.log) 2>&1

# Update system
yum update -y

# Install basic tools
yum install -y docker git wget curl unzip

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user              

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/          

# Install k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create a welcome message
echo "Welcome ${var.user_name}! Instance created on ${var.creation_date}" > /home/ec2-user/welcome.txt
chown ec2-user:ec2-user /home/ec2-user/welcome.txt