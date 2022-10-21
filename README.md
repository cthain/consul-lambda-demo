## Requirements

## TLDR

```shell
terraform init && terraform apply

# configure kubectl
$(terraform output -json | jq -r .eks_update_kubeconfig_command.value)

# configure the env from the deployment
export AWS_REGION=$(terraform output -json | jq -r .region.value)
export DEPLOY_NAME=$(terraform output -json | jq -r .name.value)
export CONSUL_HTTP_ADDR=$(terraform output -json | jq -r .consul_http_addr.value)
export CONSUL_HTTP_TOKEN=$(terraform output -json | jq -r .consul_http_token.value)
export CONSUL_DC=$(terraform output -json | jq -r .consul_datacenter.value)
export HASHICUPS_ADDR=$(kubectl get svc | grep 'api-gateway.*LoadBalancer' | awk '{ print $4}')
export POLICY_NAME="payments-lambda-tgw"
export CONSUL_MESH_GATEWAY_URI=$(kubectl get svc | grep consul-mesh-gateway | awk '{ print $4":443"}')

# view services, intentions etc.. in Consul UI
# view HashiCups, order a coffee.

# Configure ACLs on the TGW
cd lambda/

TGW_TOKEN=$(consul acl token list -format=json | jq '.[] | select(.Roles[]?.Name | contains("terminating-gateway"))' | jq -r '.AccessorID')
consul acl policy create -name "${POLICY_NAME}" -description "Allows Terminating Gateway to pass traffic from the payments Lambda function" -rules @tgw-policy.hcl
consul acl token update -id $TGW_TOKEN -policy-name $POLICY_NAME -merge-policies -merge-roles

# Apply the Lambda TF
export CONSUL_LAMBDA_VERSION="0.1.0-beta2"
curl -s -o consul-lambda-extension.zip https://releases.hashicorp.com/consul-lambda-extension/${CONSUL_LAMBDA_VERSION}/consul-lambda-extension_${CONSUL_LAMBDA_VERSION}_linux_amd64.zip

for lambda in lambda-payments lambda-products;
do
  (cd ../src/${lambda}/ && \
  GOOS=linux GOARCH=amd64 go build . && \
  zip ../../lambda/${lambda}.zip ${lambda}); \
done

terraform init
tfyolo apply \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"

# during the apply view the Lambda TF files for Lambda registrator and the Lambda funcs

# look at Lambda registrator and Lambda funcs in AWS Lambda

# Register the lambda funcs to the TGW, create the intentions and route traffic to the Lambda func

kubectl apply -f gateway-registration.yaml
kubectl apply -f service-intentions.yaml
kubectl apply -f service-splitter.yaml

# Create a new coffee
aws lambda invoke --region $AWS_REGION --function-name lambda-products --payload \
"$(echo '{
  "method": "PUT",
  "coffee": {
    "name": "Noveletto",
    "teaser": "The newest HashiCups product",
    "collection": "Discoveries",
    "origin": "Fall 2022",
    "color": "#444",
    "description": "",
    "price": 200,
    "image": "/hashicorp.png",
    "ingredients": [
      {
        "id": 1,
        "quantity": 40,
        "unit": "ml"
      },
      {
        "id": 5,
        "quantity": 100,
        "unit": "ml"
      }
    ]
  }
}
' | base64)" /dev/stdout | jq .

# order the new coffee and show that encryption is now enabled via the Lambda func

# clean up
tfyolo destroy \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"

cd ..

tfyolo destroy ; tfyolo destroy

```

## Deploy HCP Consul and HashiCups on EKS

```shell
terraform init && terraform apply
```

```shell
. . .

Plan: 135 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cloudwatch_logs_path          = {
      + eks         = "/aws/eks/hashicups/cluster"
      + payments    = "/aws/lambda/lambda-payments"
      + products    = "/aws/lambda/lambda-products"
      + registrator = "/aws/lambda/lambda-registrator"
    }
  + consul_http_addr              = (known after apply)
  + consul_http_token             = (sensitive value)
  + eks_update_kubeconfig_command = (known after apply)
  + lambda_inputs                 = {
      + consul_datacenter     = "dc1"
      + extension_data_prefix = "/dc1"
      + name                  = "hashicups"
    }
  + region                        = "us-west-2"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

## Configure stuff

Configure `kubectl`

```shell
$(terraform output -json | jq -r .eks_update_kubeconfig_command.value)
```

```shell
export AWS_REGION=$(terraform output -json | jq -r .region.value)
export DEPLOY_NAME=$(terraform output -json | jq -r .name.value)
export CONSUL_HTTP_ADDR=$(terraform output -json | jq -r .consul_http_addr.value)
export CONSUL_HTTP_TOKEN=$(terraform output -json | jq -r .consul_http_token.value)
export CONSUL_DC=$(terraform output -json | jq -r .consul_datacenter.value)
export HASHICUPS_ADDR=$(kubectl get svc | grep 'api-gateway.*LoadBalancer' | awk '{ print $4}')
export POLICY_NAME="payments-lambda-tgw"
```

Get the URI for the `consul-mesh-gateway`.

```shell
export CONSUL_MESH_GATEWAY_URI=$(kubectl get svc | grep consul-mesh-gateway | awk '{ print $4":443"}') ; echo $CONSUL_MESH_GATEWAY_URI
```

Configure the policy on the ACL token for the terminating gateway.

```shell
TGW_TOKEN=$(consul acl token list -format=json | jq '.[] | select(.Roles[]?.Name | contains("terminating-gateway"))' | jq -r '.AccessorID') && echo $TGW_TOKEN
consul acl policy create -name "${POLICY_NAME}" -description "Allows Terminating Gateway to pass traffic from the payments Lambda function" -rules @tgw-policy.hcl
consul acl token update -id $TGW_TOKEN -policy-name $POLICY_NAME -merge-policies -merge-roles
```

## Verify Consul and HashiCups

- Browse the Consul UI:
  ```shell
  echo $CONSUL_HTTP_ADDR
  echo $CONSUL_HTTP_TOKEN
  ```
- Browse HashiCups
  ```shell
  echo $HASHICUPS_ADDR
  ```
- Order a coffee
  ```shell
  kubectl port-forward deploy/public-api 8080
  ```

View Lambda Registrator module.

## Deploy AWS Lambda functions

Change directory into the `lambda` Terraform workspace.

```shell
cd lambda/
```

Set an environment variable that holds the version of the Consul Lambda integration.

```shell
export CONSUL_LAMBDA_VERSION="0.1.0-beta2"
```

### Download the Consul Lambda extension

```shell
curl -s -o consul-lambda-extension.zip https://releases.hashicorp.com/consul-lambda-extension/${CONSUL_LAMBDA_VERSION}/consul-lambda-extension_${CONSUL_LAMBDA_VERSION}_linux_amd64.zip
```

### Build and deploy the HashiCups Lambda functions

Build and package the `lambda-payments` and `lambda-products` functions that are used in the example.

```shell
for lambda in lambda-payments lambda-products;
do
  (cd ../src/${lambda}/ && \
  GOOS=linux GOARCH=amd64 go build . && \
  zip ../../lambda/${lambda}.zip ${lambda}); \
done
```

```shell
terraform init
```

```shell
terraform apply \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"
```

## Verify AWS Lambda deployments

- View the functions in the AWS Lambda console

## Register `lambda-payments` with the Terminating Gateway

```shell
kubectl apply -f gateway-registration.yaml
```

### Create service intentions

Create the service intentions for the Lambda functions

```shell
kubectl apply -f service-intentions.yaml
```

### Route payment traffic to the Lambda

Create a service splitter to route all traffic to the new `lambda-payments` function.

```shell
kubectl apply -f service-splitter.yaml
```

### Verify

```shell
kubectl port-forward deploy/public-api 8080
```

```shell
curl -v 'http://localhost:8080/api'   -H 'Accept-Encoding: gzip, deflate, br'   -H 'Content-Type: application/json'   -H 'Accept: application/json'   -H 'Connection: keep-alive'   -H 'DNT: 1'   -H 'Origin: http://localhost:8080'   --data-binary '{"query":"mutation{ pay(details:{ name: \"HELLO_LAMBDA_FUNCTION!\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\",    cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq
```

```shell
#testing only
aws lambda invoke --region $AWS_REGION --function-name lambda-payments --payload \
"$(echo '{
  "method": "POST",
  "body": "{ \"name\": \"HELLO_LAMBDA_FUNCTION!\", \"type\": \"mastercard\", \"number\": \"1234123-0123123\", \"expiry\":\"10/02\",    \"cvc\": \"123\"}"
}' | base64)" /dev/stdout
```

Buy a coffee

### Add a coffee

```shell
aws lambda invoke --region $AWS_REGION --function-name lambda-products --payload \
"$(echo '{
  "method": "PUT",
  "coffee": {
    "name": "Noveletto",
    "teaser": "The newest HashiCups product",
    "collection": "Discoveries",
    "origin": "Fall 2022",
    "color": "#444",
    "description": "",
    "price": 200,
    "image": "/hashicorp.png",
    "ingredients": [
      {
        "id": 1,
        "quantity": 40,
        "unit": "ml"
      },
      {
        "id": 5,
        "quantity": 100,
        "unit": "ml"
      }
    ]
  }
}
' | base64)" /dev/stdout | jq .
```
