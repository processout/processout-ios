#!/bin/bash

set -euo pipefail

# Exports version as environment variable
export CURRENT_VERSION="$(cat Version.resolved)"

# Installs brew dependencies
brew bundle -q

# Creates project
xcodegen generate
