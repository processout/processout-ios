#!/bin/bash

set -euo pipefail

# Searches for all xliff files in a given directory and imports them in project.
find "$1" -name '*.xliff' -exec xcodebuild -importLocalizations -project ProcessOut.xcodeproj -localizationPath '{}' \;
