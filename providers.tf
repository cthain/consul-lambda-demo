terraform {
  backend "s3" {
    bucket = "cftc-demo"
    key    = "hashicups/demo"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.18.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "hcp" {
}
