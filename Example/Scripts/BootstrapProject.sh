#!/bin/bash

set -euo pipefail

# Installs brew dependencies
brew bundle -q

# Installs mint dependencies if needed
if ! [[ "$@" =~ '--skip-mint-bootstrap' ]]; then
    mint bootstrap
fi

# Generates project
mint run xcodegen generate

# Creates hardlink to Package.resolved
SWIFTPM_DIR='Example.xcodeproj/project.xcworkspace/xcshareddata/swiftpm'
mkdir -p $SWIFTPM_DIR
ln -f Package.resolved $SWIFTPM_DIR/Package.resolved
