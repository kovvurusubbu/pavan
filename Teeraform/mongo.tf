main.tf 

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAXKDZ6SSYO7D2NDNM"
  secret_key = "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"
}

# Generate a new key pair for SSH access to the MongoDB instance
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/mongodb-ssh-key.pem"
  content  = tls_private_key.ssh_key.private_key_pem
}

# Create the key pair in AWS
resource "aws_key_pair" "mongodb_ssh_key" {
  key_name   = "mongodb-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Define the MongoDB instance
resource "aws_instance" "mongodb_instance" {
  ami           = "ami-0eb02ea7bebc3d987"
  instance_type = "t2.medium"
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.mongodb_ssh_key.key_name

  tags = {
    Name = "MongoDB-Instance"
  }

  /*provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mongodb",
      "sudo systemctl start mongodb",
      "sudo systemctl enable mongodb",
      "sleep 10",
      "source ~/.bashrc",
      "mongo admin --eval 'db.createUser({user:\"subbu\", pwd:\"subbu1234\", roles:[{role:\"root\",db:\"admin\"}]});'",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${path.module}/mongodb-ssh-key.pem")
      host        = aws_instance.mongodb_instance.public_ip
    }
  }*/
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
---
var.tf

variable "vpc_id" {
  description = "The ID of the VPC where the MongoDB instance will be deployed."
}

variable "subnet_id" {
  description = "The ID of the subnet where the MongoDB instance will be launched."
}
---

terraform.tfvars

vpc_id    = "vpc-0704c93e22bf3fe26"
subnet_id = "subnet-0921cf7a8e5add9f6"

