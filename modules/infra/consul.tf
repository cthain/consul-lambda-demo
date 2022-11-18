resource "hcp_hvn" "main" {
  cloud_provider = "aws"
  region         = var.region
  hvn_id         = var.name
  cidr_block     = var.hvn_cidr
}

resource "hcp_consul_cluster" "main" {
  cluster_id         = var.name
  datacenter         = var.consul_datacenter
  min_consul_version = var.consul_version
  tier               = var.consul_tier
  hvn_id             = hcp_hvn.main.hvn_id
  public_endpoint    = true
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

resource "hcp_aws_network_peering" "default" {
  peer_account_id = data.aws_caller_identity.current.account_id
  peering_id      = "${module.vpc.vpc_id}-peering"
  peer_vpc_region = var.region
  peer_vpc_id     = module.vpc.vpc_id
  hvn_id          = hcp_hvn.main.hvn_id
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.default.provider_peering_id
  auto_accept               = true
}

resource "hcp_hvn_route" "peering_route" {
  hvn_route_id     = "${module.vpc.vpc_id}-route"
  target_link      = hcp_aws_network_peering.default.self_link
  hvn_link         = hcp_hvn.main.self_link
  destination_cidr = module.vpc.vpc_cidr_block
  depends_on       = [aws_vpc_peering_connection_accepter.peer]
}

resource "aws_route" "public_to_hvn" {
  count = length(module.vpc.public_route_table_ids)

  route_table_id            = module.vpc.public_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}

resource "aws_route" "private_to_hvn" {
  count = length(module.vpc.private_route_table_ids)

  route_table_id            = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block    = hcp_hvn.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.vpc_peering_connection_id
}
