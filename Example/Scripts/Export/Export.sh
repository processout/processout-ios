#!/bin/bash

set -euo pipefail

# Configure cleanup
function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT

# Clean
xcodebuild clean

# Constants
DEVELOPMENT_TEAM_ID="3Y9WMX63ZJ"
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
  "DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM_ID"

# Navigate to working directory
cd $WORK_DIR

# Create export options plist
/usr/libexec/PlistBuddy "ExportOptions.plist" \
  -c "Add :method string 'app-store-connect'" \
  -c "Add :destination string 'upload'" \
  -c "Add :testFlightInternalTestingOnly bool true" \
  -c "Add :manageAppVersionAndBuildNumber bool true" \
  -c "Add :teamID string '$DEVELOPMENT_TEAM_ID'"

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
