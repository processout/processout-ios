#!/bin/bash

set -euo pipefail

# Add brew binaries to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Run sourcery
sourcery \
  --sources $TARGET_ROOT/Sources \
  --templates $PROJECT_DIR/Templates \
  --parseDocumentation \
  --output $TARGET_ROOT/Sources/Generated/Sourcery+Generated.swift
