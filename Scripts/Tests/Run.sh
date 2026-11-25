#!/bin/bash

# Runs the tests of every module that has tests. Formats the output with xcpretty if it is installed.

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(./Scripts/Tests/Destination.swift)

# Select output formatter
if command -v xcpretty &> /dev/null; then
    FORMATTER=(xcpretty)
else
    echo "xcpretty is not installed, so the output is not formatted. To install it, run 'gem install xcpretty'." 1>&2
    FORMATTER=(cat)
fi

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutUI" "ProcessOutCheckout3DS" "ProcessOutNetcetera3DS"; do
    xcodebuild clean test \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT \
        -enableCodeCoverage NO |
        "${FORMATTER[@]}"
done
