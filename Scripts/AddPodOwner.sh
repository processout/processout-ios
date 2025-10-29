#!/bin/bash

set -euo pipefail

# Validates arguments count
test $# -eq 1

# Add owner
for POD in "ProcessOutCore" "ProcessOut" "ProcessOutCoreUI" "ProcessOutUI" "ProcessOutCheckout3DS"; do
    pod trunk add-owner $POD $1
done
