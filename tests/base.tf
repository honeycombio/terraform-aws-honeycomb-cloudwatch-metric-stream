provider "aws" {
  region                  = "us-east-1"
  profile                 = "sandbox"
  shared_credentials_file = pathexpand("~/aws/credentials")
}

variable "honeycomb_api_key" {
  type = string
}

variable "honeycomb_api_host" {
  type    = string
  default = "https://api.honeycomb.io"
}
