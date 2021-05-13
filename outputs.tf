output "s3_bucket" {
  value = aws_s3_bucket.metric_stream.bucket
}

output cloudwatch_metric_stream_arn {
  value = aws_cloudwatch_metric_stream.metric-stream.arn
}

output cloudwatch_metric_stream_name {
  value = aws_cloudwatch_metric_stream.metric-stream.name
}
