#!/bin/bash

set -e

# # Creates XCFramework
# source Scripts/CreateXcframework.sh

# # Builds documentation
# source Scripts/CreateDocumentation.sh

# # Reads current version into variable
# RELEASE_VERSION=$(cat Version.resolved)

# # Creates release
# gh release create $RELEASE_VERSION \
#   --generate-notes \
#   --verify-tag \
#   .build/framework/*.xcframework.zip \
#   .build/documentation/*.doccarchive.zip

# # Pushes podspec
# pod trunk push ProcessOut.podspec


if $(gh release view 3.3.0) ; then
    echo "Command succeeded"
else
    echo "Command failed"
fi

gh release create 3.3.0 --generate-notes --verify-tag