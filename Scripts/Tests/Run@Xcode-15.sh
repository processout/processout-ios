#!/bin/bash

# Note: Test targets are not compatible with Xcode 15.
# This script ensures that the project can be built successfully as a minimal validation check.

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(./Scripts/Tests/Destination.swift)

# Iterate over each product and build it using xcodebuild
for PRODUCT in "ProcessOut" "ProcessOutUI" "ProcessOutCheckout3DS"; do
    xcodebuild clean build \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT \
        xcpretty
done
