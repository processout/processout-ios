#!/bin/bash

set -euo pipefail

# Add brew binaries to PATH
export PATH="/opt/homebrew/bin:$PATH"

# Lint
# todo(andrii-vysotskyi): reenable when disable paths are fixed https://github.com/realm/SwiftLint/issues/5953
# swiftlint lint --strict
