#!/bin/bash

set -euo pipefail

SDK='iphonesimulator17.0'
DESTINATION='platform=iOS Simulator,name=iPhone 15'

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
