module "eks" {
  source                          = "registry.terraform.io/terraform-aws-modules/eks/aws"
  version                         = "18.26.6"
  cluster_name                    = var.name
  cluster_version                 = var.k8s_version
  subnet_ids                      = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  vpc_id                          = module.vpc.vpc_id
  enable_irsa                     = false
  eks_managed_node_group_defaults = {}
  create_cluster_security_group   = false
  cluster_security_group_id       = aws_security_group.hashicups.id
  eks_managed_node_groups = {
    default_group = {
      min_size               = 3
      max_size               = 3
      desired_size           = 3
      labels                 = {}
      vpc_security_group_ids = [aws_security_group.hashicups.id]

      instance_types = ["m5.large"]
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "optional"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "invoke_lambda" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = aws_iam_policy.invoke_lambda.arn
  role       = each.value.iam_role_name
}

resource "aws_iam_policy" "invoke_lambda" {
  name        = "${var.name}-invoke-lambda"
  path        = var.iam_path
  description = "Permits invocation of any lambda function"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
