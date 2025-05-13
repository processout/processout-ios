#!/bin/bash

set -euo pipefail

# Create temp directory
WORK_DIR=$(mktemp -d)

# Navigate to project root
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/../.."

# Clean project
xcodebuild clean

# Write AppStore Connect API key
APP_STORE_CONNECT_API_KEY_PATH="$WORK_DIR/AuthKey.p8"
echo -n $APP_STORE_CONNECT_API_KEY_CONTENT | base64 -d -o $APP_STORE_CONNECT_API_KEY_PATH

# Credentials
AUTHENTICATION_ARGS=(
  -authenticationKeyIssuerID $APP_STORE_CONNECT_API_KEY_ISSUER_ID
  -authenticationKeyID $APP_STORE_CONNECT_API_KEY_ID
  -authenticationKeyPath $APP_STORE_CONNECT_API_KEY_PATH
  -allowProvisioningUpdates
)
DEVELOPMENT_TEAM_ID="3Y9WMX63ZJ"

# Create archive
xcodebuild archive \
  -scheme Example \
  -sdk iphoneos \
  -destination generic/platform=iOS \
  -archivePath $WORK_DIR/Example.xcarchive \
  "${AUTHENTICATION_ARGS[@]}" \
  "DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM_ID"

# Navigate to working directory
cd $WORK_DIR

# Create export options plist
/usr/libexec/PlistBuddy "ExportOptions.plist" \
  -c "Add :method string 'app-store-connect'" \
  -c "Add :destination string 'upload'" \
  -c "Add :testFlightInternalTestingOnly bool $TESTFLIGHT_INTERNAL_ONLY" \
  -c "Add :manageAppVersionAndBuildNumber bool true" \
  -c "Add :teamID string '$DEVELOPMENT_TEAM_ID'"

# Export archive
xcodebuild \
  -exportArchive \
  -archivePath "Example.xcarchive" \
  -exportOptionsPlist "ExportOptions.plist" \
  -exportPath "./" \
  "${AUTHENTICATION_ARGS[@]}"
