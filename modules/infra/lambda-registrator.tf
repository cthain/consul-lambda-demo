locals {
  lr_image         = "consul-lambda-registrator:${var.consul_lambda_version}"
  public_lr_image  = "${var.image_rgy_url}/hashicorp/${local.lr_image}"
  private_lr_image = "${aws_ecr_repository.lambda_registrator.repository_url}:${var.consul_lambda_version}"
}

module "lambda_registrator" {
  source             = "hashicorp/consul-lambda/aws//modules/lambda-registrator"
  version            = "0.1.0-beta2"
  name               = "lambda-registrator"
  ecr_image_uri      = local.private_lr_image
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.vpc.default_security_group_id]

  consul_http_addr             = hcp_consul_cluster.main.consul_public_endpoint_url
  consul_http_token_path       = aws_ssm_parameter.token.name
  consul_extension_data_prefix = "/${var.consul_datacenter}"

  depends_on = [
    null_resource.publish_lambda_registrator
  ]
}

resource "aws_ecr_repository" "lambda_registrator" {
  name = "consul-lambda-registrator"
}

resource "null_resource" "publish_lambda_registrator" {
  triggers = {
    consul_lambda_version = var.consul_lambda_version
  }

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda_registrator.repository_url}
    docker pull ${local.public_lr_image}
    docker tag ${local.public_lr_image} ${aws_ecr_repository.lambda_registrator.repository_url}:${var.consul_lambda_version}
    docker push ${aws_ecr_repository.lambda_registrator.repository_url}:${var.consul_lambda_version}
    EOF
  }

  depends_on = [
    aws_ecr_repository.lambda_registrator
  ]
}

resource "aws_ssm_parameter" "token" {
  name  = "/${var.consul_datacenter}/token"
  type  = "SecureString"
  value = hcp_consul_cluster_root_token.token.secret_id
}

