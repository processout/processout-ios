#!/bin/bash

set -e

SDK='iphonesimulator'
DESTINATION='platform=iOS Simulator,name=iPhone 14 Pro,OS=16.2'

xcodebuild clean test \
    -project ProcessOut.xcodeproj \
    -scheme ProcessOut \
    -sdk "$SDK" \
    -destination "$DESTINATION" |
    bundle exec xcpretty

# todo(andrii-vysotskyi): run example target tests when POM-144 is resolved