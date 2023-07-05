#!/bin/bash

set -euo pipefail

SDK='iphonesimulator'
DESTINATION='platform=iOS Simulator,name=iPhone 14 Pro,OS=latest'

export TARGET_ROOT="$(pwd)/Tests/ProcessOutTests/"

source Scripts/SwiftGen.sh

# xcodebuild clean test \
#     -project ProcessOut.xcodeproj \
#     -scheme ProcessOut \
#     -sdk "$SDK" \
#     -destination "$DESTINATION" |
#     bundle exec xcpretty

# # Checkout3DS dependency is only available via cocoapods now, so target is tested
# # using `pod lib lint`.
# bundle exec pod repo update
# bundle exec pod lib lint ProcessOutCheckout3DS.podspec --allow-warnings

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved
