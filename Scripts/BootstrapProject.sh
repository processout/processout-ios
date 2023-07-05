#!/bin/bash

set -e

# Exports version as environment variable
export CURRENT_VERSION="$(cat Version.resolved)"

# Installs brew dependencies
brew bundle

# Installs mint dependencies
mint bootstrap

# Installs bundler dependencies if needed
if ! [[ "$@" =~ '--skip-bundle-instal' ]]; then
    bundle check || bundle install
fi

# Creates project
mint run xcodegen generate
