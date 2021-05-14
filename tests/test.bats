# This script checks that what's deployed in AWS is "correct" according to our
# expectations. It does not, itself, run `terraform apply` or `terraform
# destroy`.

### BEFORE:
# Configure terraform (to be doc'd in more detail?) and run `terraform apply`.
###

### Run:
# bats test.bats # Bats can be installed using homebrew (OS X) or apt (Ubuntu)
###

### AFTER:
# Clean up by running `terraform destroy`.
###

@test "default module creation works" {
  run aws cloudwatch get-metric-stream --name cms_default

  [ "$status" -eq 0 ]
}

@test "module sets tags on 'aws_cloudwatch_metric_stream'" {
  run aws cloudwatch get-metric-stream --name cms_with_tags --output text --query "Arn"
  arn=$output

  run aws cloudwatch list-tags-for-resource --resource-arn $arn

  local expected=$(cat <<EOF
{
    "Tags": [
        {
            "Key": "Environment",
            "Value": "ismith-sandbox"
        }
    ]
}
EOF
)

  [ "$status" -eq 0 ]
  if ! [ "$output" == "$expected" ]; then
    echo "Tags for cms_default:"
    echo "Expected:"
    echo "$expected"
    echo "Actual:"
    echo "$output"
    return 1
  fi
}

expected_filters=$(cat <<EOF
[
    {
        "Namespace": "AWS/RDS"
    },
    {
        "Namespace": "AWS/ELB"
    }
]
EOF
)

@test "module sets include_filters 'aws_cloudwatch_metric_stream'" {
  run aws cloudwatch get-metric-stream --name cms_with_includes --query "IncludeFilters"
  local expected=$expected_filters

  [ "$status" -eq 0 ]
  if ! [ "$output" == "$expected" ]; then
    echo "Tags for cms_default:"
    echo "Expected:"
    echo "$expected"
    echo "Actual:"
    echo "$output"
    return 1
  fi
}

@test "module sets exclude_filters 'aws_cloudwatch_metric_stream'" {
  run aws cloudwatch get-metric-stream --name cms_with_excludes --query "ExcludeFilters"
  local expected=$expected_filters

  [ "$status" -eq 0 ]
  if ! [ "$output" == "$expected" ]; then
    echo "Tags for cms_default:"
    echo "Expected:"
    echo "$expected"
    echo "Actual:"
    echo "$output"
    return 1
  fi
}
