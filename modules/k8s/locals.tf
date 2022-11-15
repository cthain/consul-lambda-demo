locals {
  consul_resources_path_service_defaults   = "./modules/k8s/hashicups/consul_resources/service-defaults/*"
  consul_resources_path_service-intentions = "./modules/k8s/hashicups/consul_resources/service-intentions/*"
  consul_resources_path_proxy-defaults     = "./modules/k8s/hashicups/consul_resources/proxy-defaults/*"
  consul_resources_path                    = "./modules/k8s/hashicups/consul_resources/*"
  kube_resources_path_service-accounts     = "./modules/k8s/hashicups/kube_resources/service-account/*"
  kube_resources_path_config-maps          = "./modules/k8s/hashicups/kube_resources/config-map/*"
  hashicups_resources                      = "./modules/k8s/hashicups/**"
  service_account_config_maps              = setunion(fileset(path.root, local.kube_resources_path_service-accounts), fileset(path.root, local.kube_resources_path_config-maps))
  service_intentions                       = fileset(path.root, local.consul_resources_path_service-intentions)
  service_defaults                         = fileset(path.root, local.consul_resources_path_service_defaults)
  consul_yamls                             = setunion(local.service_intentions, local.service_defaults)
}
