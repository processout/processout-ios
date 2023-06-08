#!/bin/bash

set -e

OUTPUT_DIR="Docs"

function build_doc {(
    set -e

    # Creates doccarchive for single product
    xcodebuild docbuild \
        -project ProcessOut.xcodeproj \
        -derivedDataPath '.build/derived-data' \
        -scheme $1 \
        -destination 'generic/platform=iOS' |
        bundle exec xcpretty

    # Assigns archive path
    ARCHIVE_PATH=$(find '.build/derived-data' -type d -name "$1.doccarchive")

    # Transforms archive into static website
    $(xcrun --find docc) process-archive \
        transform-for-static-hosting $ARCHIVE_PATH \
        --output-path "$OUTPUT_DIR" \
        --hosting-base-path "processout-ios"
)}

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

# TODO(andrii-vysotskyi): Add "ProcessOutCheckout3DS" when Checkout3DS is available via SPM
for PRODUCT in "ProcessOut" ; do
    build_doc $PRODUCT
done
