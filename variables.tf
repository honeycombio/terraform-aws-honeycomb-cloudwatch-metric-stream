# Required variables
variable "name" {
  type = string
  # required, no default

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 32
    error_message = "We use var.name as a name_prefix, so it must be 1-32 characters in length."
  }
}

variable "honeycomb_dataset_name" {
  type = string
}

variable "honeycomb_api_key" {
  type = string
}


# Optional variables for customer configuration
variable "honeycomb_api_host" {
  type = string
  default = "https://api.honeycomb.io"
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "namespace_include_filters" {
  type = list(string)
  default = []
  description = "An optional list of CloudWatch Metric namespaces to include. If set, we'll only stream metrics from these namespaces. Mutually exclusive with `namespace_exclude_filters`."
}

variable "namespace_exclude_filters" {
  type = list(string)
  default = []
  description = "An optional list of CloudWatch Metric namespaces to exclude. If set, we'll only stream metrics that are not in these namespaces. Mutually exclusive with `namespace_include_filters`."
}

variable "s3_buffer_size" {
  type = number
  default = 10
  description = "In MiB. See https://docs.aws.amazon.com/firehose/latest/dev/create-configure.html"

  validation {
    condition     = var.s3_buffer_size >= 1 && var.s3_buffer_size <= 128
    error_message = "The s3_buffer_size must be 1-128 MiBs."
  }
}

variable "s3_buffer_interval" {
  type = number
  default = 400
  description = "In seconds. See https://docs.aws.amazon.com/firehose/latest/dev/create-configure.html"

  validation {
    condition     = var.s3_buffer_interval >= 60 && var.s3_buffer_interval <= 900
    error_message = "The s3_buffer_interval must be 60-900 seconds."
  }
}

variable "s3_compression_format" {
  type = string
  default = "GZIP"
  description = "May be GZIP, Snappy, Zip, or Hadoop-Compatiable Snappy. See https://docs.aws.amazon.com/firehose/latest/dev/create-configure.html"

  validation {
    condition     = contains(["GZIP",
      "Snappy",
      "Zip",
      "Hadoop-Compatible Snappy"],
      var.s3_compression_format)
    error_message = "Not an allowed compression format."
  }
}

variable "s3_backup_mode" {
  type = string
  default = "FailedDataOnly"
}

# By default, AWS will decline to delete S3 buckets that are not empty:
# `BucketNotEmpty: The bucket you tried to delete is not empty`.  These buckets
# are used for backup if delivery or processing fail.
#
# To allow this module's resources to be removed, we've set force_destroy =
# true, allowing non-empty buckets to be deleted. If you want to block this and
# preserve those failed deliveries, you can set this value to false, though that
# will leave terraform unable to cleanly destroy the module.
variable "s3_force_destroy" {
  type = bool
  default = true
}


# Optional variables you are unlikely to want to modify; these are here to ease
# development and long-term maintainability. Only the default values are
# supported.
variable "output_format" {
  type = string
  default = "opentelemetry0.7"
}

variable "http_buffering_size" {
  type = number
  default = 15
}

variable "http_buffering_interval" {
  type = number
  default = 600
}

variable "http_content_encoding" {
  type = string
  default = "GZIP"
}
