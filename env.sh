#!/bin/bash

TFO=$(terraform output -json)

$(echo "$TFO" | jq -r .eks_update_kubeconfig_command.value)

# configure the env from the deployment
export AWS_REGION=$(echo "$TFO" | jq -r .region.value)
export DEPLOY_NAME=$(echo "$TFO" | jq -r .name.value)
export CONSUL_HTTP_ADDR=$(echo "$TFO" | jq -r .consul_http_addr.value)
export CONSUL_HTTP_TOKEN=$(echo "$TFO" | jq -r .consul_http_token.value)
export CONSUL_DC=$(echo "$TFO" | jq -r .consul_datacenter.value)
export HASHICUPS_ADDR=$(kubectl get svc | grep 'api-gateway.*LoadBalancer' | awk '{ print $4}')
export POLICY_NAME="payments-lambda-tgw"
export CONSUL_MESH_GATEWAY_URI=$(kubectl get svc | grep consul-mesh-gateway | awk '{ print $4":443"}')
export TGW_TOKEN=$(consul acl token list -format=json | jq '.[] | select(.Roles[]?.Name | contains("terminating-gateway"))' | jq -r '.AccessorID')

if ! consul acl policy list | grep -q 'payments-lambda'; then
  # allow the terminating gateway to write policies and read intentions on the payments components
  # only do this once.
  consul acl policy create -name "${POLICY_NAME}" -description "Allows Terminating Gateway to pass traffic from the payments Lambda function" -rules @lambda/tgw-policy.hcl &> /dev/null
  consul acl token update -id $TGW_TOKEN -policy-name $POLICY_NAME -merge-policies -merge-roles  &> /dev/null
fi

echo ""
echo "Consul UI:          $CONSUL_HTTP_ADDR"
echo "Consul login token: $CONSUL_HTTP_TOKEN"
echo "HashiCups UI:       $HASHICUPS_ADDR"
