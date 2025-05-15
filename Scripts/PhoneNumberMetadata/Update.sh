#!/bin/bash

set -euo pipefail

function fail {
  echo "$@" 1>&2
  exit 1
}

function cleanup {
  rm -rf $WORK_DIR
}

# Configure cleanup
trap cleanup EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OUTPUT_DIR="$SCRIPT_DIR/../../Sources/ProcessOut/Resources/PhoneNumberMetadata"
WORK_DIR=$(mktemp -d)

# Validates arguments acount
test $# -eq 1 || fail "Expected tag or branch reference."

# Go to temporary directory
cd $WORK_DIR

# Clone PhoneNumberKit (port of Google's libphonenumber)
git clone --depth 1 --branch $1 https://github.com/marmelroy/PhoneNumberKit PhoneNumberKit

# Go to resources
cd PhoneNumberKit/PhoneNumberKit/Resources/

mkdir -p $OUTPUT_DIR

# Postprocess metadata
"$SCRIPT_DIR/Postprocess.swift" "PhoneNumberMetadata.json" "$OUTPUT_DIR/PhoneNumberMetadata.json"

# # Write metadata
cp .metadata-version "$OUTPUT_DIR/PhoneNumberMetadata.version"
