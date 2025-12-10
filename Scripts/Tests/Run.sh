#!/bin/bash

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(./Scripts/Tests/Destination.swift)

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutUI" "ProcessOutNetcetera3DS"; do
    xcodebuild clean test \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT \
        -enableCodeCoverage NO |
        xcpretty
done
