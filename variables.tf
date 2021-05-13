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
variable "tags" {
  type = map(string)
  default = {}
}

variable "namespace_include_filters" {
  type = list(string)
  default = []
}

variable "namespace_exclude_filters" {
  type = list(string)
  default = []
}

variable "s3_buffer_size" {
  type = number
  default = 10
}

variable "s3_buffer_interval" {
  type = number
  default = 400
}

variable "s3_compression_format" {
  type = string
  default = "GZIP"
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


# Optional variables you are unlikely to modify
variable "honeycomb_api_base_url" {
  type = string
  default = "https://api.honeycomb.io/1/kinesis_events"
}

variable "output_format" {
  type = string
  default = "opentelemetry0.7"
}
