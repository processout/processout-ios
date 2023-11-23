#!/bin/bash

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(./Scripts/TestDestination.swift)

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutUI"; do
    xcodebuild clean test \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT \
        -enableCodeCoverage NO |
        xcpretty
done

# It is a known issue that Checkout3DS v3.2.1 (framework that ProcessOutCheckout3DS
# depends on) can't be properly tested without host application due to bug.
xcodebuild clean build \
    -project $PROJECT \
    -scheme ProcessOutCheckout3DS \
    -destination "generic/platform=iOS" |
    xcpretty

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
