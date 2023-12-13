#!/bin/bash

set -euo pipefail

# Add brew binaries to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Run sourcery
sourcery \
  --sources $PROJECT_DIR/Sources/$TARGET_NAME/Sources \
  --templates $PROJECT_DIR/Templates/AutoCompletion.stencil \
  --parseDocumentation \
  --output $PROJECT_DIR/Sources/$TARGET_NAME/Sources/Generated/Sourcery+Generated.swift
