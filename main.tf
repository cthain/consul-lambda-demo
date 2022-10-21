# Deploy infrastructure: AWS VPC, EKS, Consul
module "infra" {
  source = "./modules/infra"

  name                  = var.name
  region                = var.region
  vpc_cidr              = var.vpc_cidr
  private_subnets       = var.private_subnets
  public_subnets        = var.public_subnets
  iam_path              = var.iam_path
  hvn_cidr              = var.hvn_cidr
  consul_datacenter     = var.consul_datacenter
  consul_version        = var.consul_version
  consul_tier           = var.consul_tier
  consul_lambda_version = var.consul_lambda_version
  image_rgy_url         = var.image_rgy_url
  k8s_version           = var.k8s_version
}

# Deploy HashiCups on Kubernetes
module "k8s_hashicups" {
  source = "./modules/k8s"

  hcp_cluster_id        = module.infra.hcp_cluster_id
  consul_hosts          = module.infra.consul_hosts
  k8s_api_endpoint      = module.infra.k8s_api_endpoint
  consul_version        = module.infra.consul_version
  boostrap_acl_token    = module.infra.boostrap_acl_token
  consul_ca_file        = module.infra.consul_ca_file
  datacenter            = module.infra.datacenter
  gossip_encryption_key = module.infra.gossip_encryption_key
  eks_cluster_id        = module.infra.eks_cluster_id
  region                = var.region
  security_group        = module.infra.security_group
}


module "remove_kubernetes_backed_enis" {
  source = "github.com/webdog/terraform-kubernetes-delete-eni"
  vpc_id = module.infra.vpc.vpc_id
  region = var.region
}
