## Requirements

- AWS Account
- HCP Account

- AWS CLI v2.8.5
- Consul v1.13.2
- curl v7.83
- Docker 20.10.21, API v1.41
- Go v1.19
- jq v1.6
- kubectl v1.23.8
- Terraform v1.3.3

## TLDR

### Deploy the demo

```shell
terraform init && terraform apply -auto-approve
```

### Run the demo
```
./runbook
```

### Reset the demo to its original state
```
./runbook reset
```

Note: The `./runbook reset` command is idempotent and can be run as many times as you want.

### Clean up all resources
```
cd lambda/
terraform destroy -auto-approve \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"
cd ..
terraform destroy -auto-approve ; terraform destroy -auto-approve
```

## Manual steps

```shell

# Deploy the demo infrastructure
terraform init && terraform apply -auto-approve

# configure the environment from the deployed infrastructure
. env.sh

# view services, intentions etc.. in Consul UI
# view HashiCups, order a coffee.


# Deploy the Lambda functions
cd lambda/

# Download the extension
curl -s -o consul-lambda-extension.zip https://releases.hashicorp.com/consul-lambda-extension/0.1.0-beta2/consul-lambda-extension_0.1.0-beta2_linux_amd64.zip

# Build and package the Lambda functions
for lambda in lambda-payments lambda-products;
do
  (cd ../src/${lambda}/ && \
  GOOS=linux GOARCH=amd64 go build . && \
  zip ../../lambda/${lambda}.zip ${lambda}); \
done

# Deploy
tf init
tfyolo apply \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"

# during the apply view the Lambda TF files for Lambda registrator and the Lambda funcs
vi lambda-payments.tf
vi lambda-products.tf

# look at Lambda registrator and Lambda funcs in AWS Lambda
# look at the Lambda services in Consul

# Register the lambda funcs to the TGW, create the intentions and route traffic to the Lambda func
vi gateway-registration.yaml; kubectl apply -f gateway-registration.yaml
vi service-intentions.yaml ; kubectl apply -f service-intentions.yaml
vi service-splitter.yaml ; kubectl apply -f service-splitter.yaml

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

# clean up Lambda workspace
tfyolo destroy \
  -var "name=${DEPLOY_NAME}" \
  -var "region=${AWS_REGION}" \
  -var "consul_datacenter=${CONSUL_DC}" \
  -var "consul_mesh_gateway_uri=${CONSUL_MESH_GATEWAY_URI}" \
  -var "extension_data_prefix=${CONSUL_DC}"

cd ..

# cleanup infra workspace. 2 destroys are needed to clear out any lingering ENIs.
tfyolo destroy ; tfyolo destroy

```
