#!/bin/bash

set -euo pipefail

# Navigate to project root
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd "$SCRIPT_DIR/.."

# Installs brew dependencies
brew bundle -q

# Generates project
xcodegen generate
