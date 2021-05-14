terraform {
  # TODO: not sure we need >= 0.13! But it's what we can test against.
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "> 0.0.0" # TODO: pending https://github.com/hashicorp/terraform-provider-aws/pull/18870
    }
  }
}
