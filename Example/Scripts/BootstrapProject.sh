#!/bin/bash

set -euo pipefail

# Installs brew dependencies
brew bundle -q

# Generates project
xcodegen generate
