#!/bin/bash

set -euo pipefail

# Validates arguments account
test $# -eq 1

# Add owner
for POD in "ProcessOut" "ProcessOutCoreUI" "ProcessOutUI" "ProcessOutNetcetera3DS"; do
    pod trunk add-owner $POD $1
done
