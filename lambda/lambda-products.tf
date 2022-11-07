resource "aws_lambda_layer_version" "consul_lambda_extension" {
  layer_name       = "consul-lambda-extension"
  filename         = "consul-lambda-extension.zip"
  source_code_hash = filebase64sha256("consul-lambda-extension.zip")
  description      = "Consul service mesh extension for AWS Lambda"
}

resource "aws_lambda_function" "lambda_products" {
  function_name    = "lambda-products"
  filename         = "lambda-products.zip"
  source_code_hash = filebase64sha256("lambda-products.zip")
  role             = aws_iam_role.lambda.arn
  handler          = "lambda-products"
  runtime          = "go1.x"
  layers           = [aws_lambda_layer_version.consul_lambda_extension.arn]
  tags = {
    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled" : "true"
  }

  environment {
    variables = {
      CONSUL_DATACENTER            = var.consul_datacenter
      CONSUL_EXTENSION_DATA_PREFIX = "/${var.extension_data_prefix}"
      CONSUL_MESH_GATEWAY_URI      = var.consul_mesh_gateway_uri
      CONSUL_SERVICE_UPSTREAMS     = "product-api-db:5432:${var.consul_datacenter}"

      PGHOST     = "localhost"
      PGPORT     = "5432"
      PGDATABASE = "products"
      PGUSER     = "postgres"
      PGPASSWORD = "password"
    }
  }
}
