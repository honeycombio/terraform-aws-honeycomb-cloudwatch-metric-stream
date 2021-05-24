module "cloudwatch_metric_stream_default" {
  source = "app.terraform.io/honeycomb/honeycomb-cloudwatch-metric-stream/aws"

  name                   = "cms_default"
  honeycomb_dataset_name = "cloudwatch-default"

  honeycomb_writekey = var.honeycomb_writekey

  # Users generally don't need to set this unless they're using Secure Tenancy,
  # but it's here to enable our tests to run.
  honeycomb_api_host = var.honeycomb_api_host
}
