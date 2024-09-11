#!/bin/bash

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(./Scripts/TestDestination.swift)

# todo(andrii-vysotskyi): reenable "ProcessOutCheckout3DS" tests
# when Swift6 compatibility is fixed

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutUI"; do
    xcodebuild clean test \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT \
        -enableCodeCoverage NO |
        xcpretty
done

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
