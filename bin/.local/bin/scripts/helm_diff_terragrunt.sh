#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <terraform-resource-address>"
  echo "Example: $0 module.argocd.helm_release.argocd[0]"
  exit 1
fi

ADDR="$1"
TMPDIR=$(mktemp -d)
PLANFILE="$TMPDIR/tgplan"

echo "Generating Terragrunt plan..."
terragrunt plan -out="$PLANFILE" >/dev/null

# Extract before values (if any)
echo "Extracting previous Helm values..."
terragrunt show -json "$PLANFILE" | jq -r \
  --arg addr "$ADDR" '
    .resource_changes[]
    | select(.address == $addr)
    | .change.before.values? // empty
    | if type == "array" and (.[0] | type == "string") then join("\n") else . end' \
  > "$TMPDIR/before.yaml"

# Extract after values (if any)
echo "Extracting updated Helm values..."
terragrunt show -json "$PLANFILE" | jq -r \
  --arg addr "$ADDR" '
    .resource_changes[]
    | select(.address == $addr)
    | .change.after.values? // empty
    | if type == "array" and (.[0] | type == "string") then join("\n") else . end' \
  > "$TMPDIR/after.yaml"

echo "Showing diff between values:"
diff -u --color=always "$TMPDIR/before.yaml" "$TMPDIR/after.yaml" || true

echo "Cleaning up temporary files..."
rm -rf "$TMPDIR"
