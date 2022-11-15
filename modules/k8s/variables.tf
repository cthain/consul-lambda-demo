variable "region" {
  type        = string
  description = "AWS region"
}

variable "eks_cluster_id" {
  type        = string
  description = "Cluster ID of EKS"
}

variable "datacenter" {
  type        = string
  description = "The name of the Consul datacenter that client agents should register as"
}

variable "k8s_api_endpoint" {
  type        = string
  description = "The Kubernetes API endpoint for the Kubernetes cluster"
}

variable "consul_version" {
  type        = string
  description = "The Consul version of the HCP servers"
}

variable "chart_version" {
  type        = string
  description = "The Consul Helm chart version to use"
  default     = "1.0.0-beta5"
}

variable "api_gateway_version" {
  type        = string
  description = "The Consul API gateway image version to use"
  default     = "0.4.0"
}

variable "security_group" {}
