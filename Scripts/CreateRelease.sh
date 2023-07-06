#!/bin/bash

set -euo pipefail

# Creates XCFramework
source Scripts/CreateXcframework.sh

# Reads current version into variable
RELEASE_VERSION=$(cat Version.resolved)

# Creates release
gh release create $RELEASE_VERSION --generate-notes .build/framework/*.xcframework.zip
