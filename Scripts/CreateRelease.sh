#!/bin/bash

set -e

# Creates XCFramework
source Scripts/CreateXcframework.sh

# Builds documentation
source Scripts/CreateDocumentation.sh

# Reads current version into variable
RELEASE_VERSION=$(cat Version.resolved)

# Creates release
gh release create $RELEASE_VERSION \
  --generate-notes \
  .build/framework/*.xcframework.zip \
  .build/documentation/*.doccarchive.zip

# Push Podspecs
for PRODUCT in "ProcessOut" "ProcessOutCheckout3DS"; do
    pod trunk push $PRODUCT.podspec --allow-warnings
done
