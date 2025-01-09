#!/bin/bash

set -euo pipefail

# Navigate to project root
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.."

# Installs brew dependencies
brew bundle -q

# Generate entitlements
ENTITLEMENTS_PATH="./Example/Example.entitlements"
if [ -n "${EXAMPLE_ENTITLEMENTS}" ]; then
    echo -n $EXAMPLE_ENTITLEMENTS | base64 -d -o $ENTITLEMENTS_PATH
fi

# Generates project
xcodegen generate
