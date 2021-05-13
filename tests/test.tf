# Put the below in ~/.terraformrc to override to a local build.
#
# This is necessary because terraform-aws-provider does not yet have an
# aws_cloudwatch_metric_stream resource; once
# https://github.com/hashicorp/terraform-provider-aws/pull/18870, this whole
# comment block can go away.
#
# provider_installation {
#   # dev_overrides requires terraform >= 0.14
#   dev_overrides {
#     # See
#     # https://github.com/hashicorp/terraform-provider-aws/blob/main/docs/DEVELOPMENT.md
#     # for details on building the provider; tl;dr: "make tools && make build" in
#     # that repo.
#     "hashicorp/aws" = "/home/USERNAME/go/bin"
#   }
#   direct {}
# }

provider "aws" {
  region = "us-east-1"
  profile = "sandbox"
  shared_credentials_file = pathexpand("~/aws/credentials")
}

# We've specified this value in test.auto.tfvars, which is gitignored from the
# repo because it is sensitive.
variable "honeycomb_api_key" {
  type = string
}

module "cloudwatch_metric_stream_default" {
  source = "../"

  name = "cms_default"
  honeycomb_dataset_name = "cloudwatch-default"

  honeycomb_api_key = var.honeycomb_api_key

  # To check tags, use
  # `aws cloudwatch list-tags-for-resource --resource-arn $arn`
  tags = {
    Environment = "ismith-sandbox"
  }
}

module "cloudwatch_metric_stream_with_includes" {
  source = "../"

  name = "cms_with_includes"
  honeycomb_dataset_name = "cloudwatch-with-includes"

  honeycomb_api_key = var.honeycomb_api_key

  tags = {
    Environment = "ismith-sandbox"
  }

  # To check this, use
  # `aws cloudwatch get-metric-stream --name $name`
  namespace_include_filters = ["AWS/RDS", "AWS/ELB"]
}

module "cloudwatch_metric_stream_with_excludes" {
  source = "../"

  name = "cms_with_excludes"
  honeycomb_dataset_name = "cloudwatch-with-excludes"

  honeycomb_api_key = var.honeycomb_api_key

  tags = {
    Environment = "ismith-sandbox"
  }

  # To check this, use
  # `aws cloudwatch get-metric-stream --name $name`
  namespace_exclude_filters = ["AWS/RDS", "AWS/ELB"]
}
