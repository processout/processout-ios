#!/bin/bash

set -euo pipefail

# Exports version as environment variable
export CURRENT_VERSION="$(cat Version.resolved)"

# Installs brew dependencies
brew bundle -q

# Installs bundler dependencies if needed
if ! [[ "$@" =~ '--skip-bundle-instal' ]]; then
    bundle check || bundle install
fi

# Creates project
xcodegen generate
