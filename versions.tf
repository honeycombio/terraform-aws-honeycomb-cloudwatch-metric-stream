terraform {
  # TODO: not sure we need >= 0.13! But it's what we've tested against.
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.42.0"
    }
  }
}
