provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAXZ6SSYC52EUMIV"
  secret_key = "69UX4supbh5/KEblM2Ny3yvNGKjTV7Qc"
}

# Generate a new key pair for SSH access to the MongoDB instance
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/mongodb-ssh-key.pem"
  content  = tls_private_key.ssh_key.private_key_pemyes

}

# Create the key pair in AWS
resource "aws_key_pair" "mongodb_ssh_key" {
  key_name   = "mongodb-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Define the MongoDB instance
resource "aws_instance" "mongodb_instance" {
  ami           = "ami-0eb02ea7bebc3d987" # Bitnami MongoDB AMI for ap-south-1
  instance_type = "t2.medium"

  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.mongodb_ssh_key.key_name

  tags = {
    Name = "MongoDB-Instance"
  }
}

# Security group for MongoDB (assuming this resource exists in your configuration)
resource "aws_security_group" "mongodb_sg" {
  name_prefix = "mongodb-sg-"
  description = "Security group for MongoDB"
  vpc_id      = var.vpc_id
  # Define inbound rules as needed (e.g., MongoDB port 27017)
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
