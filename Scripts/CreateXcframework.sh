#!/bin/bash

set -e

rm -rf .build/framework

xcodebuild archive \
    -scheme ProcessOut \
    -destination "generic/platform=iOS" \
    -archivePath .build/framework/ProcessOut-iOS \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES |
    bundle exec xcpretty

xcodebuild archive \
    -scheme ProcessOut \
    -destination "generic/platform=iOS Simulator" \
    -archivePath .build/framework/ProcessOut-Sim \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES |
    bundle exec xcpretty

cd .build/framework

xcodebuild -create-xcframework \
    -framework ./ProcessOut-iOS.xcarchive/Products/Library/Frameworks/ProcessOut.framework \
    -framework ./ProcessOut-Sim.xcarchive/Products/Library/Frameworks/ProcessOut.framework \
    -output ./ProcessOut.xcframework
