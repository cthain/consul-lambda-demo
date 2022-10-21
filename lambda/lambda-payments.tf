locals {
  lambda_payments = "lambda-payments"
}

resource "aws_lambda_function" "lambda_payments" {
  function_name    = local.lambda_payments
  filename         = "${local.lambda_payments}.zip"
  source_code_hash = filebase64sha256("${local.lambda_payments}.zip")
  role             = aws_iam_role.lambda.arn
  handler          = local.lambda_payments
  runtime          = "go1.x"
  tags = {
    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled" = "true"
  }
}
