#!/bin/bash

set -euo pipefail

PROJECT='ProcessOut.xcodeproj'
DESTINATION=$(python3 ./Scripts/TestDestination.py)

# Run Tests
for PRODUCT in "ProcessOut" "ProcessOutUI"; do
    xcodebuild clean test \
        -destination "$DESTINATION" \
        -project $PROJECT \
        -scheme $PRODUCT
done

# It is a known issue that Checkout3DS v3.2.1 (framework that ProcessOutCheckout3DS
# depends on) can't be properly tested without host application due to bug.
xcodebuild clean build \
    -project $PROJECT \
    -scheme ProcessOutCheckout3DS \
    -destination "generic/platform=iOS"

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
