output "name" {
  value = var.name
}

output "region" {
  value = var.region
}

output "consul_http_addr" {
  value = module.infra.consul_addr
}

output "consul_http_token" {
  value     = module.infra.consul_token
  sensitive = true
}

output "consul_datacenter" {
  value = var.consul_datacenter
}

output "cloudwatch_logs_path" {
  value = {
    registrator = "/aws/lambda/lambda-registrator"
    payments    = "/aws/lambda/lambda-payments"
    products    = "/aws/lambda/lambda-products"
    eks         = "/aws/eks/${var.name}/cluster"
  }
}

output "eks_update_kubeconfig_command" {
  value = "aws eks --region ${var.region} update-kubeconfig --name ${module.infra.eks_cluster_id}"
}
