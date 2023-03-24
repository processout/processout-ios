#!/bin/bash

OUTPUT_DIR=".build/documentation"

function build_doc {(
    set -e

    xcodebuild docbuild \
        -project ProcessOut.xcodeproj \
        -derivedDataPath '.build/derived-data' \
        -scheme $1 \
        -destination 'generic/platform=iOS' |
        bundle exec xcpretty

    ARCHIVE_PATH=$(find '.build/derived-data' -type d -name "$1.doccarchive")

    cp -R $ARCHIVE_PATH $OUTPUT_DIR

    cd $OUTPUT_DIR
    zip $1.doccarchive.zip -r $1.doccarchive -x '.*' -x '__MACOSX'
)}

set -e

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

for PRODUCT in "ProcessOut" "ProcessOutCheckout" ; do
    build_doc $PRODUCT
done
