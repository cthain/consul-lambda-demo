resource "aws_lambda_function" "lambda_payments" {
  function_name    = "lambda-payments"
  filename         = "lambda-payments.zip"
  source_code_hash = filebase64sha256("lambda-payments.zip")
  role             = aws_iam_role.lambda.arn
  handler          = "lambda-payments"
  runtime          = "go1.x"
  tags = {
    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled" = "true"
  }
}
