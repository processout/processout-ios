#!/bin/bash

set -euo pipefail

# Constants
WORK_DIR=$(mktemp -d)
BASE_LANGUAGE=en
BASE_LANGUAGE_XLIFF="$WORK_DIR/export/$BASE_LANGUAGE.xcloc/Localized Contents/$BASE_LANGUAGE.xliff"

# Load env
export $(cat .env | xargs)

# Create directories
mkdir -p $WORK_DIR/import
mkdir -p $WORK_DIR/export

# Export base localization
xcodebuild -exportLocalizations \
  -project ProcessOut.xcodeproj \
  -localizationPath $WORK_DIR/export \
  -exportLanguage $BASE_LANGUAGE

# Download strings
lokalise2 \
    --token $LOKALISE_TOKEN \
    --project-id "20942964654390ceed1ab9.44453861" \
    file download \
    --format xliff \
    --unzip-to $WORK_DIR/import

# Preprocess imported XLIFFs and import them in project
find $WORK_DIR/import -name '*.xliff' \
  -exec ./Scripts/PreprocessLocalization.swift "$BASE_LANGUAGE_XLIFF" '{}' \; \
  -exec xcodebuild -importLocalizations -project ProcessOut.xcodeproj -localizationPath '{}' \;

function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT
