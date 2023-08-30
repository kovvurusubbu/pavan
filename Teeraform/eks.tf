resource "aws_eks_cluster" "my_eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.public_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
  ]

  tags = {
    Environment = "Test"
  }
}


resource "aws_eks_node_group" "worker_nodes_milestone3" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "eks-workers"
  node_role_arn   = aws_iam_role.eks_workers.arn

  subnet_ids = var.private_subnet_ids

  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }

  tags = {
    Environment = "Test"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_workers,
    aws_iam_role_policy_attachment.eks_cni,
  ]
}

resource "aws_security_group" "worker_nodes" {
  name_prefix = "my-eks-nodegroup-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    self        = true
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Worker Nodes Security Group"
    Environment = "Test"
  }
}

