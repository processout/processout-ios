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
# trap cleanup EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OUTPUT_DIR="$SCRIPT_DIR/../../Vendor"
WORK_DIR=$(mktemp -d)

# Script expects revision as a first and only argument
test $# -eq 1 || fail "Expected tag or branch reference."

# Exports version as environment variable
export CURRENT_VERSION=$1

# Go to temporary directory
cd $WORK_DIR

# Clone library
git clone --depth 1 --branch $CURRENT_VERSION https://github.com/swiftlang/swift-cmark .

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

# Generate XCFramework
xcodebuild -create-xcframework \
    -framework ./cmark_gfm-iOS.xcarchive/Products/Library/Frameworks/cmark_gfm.framework \
    -framework ./cmark_gfm-Sim.xcarchive/Products/Library/Frameworks/cmark_gfm.framework \
    -output "$OUTPUT_DIR/cmark_gfm.xcframework"

# Write metadata
echo $CURRENT_VERSION > "$OUTPUT_DIR/cmark_gfm.xcframework.version"
