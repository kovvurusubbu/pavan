main.tf 

/*provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA2SRVR5EKTHRKEAOA"
  secret_key = "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"
}

# Generate a new key pair for SSH access to the MongoDB instance
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/mongo-ssh-key.pem"
  content  = tls_private_key.ssh_key.private_key_pem
}

# Create the key pair in AWS
resource "aws_key_pair" "mongo_ssh_key" {
  key_name   = "mongo-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
# Create an Elastic IP
resource "aws_eip" "mongodb_eip" {
  instance = aws_instance.mongodb_instance.id
}

# Define the MongoDB instance
resource "aws_instance" "mongodb_instance" {
  ami           = "ami-0eb02ea7bebc3d987"
  instance_type = "t2.medium"
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.mongo_ssh_key.key_name
  //vpc_security_group_ids      = [aws_security_group.mongodb_sg.id]
  associate_public_ip_address = false

  //network_interface "cd" {
  //  network_security_group_ids = [aws_security_group.mongodb_sg.id]
  }

  # Add a block to specify the EBS volume configuration
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
  }
  /*provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mongodb",
      "sudo systemctl start mongodb",
      "sudo systemctl enable mongodb",
      "sleep 10m",
      "source ~/.bashrc",
      "mongo admin --eval 'db.createUser({user:\"mongosubbu\", pwd:\"subbu1234\", roles:[{role:\"root\",db:\"admin\"}]});'",
    ]

    connection {
      timeout     = "10m"
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.ssh_key.filename)
      host        = aws_instance.mongodb_instance.public_ip
    }
  } 

  tags = {
    Name = "MongoDB-Instance"
  }
}

# Security group for MongoDB (assuming this resource exists in your configuration)
resource "aws_security_group" "mongodb_sg" {
  name_prefix = "mongodb-sg"
  description = "Security group for MongoDB"
  vpc_id      = var.vpc_id
  # Define inbound rules as needed (e.g., MongoDB port 27017)
  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    //cidr_blocks = ["0.0.0.0/0"]
    cidr_blocks = [aws_eip.mongodb_eip.public_ip]
  }
} */
============================================================>
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA2SRVR5EKTHRKEAOA"
  secret_key = "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"
}

# Generate a new key pair for SSH access to the MongoDB instance
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/mongo-ssh.pem"
  content  = tls_private_key.ssh_key.private_key_pem
}

# Create the key pair in AWS
resource "aws_key_pair" "mongo_ssh" {
  key_name   = "mongo-ssh"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create an Elastic IP
resource "aws_eip" "mongodb_eip" {
  instance = aws_instance.mongodb_instance.id
}

# Define the MongoDB instance
resource "aws_instance" "mongodb_instance" {
  ami                         = "ami-0eb02ea7bebc3d987"
  instance_type               = "t2.medium"
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.mongo_ssh.key_name
# Allow automatic public IP assignment
  associate_public_ip_address = true

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "MongoDB-Instance"
  }
}

# Security group for MongoDB (assuming this resource exists in your configuration)
resource "aws_security_group" "mongodb_sg" {
  name_prefix = "mongodb-sg"
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
============================================================>

var.tf
------
variable "vpc_id" {
  description = "The ID of the VPC where the MongoDB instance will be deployed."
}
variable "subnet_id" {
  description = "The ID of the subnet where the MongoDB instance will be launched."
}
variable "security_group_ids" {
  description = "The ID of the security_group_ids where the MongoDB instance will be launched."
}
============================================================>

terraform.tfvars
----------------
vpc_id                 = "vpc-0ed659416a1dd28e6"
subnet_id              = "subnet-08cb317834492d425"
vpc_security_group_ids = "sg-026c9264928604e04"


<" You can  chnage  here  vpcid,subnet,id,securtyGroupid,access_key, secret_key,region ">

