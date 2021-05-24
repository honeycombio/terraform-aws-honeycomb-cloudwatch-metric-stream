module "cloudwatch_metric_stream_with_includes" {
  source = "app.terraform.io/honeycomb/honeycomb-cloudwatch-metric-stream/aws"

  name                   = "cms_with_includes"
  honeycomb_dataset_name = "cloudwatch-with-includes"

  honeycomb_writekey = var.honeycomb_writekey

  # Users generally don't need to set this unless they're using Secure Tenancy,
  # but it's here to enable our tests to run.
  honeycomb_api_host = var.honeycomb_api_host

  namespace_include_filters = ["AWS/RDS", "AWS/ELB"]
}
