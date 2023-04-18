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
# using `pod spec lint`.
bundle exec pod spec lint ProcessOutCheckout3DS.podspec

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved