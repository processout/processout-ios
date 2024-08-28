#!/bin/bash

set -euo pipefail

function cleanup {
  rm -rf $WORK_DIR
}

# Configure cleanup
trap cleanup EXIT

# Create temp directory
WORK_DIR=$(mktemp -d)

# Import certificate from secrets
DEVELOPMENT_CERTIFICATE_PATH="$WORK_DIR/DevelopmentCertificate.p12"
echo -n $APPLE_DEVELOPMENT_CERTIFICATE_CONTENT | base64 -d -o $DEVELOPMENT_CERTIFICATE_PATH

# Keychain constants
KEYCHAIN_PATH="$WORK_DIR/signing.keychain-db"
KEYCHAIN_PASSWORD=$(openssl rand -base64 32)

# Create temporary keychain
security create-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_PATH

# Import certificate to keychain
security import $DEVELOPMENT_CERTIFICATE_PATH \
    -P $APPLE_DEVELOPMENT_CERTIFICATE_PASSWORD \
    -k $KEYCHAIN_PATH \
    -A \
    -t cert \
    -f pkcs12

# Enable codesigning from a non user interactive shell
security set-key-partition-list -S apple-tool:,apple: -k $KEYCHAIN_PASSWORD $KEYCHAIN_PATH

# Append keychain to the user domain
security list-keychain -d user -s $KEYCHAIN_PATH
