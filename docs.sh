#!/bin/bash
set -euo pipefail

# This script generates the docs that .github/workflows/terraform-docs.yml
# would, but cannot push due to repo ACLs. So instead that workflow just checks
# that USAGE.md is what it expects, and fails the build if it is not.

if ! (command -v terraform-docs >/dev/null); then
  echo "You need terraform-docs:"
  echo "  go get github.com/terraform-docs/terraform-docs@v0.13.0"
  exit 1
fi

terraform-docs markdown . --output-file USAGE.md
