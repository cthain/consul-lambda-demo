variable "name" {
  description = "The name of this deployment."
  type        = string
  default     = "hashicups"
}

# AWS

variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"

}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "iam_path" {
  description = "The path under which IAM objecst are stored."
  type        = string
  default     = "/"
}

# Consul

variable "hvn_cidr" {
  description = "HCP HVN CIDR block"
  type        = string
  default     = "172.25.16.0/20"
}

variable "consul_datacenter" {
  description = "The name of the Consul datacenter."
  type        = string
  default     = "dc1"
}

variable "consul_version" {
  type        = string
  description = "The HCP Consul version"
  default     = "v1.13.2"
}

variable "consul_tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "development"
}

variable "consul_lambda_version" {
  type        = string
  description = "The version of the Consul Lambda integration to use."
  default     = "0.1.0-beta2"
}

variable "image_rgy_url" {
  type        = string
  description = "The URL of the public repository to pull images from."
  default     = "public.ecr.aws"
}

variable "k8s_version" {
  type        = string
  description = "Version of Kubernetes to deploy to EKS."
  default     = "1.22"
}
