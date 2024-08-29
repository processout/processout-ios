#!/bin/bash

set -euo pipefail

# Create temp directory
WORK_DIR=$(mktemp -d)

# Import certificate from secrets
DEVELOPMENT_CERTIFICATE_PATH="$WORK_DIR/DevelopmentCertificate.p12"
echo -n $APPLE_DEVELOPMENT_CERTIFICATE_CONTENT | base64 -d -o $DEVELOPMENT_CERTIFICATE_PATH

# Keychain constants
KEYCHAIN_PATH="$WORK_DIR/processout-signing.keychain-db"
KEYCHAIN_PASSWORD=$(openssl rand -base64 32)

# Create temporary keychain
security create-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_PATH
security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN_PATH

# Import certificate to keychain
security import $DEVELOPMENT_CERTIFICATE_PATH \
    -P $APPLE_DEVELOPMENT_CERTIFICATE_PASSWORD \
    -k $KEYCHAIN_PATH \
    -f pkcs12 \
    -A

# Append temp keychain to the user domain
EXISTING_USER_KEYCHAIN_PATHS=$(security list-keychain -d user | awk -F'"' '{print $2}' ORS=' ')
security list-keychains -d user -s $KEYCHAIN_PATH $EXISTING_USER_KEYCHAIN_PATHS
