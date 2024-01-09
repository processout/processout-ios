#!/bin/bash

set -euo pipefail

# Define variables
WORK_DIR=$(mktemp -d)

# Load env
export $(cat .env | xargs)

# Downloads strings
lokalise2 \
    --token $LOKALISE_TOKEN \
    --project-id "20942964654390ceed1ab9.44453861" \
    file download \
    --format xliff \
    --unzip-to $WORK_DIR

# Searches for all xliff files in a work directory and imports them in project
find $WORK_DIR -name '*.xliff' -exec xcodebuild -importLocalizations -project ProcessOut.xcodeproj -localizationPath '{}' \;

function cleanup {
  rm -rf $WORK_DIR
}

trap cleanup EXIT
