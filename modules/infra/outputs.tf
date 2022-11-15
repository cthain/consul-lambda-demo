#output "hcp_cluster_id" {
#  value = hcp_consul_cluster.main.cluster_id
#}
#
#output "consul_hosts" {
#  value = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["retry_join"]
#}

output "k8s_api_endpoint" {
  value = module.eks.cluster_endpoint
}

output "consul_version" {
  value = var.consul_version
}
#
#output "boostrap_acl_token" {
#  value = hcp_consul_cluster_root_token.token.secret_id
#}
#
#output "consul_ca_file" {
#  value = base64decode(hcp_consul_cluster.main.consul_ca_file)
#}

output "datacenter" {
  value = var.consul_datacenter
}

#output "gossip_encryption_key" {
#  value = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["encrypt"]
#}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "region" {
  value = var.region
}

output "security_group" {
  value = aws_security_group.hashicups.id
}

output "vpc" {
  value = module.vpc
}
#
#output "consul_addr" {
#  value = hcp_consul_cluster.main.consul_public_endpoint_url
#}
#
#output "consul_token" {
#  value     = hcp_consul_cluster_root_token.token.secret_id
#  sensitive = true
#}
