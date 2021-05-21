# This script checks that what's deployed in AWS is "correct" according to our
# expectations. It does not, itself, run `terraform apply` or `terraform
# destroy`.

### BEFORE:
# Configure terraform and run `terraform apply`.
###

### Run:
# bats test.bats # Bats can be installed using homebrew (OS X) or apt (Ubuntu)
#
# Exit status 254 on all your tests most likely means it can't find the
# resources - probably you haven't run `terraform apply` or you're using the
# wrong credentials/profile.
###

### AFTER:
# Clean up by running `terraform destroy`.
###

# If we've set an aws profile in base.tf, run our tests with that profile.
#
# (`sed` normalizes whitespace; the lookbehind in our grep can't use
# /profile *= # / because lookbehinds must be a known width)
aws_profile_from_base_tf=$(cat $BATS_TEST_DIRNAME/base.tf | sed 's/  */ /g' | grep -P -o '(?<=profile = ").*(?=")' | head -n 1)
if [[ "$aws_profile_from_base_tf" ]]; then
  AWS_PROFILE="$aws_profile_from_base_tf"
fi

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
