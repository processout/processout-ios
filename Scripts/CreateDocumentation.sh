#!/bin/bash

set -e

xcodebuild docbuild \
    -project ProcessOut.xcodeproj \
    -derivedDataPath '.build/derived-data' \
    -scheme ProcessOut \
    -destination 'generic/platform=iOS'

ARCHIVE_PATH=$(find '.build/derived-data' -type d -name '*.doccarchive')
ARCHIVE_NAME=$(basename $ARCHIVE_PATH .doccarchive)

$(xcrun --find docc) process-archive \
    transform-for-static-hosting $ARCHIVE_PATH \
    --output-path Docs
