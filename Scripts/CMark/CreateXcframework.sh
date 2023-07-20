#!/bin/sh

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
OUTPUT_DIR="$SCRIPT_DIR/../../Vendor"
WORK_DIR=$(mktemp -d)

# Script expects revision as a first and only argument
test $# -eq 1

# Exports version as environment variable
export CURRENT_VERSION=$1

# Go to temporary directory
cd $WORK_DIR

# Clone library
git clone --depth 1 --branch $CURRENT_VERSION https://github.com/commonmark/cmark .

# Create temporary Xcode project
mkdir build && cd build && cmake -G Xcode .. && cd ../

# Copy generated headers
find build/src -name "*.h" -exec cp '{}' src/ \;

# Fix imports
sed -i'.bak' -e 's/<cmark_export.h>/"cmark_export.h"/g' src/cmark.h
sed -i'.bak' -e 's/<cmark_version.h>/"cmark_version.h"/g' src/cmark.h
rm src/cmark.h.bak

# Copy modulemap
cp "$SCRIPT_DIR/module.modulemap" src/

# Copy project Configuration
cp "$SCRIPT_DIR/project.yml" .

# Generate project
mint run xcodegen generate

# Create frameworks for needed platforms
xcodebuild archive -scheme cmark -destination "generic/platform=iOS" -archivePath ./cmark-iOS
xcodebuild archive -scheme cmark -destination "generic/platform=iOS Simulator" -archivePath ./cmark-Sim

# Generate XCFramework
xcodebuild -create-xcframework \
    -framework ./cmark-iOS.xcarchive/Products/Library/Frameworks/cmark.framework \
    -framework ./cmark-Sim.xcarchive/Products/Library/Frameworks/cmark.framework \
    -output "$OUTPUT_DIR/cmark.xcframework"

# Write metadata
echo $CURRENT_VERSION > "$OUTPUT_DIR/cmark.xcframework.version"

function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT
