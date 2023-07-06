#!/bin/bash

OUTPUT_DIR=".build/framework"

function build_framework {(
    set -euo pipefail

    xcodebuild archive \
        -scheme $1 \
        -destination "generic/platform=iOS" \
        -archivePath .build/framework/$1-iOS |
        bundle exec xcpretty

    xcodebuild archive \
        -scheme $1 \
        -destination "generic/platform=iOS Simulator" \
        -archivePath .build/framework/$1-Sim |
        bundle exec xcpretty

    cd .build/framework

    xcodebuild -create-xcframework \
        -framework ./$1-iOS.xcarchive/Products/Library/Frameworks/$1.framework \
        -framework ./$1-Sim.xcarchive/Products/Library/Frameworks/$1.framework \
        -output ./$1.xcframework

    zip $1.xcframework.zip -r $1.xcframework -x '.*' -x '__MACOSX'
)}

set -euo pipefail

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# TODO(andrii-vysotskyi): Add "ProcessOutCheckout3DS" when Checkout3DS is available via SPM
for PRODUCT in "ProcessOut"; do
    build_framework $PRODUCT
done
