#!/bin/bash

set -euo pipefail

# Installs brew dependencies
brew bundle -q

# SwiftGen is broken with Brew so installed with Mint instead
mint install SwiftGen/SwiftGen

# Generates project
xcodegen generate

# Creates hardlink to Package.resolved
SWIFTPM_DIR='Example.xcodeproj/project.xcworkspace/xcshareddata/swiftpm'
mkdir -p $SWIFTPM_DIR
ln -f Package.resolved $SWIFTPM_DIR/Package.resolved
