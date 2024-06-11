#!/bin/bash

set -euo pipefail

# Exports version as environment variable
export CURRENT_VERSION="$(cat Version.resolved)"

# Installs brew dependencies
brew bundle -q

# SwiftGen is broken with Brew so installed with Mint instead
mint install SwiftGen/SwiftGen

# Creates project
xcodegen generate
