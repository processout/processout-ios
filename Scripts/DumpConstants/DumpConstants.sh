#!/bin/bash

# Change directory
cd Scripts/DumpConstants

# Write constants to file
echo $TEST_PROJECT_CONSTANTS > Constants.yml

# Encrypt constants using public key
openssl rsautl -in Constants.yml -out Constants.yml.enc -pubin -inkey key.pub -encrypt

# Output constants
cat "Constants.yml.enc" | openssl enc -base64

# Decrypt constants
# openssl rsautl -in Constants.yml.enc -out Constants-out.yml -inkey key.pem -decrypt