module "api_gateway_crd" {
  source = "../../modules/api-gw-crd"
}

resource "helm_release" "consul-server" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  chart      = "consul"
  namespace = "consul-server"
  create_namespace = true

  values = [
    templatefile("${path.root}/modules/k8s/consul-server-values.yaml.tftpl", {
      datacenter          = var.datacenter
      consul_version      = substr(var.consul_version, 1, -1)
    })
  ]

  depends_on = [module.api_gateway_crd]
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  chart      = "consul"
  namespace = "consul"
  create_namespace = true

  values = [
    templatefile("${path.root}/modules/k8s/values.yaml.tftpl", {
      datacenter          = var.datacenter
      consul_hosts        = jsonencode(["consul-server.consul-server.svc.cluster.local"])
      consul_version      = substr(var.consul_version, 1, -1)
    })
  ]

  depends_on = [module.api_gateway_crd, helm_release.consul-server]
}
resource "kubectl_manifest" "kube_resources_service_accounts_and_config_maps" {
  for_each   = local.service_account_config_maps
  yaml_body  = file(each.value)
  depends_on = [helm_release.consul]
}

resource "kubectl_manifest" "hashicups_resources" {
  for_each   = fileset(path.root, local.hashicups_resources)
  yaml_body  = file(each.value)
  depends_on = [kubectl_manifest.kube_resources_service_accounts_and_config_maps]
}
resource "kubectl_manifest" "consul_service_resources" {
  for_each   = local.consul_yamls
  yaml_body  = file(each.value)
  depends_on = [kubectl_manifest.hashicups_resources]
}
