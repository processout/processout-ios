#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OUTPUT_DIR="$SCRIPT_DIR/../Sources/ProcessOut/Resources/PhoneNumberMetadata"
WORK_DIR=$(mktemp -d)

# Validates arguments acount
test $# -eq 1

# Go to temporary directory
cd $WORK_DIR

# Clone Google's libphonenumber
git clone --depth 1 --branch $1 https://github.com/google/libphonenumber libphonenumber

mkdir -p $OUTPUT_DIR

# Convert XML metadata to JSON
"$SCRIPT_DIR/ConvertPhoneNumberMetadata.swift" "libphonenumber/resources/PhoneNumberMetadata.xml" "$OUTPUT_DIR/PhoneNumberMetadata.json"

# Write metadata
echo $1 > "$OUTPUT_DIR/PhoneNumberMetadata.version"

function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT
