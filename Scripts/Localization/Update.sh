#!/bin/bash

set -euo pipefail

# Constants
export WORK_DIR=$(mktemp -d)
export BASE_LANGUAGE=en

function import_localization {

  # Constants
  BASE_LANGUAGE_XLIFF="$WORK_DIR/export/$BASE_LANGUAGE.xcloc/Localized Contents/$BASE_LANGUAGE.xliff"

  # Export base localization
  xcodebuild -exportLocalizations \
    -project ProcessOut.xcodeproj \
    -localizationPath $WORK_DIR/export \
    -exportLanguage $BASE_LANGUAGE

  # Preprocess XLIFF
  ./Scripts/Localization/PreprocessXliff.swift "$BASE_LANGUAGE_XLIFF" $1

  # Import localization
  xcodebuild -importLocalizations -project ProcessOut.xcodeproj -localizationPath $1
}

# Configure exports
export $(cat .env | xargs)
export -f import_localization

# Validates arguments acount
test $# -eq 1

IMPORT_DIR=$1

# Create directories
mkdir -p $WORK_DIR/import
mkdir -p $WORK_DIR/export

# todo(andrii-vysotskyi): uncomment when access to API is restored
# Download strings
# lokalise2 \
#     --token $LOKALISE_TOKEN \
#     --project-id "20942964654390ceed1ab9.44453861" \
#     file download \
#     --format xliff \
#     --unzip-to $WORK_DIR/import

# Import available localizations
find $IMPORT_DIR -name '*.xliff' -exec /bin/bash -c 'import_localization "$0"' {} \;

function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT
