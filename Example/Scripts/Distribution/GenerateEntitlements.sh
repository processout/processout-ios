#!/bin/bash

set -euo pipefail

# Generate 
ENTITLEMENTS_PATH="./Example/Example.entitlements"
echo -n $EXAMPLE_ENTITLEMENTS | base64 -d -o $ENTITLEMENTS_PATH
