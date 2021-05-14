Terraform AWS-Honeycomb CloudWatch Metrics Stream module
========================================================

This module creates resources to send your CloudWatch Metrics to
[Honeycomb](https://www.honeycomb.io).

## Use

Required arguments
- `name`
- `honeycomb_dataset_name`
- `honeycomb_api_key`

Everything else is optional; consult docs (TODO: generated docs linked where?)
for more details.


## Examples

Examples of use of this module can be found in [`examples/`](examples/).  We've
provided a default example ("send all metrics") and examples using the
`namespace_include_filters` and `namespace_exclude_filters (which are mutually
exclusive). We've also provided an example of tagging your resources.


## Development

### Forked hashicorp/aws provider
Since the `aws_cloudwatch_metric_stream` resource is [not yet
released](https://github.com/hashicorp/terraform-provider-aws/pull/18870),
you'll need to build a local copy:

```bash
# I assume you have the gh command from github installed; if not, just chek out
the branch in question by hand
gh repo clone hashicorp/terraform-provider-aws
cd terraform-provider-aws
gh pr checkout 18870

make tools
make build # installs to $GOPATH/bin/terraform-provider-aws
```

And configure terraform to use it by putting this in `~/.terraformrc` (change
`/home/USERNAME/go` to match your `$GOPATH`):
```hcl
provider_installation {
  dev_overrides {
    "hashicorp/aws" = "/home/USERNAME/go/bin"
  } 
} 
```

Now you can `terraform plan`, `terraform apply`, etc as usual. If you run
`terraform init`, it will complain that this is unnecessary given the
`dev_overrides`, but you need it to install the modules.

### Tests
Test cases are in [`tests/`](tests/). To setup:

1. Edit the `provider "aws"` block to fit your credentials.

2. Create a `test.auto.tfvars` file in `tests/` with values for
   `honeycomb_api_key` and, optionally, `honeycomb_api_host`.

3. `terraform plan` and `terraform apply` will now work as expected, as will
   `terraform destroy`.

4. There's a small [Bats](https://github.com/sstephenson/bats) that validates
   a few test cases, one for each of the [`examples/`](examples/).  To run it, `bats test.bats`.  If you specified a
non-default profile in (1), make sure you set it in an env var so `test.bats`
talks to the right AWS account! (Feel free to add more test cases.)
