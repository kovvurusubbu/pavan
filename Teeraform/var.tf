variable "aws_region" {
  description = "AWS region where the EKS cluster will be created."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "eks-cluster"
}

variable "instance_type" {
  description = "Default EC2 instance type for the worker nodes."
  type        = string
  default     = "t2.medium"
}

variable "vpc_id" {
  description = "ID of the existing VPC where the EKS cluster will be deployed."
  type        = string
  default     = "vpc-0e754aaec5b795f73"
}

variable "private_subnet_ids" {
  description = "List of existing subnet IDs within the VPC for the EKS cluster."
  type        = list(string)
  default     = ["subnet-04466d32e8fc1a2bf", "subnet-0818f2b5352f314c3"]
}

variable "public_subnet_ids" {
  description = "List of existing subnet IDs within the VPC for the EKS cluster."
  type        = list(string)
  default     = ["subnet-0b3dd7dfa17e6d2ae", "subnet-033c10f35a1d79a6c"]
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.27"
}