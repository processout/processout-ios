#!/bin/bash

set -euo pipefail

# Validates arguments acount
test $# -eq 1

# Add owner
for POD in "ProcessOut" "ProcessOutCoreUI" "ProcessOutUI" "ProcessOutCheckout3DS" "ProcessOutNetcetera3DS"; do
    pod trunk add-owner $POD $1
done
