#!/bin/bash

set -euo pipefail

SDK='iphonesimulator'
DESTINATION='platform=iOS Simulator,name=iPhone 14 Pro,OS=latest'

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutCheckout3DS" ; do
    xcodebuild clean test \
        -project ProcessOut.xcodeproj \
        -scheme "$PRODUCT" \
        -sdk "$SDK" \
        -destination "$DESTINATION" |
        bundle exec xcpretty
done

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
