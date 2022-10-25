#!/bin/bash

set -e

# Installs mint dependencies
mint bootstrap

# Generates project
mint run xcodegen generate

# Creates hardlink to Package.resolved
SWIFTPM_DIR='Example.xcodeproj/project.xcworkspace/xcshareddata/swiftpm'
mkdir -p $SWIFTPM_DIR
ln -f Package.resolved $SWIFTPM_DIR/Package.resolved
