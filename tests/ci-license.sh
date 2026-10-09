#!/bin/bash
# GitHub Actions: write the Stata license from the STATA_LIC_BASE64 secret
# to $RUNNER_TEMP/stata.lic, and tell later steps whether it is available.
if [[ -z "$STATA_LIC_BASE64" ]]; then
  echo "No STATA_LIC_BASE64 secret: skipping the Stata tests"
  echo "available=false" >> "$GITHUB_OUTPUT"
else
  echo "$STATA_LIC_BASE64" | base64 -d > "$RUNNER_TEMP/stata.lic"
  chmod 600 "$RUNNER_TEMP/stata.lic"
  echo "available=true" >> "$GITHUB_OUTPUT"
fi
