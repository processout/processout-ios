#!/bin/bash

set -euo pipefail

# Reads current version into variable
RELEASE_VERSION=$(cat Version.resolved)

# Creates release
gh release create $RELEASE_VERSION --generate-notes
