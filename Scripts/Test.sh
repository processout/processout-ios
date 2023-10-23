#!/bin/bash

set -euo pipefail

SDK='iphonesimulator17.0'
DESTINATION='platform=iOS Simulator,name=iPhone 15'

# Run Tests
for PRODUCT in "ProcessOut" ; do
    xcodebuild clean test \
        -project ProcessOut.xcodeproj \
        -scheme "$PRODUCT" \
        -sdk "$SDK" \
        -destination "$DESTINATION" |
        bundle exec xcpretty
done

# It is a known issue that Checkout3DS v3.2.1 (framework that ProcessOutCheckout3DS
# depends on) can't be properly tested without host application due to bug.
xcodebuild clean build \
    -project ProcessOut.xcodeproj \
    -scheme ProcessOutCheckout3DS \
    -sdk "$SDK" \
    -destination "$DESTINATION" |
    bundle exec xcpretty

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
