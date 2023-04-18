#!/bin/bash

set -e

SDK='iphonesimulator'
DESTINATION='platform=iOS Simulator,name=iPhone 14 Pro,OS=16.2'

xcodebuild clean test \
    -project ProcessOut.xcodeproj \
    -scheme ProcessOut \
    -sdk "$SDK" \
    -destination "$DESTINATION" |
    bundle exec xcpretty

# Checkout3DS dependency is only available via cocoapods now, so target is tested
# using `pod lib lint`.
bundle exec pod repo update
bundle exec pod lib lint ProcessOutCheckout3DS.podspec --allow-warnings

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
