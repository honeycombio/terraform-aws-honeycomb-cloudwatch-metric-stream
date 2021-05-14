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

# Optional - for Secure Tenancy and other proxies
variable "honeycomb_api_host" {
  type = string
  default = "https://api.honeycomb.io"
}

module "cloudwatch_metric_stream_default" {
  source = "../"

  name = "cms_default"
  honeycomb_dataset_name = "cloudwatch-default"

  honeycomb_api_key = var.honeycomb_api_key

  # Users generally don't need to set this unless they're using Secure Tenancy,
  # but it's here to enable our tests to run.
  honeycomb_api_host = var.honeycomb_api_host
}

module "cloudwatch_metric_stream_with_tags" {
  source = "../"

  name = "cms_with_tags"
  honeycomb_dataset_name = "cloudwatch-with-tags"

  honeycomb_api_key = var.honeycomb_api_key

  honeycomb_api_host = var.honeycomb_api_host

  tags = {
    Environment = "ismith-sandbox"
  }
}

module "cloudwatch_metric_stream_with_includes" {
  source = "../"

  name = "cms_with_includes"
  honeycomb_dataset_name = "cloudwatch-with-includes"

  honeycomb_api_key = var.honeycomb_api_key

  honeycomb_api_host = var.honeycomb_api_host

  tags = {
    Environment = "ismith-sandbox"
  }

  namespace_include_filters = ["AWS/RDS", "AWS/ELB"]
}

module "cloudwatch_metric_stream_with_excludes" {
  source = "../"

  name = "cms_with_excludes"
  honeycomb_dataset_name = "cloudwatch-with-excludes"

  honeycomb_api_key = var.honeycomb_api_key

  honeycomb_api_host = var.honeycomb_api_host

  tags = {
    Environment = "ismith-sandbox"
  }

  namespace_exclude_filters = ["AWS/RDS", "AWS/ELB"]
}
