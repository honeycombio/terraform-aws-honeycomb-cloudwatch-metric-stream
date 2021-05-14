# Following roles taken from https://github.com/hashicorp/terraform-provider-aws/pull/18870/files?file-filters%5B%5D=.markdown
resource "aws_iam_role" "firehose_to_s3" {
  name_prefix        = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "firehose_to_s3" {
  name_prefix = var.name
  role        = aws_iam_role.firehose_to_s3.id
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.metric_stream.arn}",
                "${aws_s3_bucket.metric_stream.arn}/*"
            ]
        }
    ]
}
EOF
}

# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-trustpolicy.html
resource "aws_iam_role" "metric_stream_to_firehose" {
  name_prefix        = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "streams.metrics.cloudwatch.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-trustpolicy.html
resource "aws_iam_role_policy" "metric_stream_to_firehose" {
  name_prefix = var.name
  role        = aws_iam_role.metric_stream_to_firehose.id
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.metrics.arn}"
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "metric_stream" {
  bucket = replace(var.name, "_", "-")
  acl    = "private"

  tags = var.tags

  # 'true' allows terraform to delete this bucket even if it is not empty.
  force_destroy = var.s3_force_destroy
}

resource "aws_kinesis_firehose_delivery_stream" "metrics" {
  name        = var.name
  destination = "http_endpoint"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_to_s3.arn
    bucket_arn = aws_s3_bucket.metric_stream.arn

    buffer_size        = var.s3_buffer_size
    buffer_interval    = var.s3_buffer_interval
    compression_format = var.s3_compression_format
  }

  http_endpoint_configuration {
    url  = "${var.honeycomb_api_host}/1/kinesis_events/${var.honeycomb_dataset_name}"
    name = "Honeycomb-${var.honeycomb_dataset_name}"

    access_key         = var.honeycomb_api_key
    buffering_size     = var.http_buffering_size
    buffering_interval = var.http_buffering_interval
    role_arn           = aws_iam_role.firehose_to_s3.arn
    s3_backup_mode     = var.s3_backup_mode

    request_configuration {
      content_encoding = var.http_content_encoding
    }
  }
}

# The aws_cloudwatch_metric_stream resource is not yet available in the
# hashicorp/aws provider, though it has a PR open: https://github.com/hashicorp/terraform-provider-aws/pull/18870
#
# However, in the interest of unblocking #proj-metrics, we can create this
# resource from the aws cli:
# ```
# aws cloudwatch put-metric-stream \
#   --name dogfood-metric-stream \
#   --firehose-arn $firehose_arn \
#   --role-arn $role_arn \
#   --output-format opentelemetry0.7
# ```
# ($firehose_arn and $role_arn being resources created in terraform.)

resource "aws_cloudwatch_metric_stream" "metric-stream" {
  name          = var.name
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.metrics.arn
  output_format = var.output_format

  # NOTE: include and exclude filters are _mutually exclusive_, you may not have
  # both (though this is difficult to enforce in variable validation.
  dynamic "include_filter" {
    for_each = var.namespace_include_filters

    content {
      namespace = include_filter.value
    }
  }

  dynamic "exclude_filter" {
    for_each = var.namespace_exclude_filters

    content {
      namespace = exclude_filter.value
    }
  }

  tags = var.tags
}
