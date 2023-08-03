#!/bin/bash

set -euo pipefail

# Add brew binaries to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Run SwiftGen
swiftgen config run
