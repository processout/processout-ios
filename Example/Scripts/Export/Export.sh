#!/bin/bash

set -euo pipefail

function cleanup {
  rm -rf $WORK_DIR
}

# Configure cleanup
trap cleanup EXIT

# Clean
xcodebuild clean

# Create working directory
WORK_DIR=$(mktemp -d)

# todo(andrii-vysotskyi): inject default credentials

# Write AppStore Connect API key
APP_STORE_CONNECT_API_KEY_PATH="$WORK_DIR/AuthKey.p8"
echo -n $APP_STORE_CONNECT_API_KEY_CONTENT | base64 -d > $APP_STORE_CONNECT_API_KEY_PATH

# Create archive
xcodebuild archive \
  -scheme Example \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -archivePath $WORK_DIR/Example.xcarchive \
  -authenticationKeyIssuerID $APP_STORE_CONNECT_API_KEY_ISSUER_ID \
  -authenticationKeyID $APP_STORE_CONNECT_API_KEY_ID \
  -authenticationKeyPath $APP_STORE_CONNECT_API_KEY_PATH \
  -allowProvisioningUpdates \
  "DEVELOPMENT_TEAM=3Y9WMX63ZJ"

# Copy export options plist
cp ./Scripts/Export/ExportOptions.plist $WORK_DIR

# Navigate to working directory
cd $WORK_DIR

# Export archive
xcodebuild \
  -exportArchive \
  -archivePath "Example.xcarchive" \
  -exportOptionsPlist "ExportOptions.plist" \
  -exportPath "./" \
  -authenticationKeyIssuerID $APP_STORE_CONNECT_API_KEY_ISSUER_ID \
  -authenticationKeyID $APP_STORE_CONNECT_API_KEY_ID \
  -authenticationKeyPath $APP_STORE_CONNECT_API_KEY_PATH \
  -allowProvisioningUpdates
