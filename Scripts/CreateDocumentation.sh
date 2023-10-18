#!/bin/bash

set -euo pipefail

DOCC_TARGET_OUTPUT_DIR="./.build/artifacts/docc-static"
DOCC_OUTPUT_DIR="Docs"

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
        --output-path $2 \
        --hosting-base-path "processout-ios"
)}

mkdir -p $DOCC_TARGET_OUTPUT_DIR
mkdir -p $DOCC_OUTPUT_DIR

# Generate documentation for the primary 'ProcessOut' target
build_doc "ProcessOut" "$DOCC_OUTPUT_DIR"

# Generate documentation for secondary targets
for PRODUCT in "ProcessOutCheckout3DS" "ProcessOutCoreUI"; do

    # Generate documentation
    build_doc "$PRODUCT" "$DOCC_TARGET_OUTPUT_DIR/$PRODUCT"

    # Merge into the primary ProcessOut docs
    cp -R "$DOCC_TARGET_OUTPUT_DIR/$PRODUCT/documentation"/* "$DOCC_OUTPUT_DIR/documentation/"
    cp -R "$DOCC_TARGET_OUTPUT_DIR/$PRODUCT/data/documentation"/* "$DOCC_OUTPUT_DIR/data/documentation/"
done

# Delete non-mergable metadata.json
rm -f "$DOCC_OUTPUT_DIR/metadata.json"
