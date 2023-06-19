#!/bin/bash

# Workaround to ignore false-negative [errors](https://github.com/CocoaPods/CocoaPods/issues/11621)
# that could happen when pushing podspecs.
set +e

# Push Podspecs
for PRODUCT in "ProcessOut" "ProcessOutCheckout3DS"; do
  bundle exec pod trunk push $PRODUCT.podspec --allow-warnings --synchronous
done
