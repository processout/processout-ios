#!/bin/bash

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'

# Run Tests
for PRODUCT in "ProcessOut" ; do
    xcodebuild clean test \
        -project $PROJECT \
        -scheme $PRODUCT \
        -sdk 'iphonesimulator17.0' \
        -destination 'platform=iOS Simulator,name=iPhone 15'
done

# It is a known issue that Checkout3DS v3.2.1 (framework that ProcessOutCheckout3DS
# depends on) can't be properly tested without host application due to bug.
xcodebuild clean build \
    -project $PROJECT \
    -scheme ProcessOutCheckout3DS \
    -destination "generic/platform=iOS"

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
