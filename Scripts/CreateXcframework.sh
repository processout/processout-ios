#!/bin/bash

set -e

rm -rf .build/framework
mkdir -p .build/framework

xcodebuild archive \
    -scheme ProcessOut \
    -destination "generic/platform=iOS" \
    -archivePath .build/framework/ProcessOut-iOS |
    bundle exec xcpretty

xcodebuild archive \
    -scheme ProcessOut \
    -destination "generic/platform=iOS Simulator" \
    -archivePath .build/framework/ProcessOut-Sim |
    bundle exec xcpretty

cd .build/framework

xcodebuild -create-xcframework \
    -framework ./ProcessOut-iOS.xcarchive/Products/Library/Frameworks/ProcessOut.framework \
    -framework ./ProcessOut-Sim.xcarchive/Products/Library/Frameworks/ProcessOut.framework \
    -output ./ProcessOut.xcframework

zip ProcessOut.xcframework.zip -r ProcessOut.xcframework -x '.*' -x '__MACOSX'
