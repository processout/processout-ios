#!/bin/bash

# Workaround to ignore false-negative [errors](https://github.com/CocoaPods/CocoaPods/issues/11621)
# that could happen when pushing podspecs.
set +e

# Push Podspecs
for PRODUCT in "ProcessOut" "ProcessOutCoreUI" "ProcessOutUI" "ProcessOutCheckout3DS" "ProcessOutNetcetera3DS"; do

  # This script is intended to be run on CI where cocoapods is already installed.
  pod trunk push $PRODUCT.podspec --allow-warnings --synchronous
done
