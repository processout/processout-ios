#!/bin/sh

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

# Constants
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
WORK_DIR=$(mktemp -d)

# Script expects revision as a first and only argument
test $# -eq 1 || fail "Expected tag or branch reference."

# Go to temporary directory
cd $WORK_DIR

# Clone library
git clone --depth 1 --branch $1 https://github.com/swiftlang/swift-cmark .

# Ensure modulemap represents darwin-style framework
MODULEMAP_PATH="src/include/module.modulemap"
echo "framework $(cat $MODULEMAP_PATH)" > $MODULEMAP_PATH

# Copy project configuration
cp "$SCRIPT_DIR/project.yml" .

# Generate project
xcodegen generate

# Create frameworks for needed platforms
xcodebuild archive -scheme cmark_gfm -destination "generic/platform=iOS" -archivePath ./cmark_gfm-iOS
xcodebuild archive -scheme cmark_gfm -destination "generic/platform=iOS Simulator" -archivePath ./cmark_gfm-Sim

# Define signing arguments
CODESIGN_ARGS=(
  --timestamp
  --force
  --sign "Apple Distribution: ProcessOut Inc. (3Y9WMX63ZJ)"
  --preserve-metadata\=identifier,entitlements,flags
)

# Sign iOS framework
/usr/bin/codesign "${CODESIGN_ARGS[@]}" ./cmark_gfm-iOS.xcarchive/Products/Library/Frameworks/cmark_gfm.framework

# Sign iOS Simulator framework
/usr/bin/codesign "${CODESIGN_ARGS[@]}" ./cmark_gfm-Sim.xcarchive/Products/Library/Frameworks/cmark_gfm.framework

# Define output directory
OUTPUT_DIR="$SCRIPT_DIR/../../Vendor"

# Generate XCFramework
xcodebuild -create-xcframework \
    -framework ./cmark_gfm-iOS.xcarchive/Products/Library/Frameworks/cmark_gfm.framework \
    -framework ./cmark_gfm-Sim.xcarchive/Products/Library/Frameworks/cmark_gfm.framework \
    -output "$OUTPUT_DIR/cmark_gfm.xcframework"

# Sign XCFramework
/usr/bin/codesign "${CODESIGN_ARGS[@]}" "$OUTPUT_DIR/cmark_gfm.xcframework"

# Write metadata
CURRENT_REVISION=$(git rev-parse --short HEAD)
echo $CURRENT_REVISION > "$OUTPUT_DIR/cmark_gfm.xcframework.version"
