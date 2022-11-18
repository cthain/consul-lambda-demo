variable "name" {
  description = "The name of the deployment."
  type        = string
}

variable "region" {
  description = "The AWS region to deploy to."
  type        = string
}

variable "consul_datacenter" {
  description = "The Consul datacenter."
  type        = string
}

variable "consul_mesh_gateway_uri" {
  description = "The public address for the Consul mesh gateway."
  type        = string
}

variable "extension_data_prefix" {
  description = "The path prefix for the Consul Lambda extension data."
  type        = string
}
